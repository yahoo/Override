// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import UIKit
import YMOverride

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard let tabController = window?.rootViewController as? UITabBarController else { return true }

        let featureVC = FeaturesViewController()
        featureVC.featureRegistry = MyFeatures(withFeatureStore: UserDefaultsFeatureStore())
        tabController.viewControllers = [featureVC]

        return true
    }
}
