// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

class FeaturesInteractor: NSObject, UITableViewDelegate, UISearchResultsUpdating {

    let presenter: FeaturesPresenter

    init(withPresenter presenter: FeaturesPresenter) {
        self.presenter = presenter
    }
}

extension FeaturesInteractor {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchResultsVC = (searchController.searchResultsController as? FeaturesTableViewController)
            else { return }

        searchResultsVC.presenter.filter(searchResultsVC.tableView, query: searchController.searchBar.text)
    }
}
