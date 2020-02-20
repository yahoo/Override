// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import UIKit
import YMOverride

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    #if swift(>=5.0)
    typealias LaunchOptionsKeyType = UIApplication.LaunchOptionsKey
    #else
    typealias LaunchOptionsKeyType = UIApplicationLaunchOptionsKey
    #endif

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [LaunchOptionsKeyType: Any]?) -> Bool {
        
        guard let tabController = window?.rootViewController as? UITabBarController else { return true }

        let featureVC = FeaturesViewController()
        featureVC.featureRegistry = MyFeatures(withFeatureStore: UserDefaultsFeatureStore())
        tabController.viewControllers = [featureVC]

        return true
    }
}
