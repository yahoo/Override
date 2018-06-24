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

    init(features: [LabeledItem]) {
        presenter = FeaturesPresenter(withFeatures: features)
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

        #if os(iOS)
        tableView.estimatedRowHeight = 60
        #endif

        tableView.dataSource = presenter
        tableView.delegate = interactor
    }
}

// MARK: - Support for direct initialization
@objc public extension FeaturesTableViewController {

    /// Initialize using a FeatureRegistry directly. This initializer
    /// allows use of this table view controller without the navigation
    /// controller provided by FeaturesViewController.
    ///
    /// - Parameter featureRegistry: The feature registry to use
    public convenience init(featureRegistry: FeatureRegistry) {
        self.init(features: featureRegistry.features)
    }
}
