// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

class FeaturesPresenter: NSObject, UITableViewDataSource {

    enum RestartPromptResolution: Int {
        // Flag indicating that the restart prompt was accepted. The overridden
        // change should be applied
        case acceptAndContinue

        // Flag indicating that the user opted to remain on the FeaturesViewController,
        // perhaps to undo some of the changes that triggered the restart requirement.
        case cancel
    }

    enum FilterScope: String, CaseIterable {
        case all = "No Filter"
        case enabled = "Enabled"
        case disabled = "Disabled"
        case overridden = "Overridden"
    }

    weak var output: UIViewController?

    var features: [LabeledItem] { filteredFeatures ?? allFeatures }

    let colorProvider: FeatureStateColorProvider

    private let allFeatures: [LabeledItem]
    private var filteredFeatures: [LabeledSearchResultItem]?

    init(withFeatures features: [LabeledItem],
         colorProvider: FeatureStateColorProvider) {
        self.allFeatures = features
        self.colorProvider = colorProvider
    }

    /// If the feature require restart (see `featuresRequiringRestart`), presents
    /// an alert from the provided view controller explaining that the feature
    /// changes require the app to be restarted. The alert includes two options:
    /// "Restart" (which terminates the app), and "Cancel" which dismisses the
    /// alert. The caller should only dismiss this view controller in completion()
    ///
    /// - Parameters:
    ///   - for: The feature to show a restart prompt for
    ///   - completion: A block invoked only if no features currently mandate a restart
    func showRestartPrompt(for feature: AnyFeature,
                           completion: @escaping (RestartPromptResolution) -> Void) {
        guard let output = output, feature.requiresRestart else { return completion(.acceptAndContinue) }

        let message = "Changing the feature \(feature.description) require a restart to take effect"
        let alert = UIAlertController(title: "Restart required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in completion(.cancel) })
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in completion(.acceptAndContinue) })
        output.present(alert, animated: true, completion: nil)
    }
}

extension FeaturesPresenter { /* UITableViewDataSource */

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labeledItem = features[indexPath.row]

        switch labeledItem {
        case let item as LabeledGroupItem:
            let cellID = FeaturesTableViewController.FeatureCellIdentifier.groupCell.rawValue
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            if let cell = cell as? FeatureGroupCell {
                cell.labeledGroup = item
            }
            return cell

        case let item as LabeledSearchResultItem:
            let cellID = FeaturesTableViewController.FeatureCellIdentifier.switchCell.rawValue
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            if let cell = cell as? FeatureSwitchCell {
                cell.configure(with: item.result,
                               colorProvider: colorProvider)
                cell.featurePath = item.groupStack
            }
            return cell

        default:
            let cellID = FeaturesTableViewController.FeatureCellIdentifier.switchCell.rawValue
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

            if let cell = cell as? FeatureSwitchCell {
                cell.configure(with: labeledItem as? LabeledFeatureItem,
                               colorProvider: colorProvider)
            }
            return cell
        }
    }
}

extension FeaturesPresenter { /* UITableViewController Support Methods */

    private struct LabeledSearchResultItem: LabeledFeatureItemLike {
        var label: String { return result.label }

        var feature: AnyFeature { return result.feature }

        let groupStack: [LabeledGroupItem]

        let result: LabeledFeatureItem
    }

    func updateFeature(tableView: UITableView, indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func showSelector(_ tableView: UITableView, indexPath: IndexPath,
                      handler: @escaping (_: AnyFeature, _: OverrideState) -> Void) {
        // Ensure the index path is for a feature, not a feature container
        guard let output = output,
            indexPath.row <= features.count,
            let labeledFeature = features[indexPath.row] as? LabeledFeatureItem
            else { return }

        let alert = UIAlertController(title: labeledFeature.label, message: "Choose a state", preferredStyle: .alert)

        let feature = labeledFeature.feature
        OverrideState.allCases.forEach { state in
            let title: String
            if state == .featureDefault {
                title = "\(state.description.capitalized) (\(feature.defaultState.description.capitalized))"
            } else {
                title = state.description.capitalized
            }

            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                handler(feature, state)
                self?.updateFeature(tableView: tableView, indexPath: indexPath)
            })
        }

