// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

/// A container used to group multiple features into a logical set.
///
/// Feature aid in grouping related features for display and
/// interactivity purposes. The Feature to FeatureGroup mapping is
/// exposed by the registry so that it can be used for formatting
/// and display purposes.
///
/// class ThemeFeatures: FeatureGroup {
///     let darkMode: Feature()
///
///     let italicizeFonts: Feature()
/// }
///
/// class MyFeatures: FeatureRegistry {
///     let portraitVideos = Feature()
///
///     let themeFeatures = ThemeFeatures()
/// }
///
/// In the example above, MyFeatures contains a top-level feature
/// for "portrait videos", and a group of features for app "theme".
/// Programatically, these features can be accessed like so:
///
/// if myFeatures.portraitVideos.enabled { ... }
/// if myFeatures.themeFeatures.darkMode.enabled { ... }
///
/// FeatureGroup instances may not be nested at this time.
@objc open class FeatureGroup: NSObject, FeatureProvider, FeatureExtractableByMirror {
    // Potentially add helper properties here in the future.
    // This is a class (vs protocol) because we need to declare
    // internal conformance to FeatureExtractable for Obj-C compat.
}
