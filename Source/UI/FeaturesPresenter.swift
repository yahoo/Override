// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

class FeaturesPresenter: NSObject {

    enum RestartPromptResolution: Int {
        // Flag indicating that the restart prompt was accepted. The overridden
        // change should be applied
        case acceptAndContinue

        // Flag indicating that the user opted to remain on the FeaturesViewController,
        // perhaps to undo some of the changes that triggered the restart requirement.
        case cancel
    }

    weak var output: UIViewController?

    let features: [LabeledItem]

    init(withFeatures features: [LabeledItem]) {
        self.features = features
    }

    func updateFeature(tableView: UITableView, indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func showSelector(_ tableView: UITableView, indexPath: IndexPath,
                      handler: @escaping (_: AnyFeature, _: OverrideState) -> Void) {
        // Ensure the index path is for a feature, not a feature container
        guard indexPath.row <= features.count,
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

        output?.present(alert, animated: true, completion: nil)
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

    func present(_ tableView: UITableView, groupAtIndexPath indexPath: IndexPath) {
        guard let labeledGroup = features[indexPath.row] as? LabeledGroupItem else { return }
        let groupTableViewController = FeaturesTableViewController(features: labeledGroup.features)

        if let navController = output?.navigationController {
            navController.pushViewController(groupTableViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            output?.present(groupTableViewController, animated: false) {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

extension FeaturesPresenter: UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labeledItem = features[indexPath.row]

        let cellID: FeaturesTableViewController.FeatureCellIdentifier = labeledItem is LabeledGroupItem ? .groupCell : .switchCell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID.rawValue, for: indexPath)

        switch (labeledItem, cell) {
        case (let labeledGroup as LabeledGroupItem, let cell as FeatureGroupCell):
            cell.labeledGroup = labeledGroup
        case (let labeledFeature as LabeledFeatureItem, let cell as FeatureSwitchCell):
            cell.labeledFeature = labeledFeature
        default:
            break
        }

        return cell
    }
}
