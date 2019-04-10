// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import YMOverride

//@objc public class ThemeFeatures: FeatureGroup {
//    @objc let
//}

@objc public class MyFeatures: FeatureRegistry {
    @objc let articlePreviews = Feature(key: "kFeatureA")
    
    @objc let streamingQuotes = Feature(key: "kFeatureB", requiresRestart: true)
    
    @objc let newHomeTab = Feature(key: "kFeatureC", requiresRestart: true, defaultState: true)
    
    @objc let aRemoteFeature = DynamicFeature(key: "kFeatureD") { _ in
        // get the default state from a dynamic source, such as a dictionary
        // backed by a JSON file, server-provided config, or database.
        false
    }
    
    /// Example of how non-feature properties are supported.
    @objc let otherValue: String = "I am not a feature, so I will be ignored"
}
