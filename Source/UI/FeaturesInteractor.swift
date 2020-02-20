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

extension FeaturesInteractor: UISearchResultsUpdating, UISearchBarDelegate {

    public func updateSearchResults(for searchController: UISearchController) {
        updateResultsForSearchBar(searchController.searchBar)
    }

    /// Handle search bar scope button taps. This delegate method does nothing for iOS 13+ since that version
    /// invokes the updateSearchResults(for:) method before this one. There is no need to use UISearchBarDelegate
    /// in iOS 13+ as of 2/14/2020
    /// - Parameters:
    ///   - searchBar: The search bar to use to update results
    ///   - selectedScope: The new selected scope index
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // In iOS 13, updateSearchResults(for:) in UISearchResultsUpdating is invoked for scope
        // changes, so the logic is handled in there.
        if #available(iOS 13, tvOS 13, *) {
            return
        }

        updateResultsForSearchBar(searchBar)
    }

    func updateResultsForSearchBar(_ searchBar: UISearchBar) {
        guard let featuresVC = presenter.output as? FeaturesTableViewController
            else { return }

        let selectedScope = searchBar.selectedScopeButtonIndex
        guard let buttonTitles = searchBar.scopeButtonTitles,
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

        featuresVC.presenter.filter(featuresVC.tableView, query: searchBar.textForFeatureQuery, scope: scope)
    }
}
