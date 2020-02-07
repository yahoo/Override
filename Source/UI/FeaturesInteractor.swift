// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

class FeaturesInteractor: NSObject, UITableViewDelegate {

    let presenter: FeaturesPresenter

    init(withPresenter presenter: FeaturesPresenter) {
        self.presenter = presenter
    }
}

extension FeaturesInteractor: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let featuresVC = presenter.output as? FeaturesTableViewController
            else { return }

        let selectedScope = searchController.searchBar.selectedScopeButtonIndex
        guard let buttonTitles = searchController.searchBar.scopeButtonTitles,
            selectedScope < buttonTitles.count else { return }

        let scope: FeaturesPresenter.FilterScope
        switch buttonTitles[selectedScope].lowercased() {
        case "enabled":
            scope = .enabled
        case "disabled":
            scope = .disabled
        case "overridden":
            scope = .overridden
        default:
            scope = .all
        }

        let query = searchController.searchBar.searchTextField.isEditing ? searchController.searchBar.text : nil
        featuresVC.presenter.filter(featuresVC.tableView, query: query, scope: scope)
    }
}
