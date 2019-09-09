// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

#if os(tvOS)
extension FeaturesInteractor { /* UITableViewDelegate */

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.showSelector(tableView, indexPath: indexPath) { [weak self] (feature, overrideState) in

            self?.presenter.showRestartPrompt(for: feature) { [weak self] resolution in
                switch resolution {
                case .acceptAndContinue:
                    feature.override = overrideState
                    self?.presenter.updateFeature(tableView: tableView, indexPath: indexPath)
                case .cancel:
                    return
                }
            }
        }
    }
}
#endif
