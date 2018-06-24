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

// MARK: - Tap-y stuff
#if os(iOS)
extension FeaturesInteractor {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return presenter.features[indexPath.row] is LabeledGroupItem
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.present(tableView, groupAtIndexPath: indexPath)
    }
}
#endif
