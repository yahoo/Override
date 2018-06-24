// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

@objc open class FeaturesViewController: UINavigationController {

    @objc public var featureRegistry: FeatureRegistry? {
        didSet {
            guard let featureRegistry = featureRegistry else {
                return viewControllers = []
            }

            let featuresTableView = FeaturesTableViewController(features: featureRegistry.features)
            viewControllers = [featuresTableView]
        }
    }
}
