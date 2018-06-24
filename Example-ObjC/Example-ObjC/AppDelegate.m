// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

#import "AppDelegate.h"
#import "Example_ObjC-Swift.h"
#import "FirstViewController.h"
@import Override;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UITabBarController *tabVC = (UITabBarController *)self.window.rootViewController;
    UserDefaultsFeatureStore *featureStore = [[UserDefaultsFeatureStore alloc] initWithKeyPrefix:@"Override_"];
    MyFeatures *features = [[MyFeatures alloc] initWithFeatureStore:featureStore];

    FirstViewController *firstVC = tabVC.viewControllers.firstObject;
    firstVC.features = features;
    
    FeaturesViewController *featuresVC = tabVC.viewControllers.lastObject;
    featuresVC.featureRegistry = features;

    return YES;
}

@end
