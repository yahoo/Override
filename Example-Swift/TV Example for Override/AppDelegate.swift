// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import UIKit
import Override

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if let featureVC = window?.rootViewController as? FeaturesViewController {
            let features = MyFeatures(withFeatureStore: UserDefaultsFeatureStore())
            featureVC.featureRegistry = features
        }

        return true
    }
}