        output.present(alert, animated: true, completion: nil)
    }

    func present(_ tableView: UITableView, groupAtIndexPath indexPath: IndexPath) {
        guard let labeledGroup = features[indexPath.row] as? LabeledGroupItem else { return }
        let groupTableViewController = FeaturesTableViewController(features: labeledGroup,
                                                                   colorProvider: colorProvider)

        if let navController = output?.navigationController {
            navController.pushViewController(groupTableViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
        } else if let output = output {
            output.present(groupTableViewController, animated: false) {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

#if os(iOS)
extension FeaturesPresenter { /* Sharing */
    func share(sender from: UIBarButtonItem) {
        guard let output = output else { return }

        let oneLineDescription = features.featuresDescription.joined(separator: "\n")
        let activityVC = UIActivityViewController(activityItems: [ oneLineDescription ], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = from
        output.present(activityVC, animated: true)
    }
}
#endif

// MARK: Filter Support Functions

extension FeaturesPresenter {

    /// Filter by search query
    /// - Parameters:
    ///   - tableView: Table view containing the results
    ///   - query: The query to search for and filter results.
    func filter(_ tableView: UITableView, query: String?, scope: FeaturesPresenter.FilterScope = .all) {
        defer {
            tableView.reloadData()
        }

        //
        if let query = query, query.isEmpty {
            filteredFeatures = [] // Search query is "", happens when search field is active
            return
        } else if query == nil, scope == .all {
            filteredFeatures = nil // Search query is not active
            return
        }

        // First scope the features down
        let scoped = allFeatures.filter(scope: scope)

        // If there is no query, convert the scoped results to Search Results
        let filterFun: (LabeledFeatureItem) -> Bool
        if let query = query?.lowercased(), !query.isEmpty {
            filterFun = { $0.label.lowercased().contains(query) }
        } else {
            filterFun = { _ in true }
        }

        filteredFeatures = scoped.depthFirstCompactMap(resultBuilder: { groupStack, feature in
            return LabeledSearchResultItem(groupStack: groupStack, result: feature)
        }, filter: filterFun)
    }
}

fileprivate extension Collection where Element == LabeledItem {

    /// Filter by FeaturesPresenter.FilterScope scopes
    /// - Parameters:
    ///   - scope: The scope to filter to
    func filter(scope: FeaturesPresenter.FilterScope) -> [Self.Element] {
        switch scope {
        case .all:
            return Array(self)
        case .disabled:
            return filter(enabled: false)
        case .enabled:
            return filter(enabled: true)
        case .overridden:
            return filter(overrideStates: Set([ .enabled, .disabled ]))
        }
    }

    /// Filter by scope consisting of OverrideState
    /// - Parameters:
    ///   - states: Set of OverrideState scopes to filter by
    func filter(enabled: Bool? = nil, overrideStates: Set<OverrideState>? = nil) -> [Self.Element] {
        return self.reduce(into: [LabeledItem]()) { (accumulator, item) in
            if let item = item as? LabeledFeatureItemLike {
                if let enabled = enabled, item.feature.enabled != enabled {
                    // enabled is specified and does not match
                    return
                }

                if let states = overrideStates, !states.contains(item.feature.override) {
                    // override state is specified and does not match
                    return
                }

                accumulator.append(item)
            } else if let group = item as? LabeledGroupItem {
                let filteredFeatures = group.filter(enabled: enabled, overrideStates: overrideStates)
                if !filteredFeatures.isEmpty {
                    let filteredGroup = LabeledGroupItem(label: item.label, features: Array(filteredFeatures))
                    accumulator.append(filteredGroup)
                }
            }
        }
    }
}
