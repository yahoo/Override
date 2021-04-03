// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import YMOverride

@objc public class ThemeImageFeatures: FeatureGroup {
    let prefetchImages = Feature()
    let cacheImages = Feature()
    let resizeImages = Feature()
}

@objc public class ThemeFeatureModes: FeatureGroup {
    let applyToIcons = Feature()
    let applyToTitles = Feature()
    let applyToCaptions = Feature()
    let imageModes = ThemeImageFeatures()
}

@objc public class ThemeFeatures: FeatureGroup {
    let darkMode = Feature()
    let customFont = Feature(requiresRestart: true)
    let advanced = ThemeFeatureModes()
}

@objc public class MyFeatures: FeatureRegistry { // @objc needed to use @IBOutlet

    @Feature1 var wrapped = true

    let theme = ThemeFeatures()
    
    /// This feature will be stored under the key "articlePreviews" because a key
    /// was not specified. It also doesn't require a restart and defaults to off
    let articlePreviews = Feature()

    /// This feature *will* require a restart on change.
    /// (Similar to articlePreviews, the key is the property name and default off
    let streamingQuotes = Feature(requiresRestart: true)

    /// This feature will *will* require a restart on change, and defaults to on.
    let newHomeTab = Feature(requiresRestart: true, defaultState: true)

    /// This feature will be stored under the custom key "kPreviousKey". This is
    /// very useful if the variable name has changed.
    /// (Since other parameters are omitted: no restart required; defaults to off)
    let legacyMode = Feature(key: "previousKey")

    /// This is a "dynamic feature" in that it's default value is comuted on-demand
    /// each time it is needed. This is especially useful when the runtime state
    /// is used to decide on a default, or for remotely controlled defaults.
    let aRemoteFeature = DynamicFeature { _ in
        // get the default state from a dynamic source, such as a dictionary
        // backed by a JSON file, server-provided config, or database.
        false
    }

    /// This is a "dynamic feature" with no parameters omitted, for reference.
    let tuesdayMode = DynamicFeature(key: "customKey", requiresRestart: true) { _ in
        // This feature defaults to "enabled" only on Tuesdays.
        let components = Calendar.current.dateComponents(Set([.weekday]), from: Date())
        return components.weekday == 3
    }

    let otherValue: String = "I am not a feature, so I will be ignored"
}
