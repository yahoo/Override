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
        tableView.estimatedRowHeight = 60

        // Setup the search/filter interface
        let searchController = UISearchController(searchResultsController: FeaturesTableViewController(features: presenter.features))
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = interactor
        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        #endif
    }
}

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
