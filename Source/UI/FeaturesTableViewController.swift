// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

@objc public class FeaturesTableViewController: UITableViewController {

    enum FeatureCellIdentifier: String {
        case switchCell = "FeatureSwitchCell"
        case groupCell = "FeatureGroupCell"
    }

    let presenter: FeaturesPresenter

    let interactor: FeaturesInteractor

    init<C: Collection>(features: C) where C.Element == LabeledItem {
        let arrayFeatures = Array(features)

        presenter = FeaturesPresenter(withFeatures: arrayFeatures)
        interactor = FeaturesInteractor(withPresenter: presenter)

        super.init(style: UITableView.Style.plain)

        presenter.output = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FeatureSwitchCell.self, forCellReuseIdentifier: FeatureCellIdentifier.switchCell.rawValue)
        tableView.register(FeatureGroupCell.self, forCellReuseIdentifier: FeatureCellIdentifier.groupCell.rawValue)

        tableView.dataSource = presenter
        tableView.delegate = interactor

        #if os(iOS)
        extendedViewDidLoad()
        #endif
    }
}

#if os(iOS) /* iOS-Only Extension */
extension FeaturesTableViewController {
    func extendedViewDidLoad() {
        tableView.estimatedRowHeight = 50

        // Setup the search/filter interface
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = interactor
        if #available(iOS 13, *) {
            // In iOS 13, searchController.searchResultsUpdater is called whenever the
            // search bar scope seletion changes. There is no need for a search bar delegate.
        } else {
            // Pre-iOS 13, the search bar delegate was the only way to know if the scope
            // buttons changed, and to update the results. In iOS 13 this delegate is
            // made redundant.
            searchController.searchBar.delegate = interactor
        }
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = FeaturesPresenter.FilterScope.allCases.map { $0.rawValue }
        definesPresentationContext = true

        if #available(iOS 11, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }

    public override var navigationItem: UINavigationItem {
        let rightItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        super.navigationItem.rightBarButtonItem = rightItem
        return super.navigationItem
    }


    @objc func share(sender: UIBarButtonItem) {
        self.presenter.share(sender: sender)
    }
}
#endif

// MARK: - Support for direct initialization
@objc public extension FeaturesTableViewController {

    /// Initialize using a FeatureRegistry directly. This initializer
    /// allows use of this table view controller without the navigation
    /// controller provided by FeaturesViewController.
    ///
    /// - Parameter featureRegistry: The feature registry to use
    convenience init(featureRegistry: FeatureRegistry) {
        self.init(features: featureRegistry.features)
    }
}
