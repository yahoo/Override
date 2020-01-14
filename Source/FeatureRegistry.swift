// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

protocol LabeledItem {
    var label: String { get }
}

protocol LabeledFeatureItemLike: LabeledItem {
    var feature: AnyFeature { get }
}

struct LabeledFeatureItem: LabeledFeatureItemLike {
    let label: String
    let feature: AnyFeature
}

struct LabeledGroupItem: LabeledItem, Collection {
    typealias Element = LabeledItem
    typealias Index = Int
    typealias Iterator = IndexingIterator<LabeledGroupItem>
    typealias Indices = DefaultIndices<LabeledGroupItem>
    typealias SubSequence = Slice<LabeledGroupItem>

    let label: String

    private let features: [LabeledItem]

    init(label: String, features: [LabeledItem]) {
        self.label = label
        self.features = features
    }
}

extension LabeledGroupItem { /* Collection Support */
    var startIndex: Int { return features.startIndex }

    var endIndex: Int { return features.endIndex }

    subscript(position: Int) -> LabeledItem {
        return features[position]
    }

    func index(after i: Int) -> Int {
        return features.index(after: i)
    }
}

/// FeatureRegistry is intended to be subclassed at least once by each integration
/// of Override. The registry serves as a container for a collection of Features,
/// and performs internal wiring to ensure that features reflect correct values
/// based on the underlying data FeatureStore.
@objc open class FeatureRegistry: NSObject, FeatureProvider, FeatureExtractableByMirror {

    @objc public let featureStore: FeatureStore

    internal private(set) var features = [LabeledItem]()
    internal private(set) var featuresByKey = [String: LabeledItem]()

    // Since the feature change handler is currently completely generic,
    // we can create it one time and reuse.
    // Self here is "unowned" – because instances of features are also properties
    // of this instance (instances of this class), they are guaranteed to exist
    /// for the lifetime of self. It would be an error if a Feature property was
    /// anything other than a 'let' (readonly property).
    private lazy var featureDidChangeHandler: (BaseFeature) -> Void = { [unowned self] feature in
        self.featureStore[feature.key] = feature.override
    }

    /// Initialize, optionally providing a particular feature store. The default
    /// feature store is the `EphemeralFeatureStore`, which will not persist data
    /// across launches (in-memory only). Ephemeral store is best suited for unit
    /// testing purposes.
    ///
    /// - Parameter store: The feature store to use instead of the default
    @objc public init(withFeatureStore store: FeatureStore?) {
        if let store = store {
            featureStore = store
        } else {
            featureStore = EphemeralFeatureStore()
        }

        super.init()

        // Build the features list. This cannot be done prior to initialization due
        // to use of 'self'. We don't use 'allFeatures' directly in the public API
        // because it is a computed var, not stored one-time.
        features = featureItems

        features.forEach { labeledItem in
            if let labeledFeature = labeledItem as? LabeledFeatureItem {
                configure(featureItem: labeledFeature)
            } else if let labeledGroup = labeledItem as? LabeledGroupItem {
                configure(groupItem: labeledGroup)
            }
        }
    }

    private func configure(featureItem: LabeledFeatureItem) {
        let feature = featureItem.feature

        // Divine key from property name if required to ensure that a key
        // is always set after FeatureRegistry initialization.
        if let baseFeature = feature as? BaseFeature {
            if feature.key == nil {
                baseFeature.key = featureItem.label
            }
        } else if feature.key == nil {
            // You can make your own custom subclasses, but then you'll need to
            // also ensure that the feature key is set or defaulted, or else we
            // are going to crash very soon...
            assertionFailure("Feature key is not set, and feature is not a BaseFeature")
        }

        // Bootstrap the last saved override value, if any
        feature.override = featureStore[feature.key]

        // Install handler after setting initial override to prevent
        // it from being invoked for that initial setting
        if let baseFeature = feature as? BaseFeature {
            baseFeature.overrideChangeHandler = featureDidChangeHandler
        }
    }

    private func configure(groupItem: LabeledGroupItem) {
        groupItem.forEach { item in
            if let featureItem = item as? LabeledFeatureItem {
                configure(featureItem: featureItem)
            } else if let groupItem = item as? LabeledGroupItem {
                configure(groupItem: groupItem)
            }
        }
    }


}

internal extension Collection where Element == LabeledItem {


    /// This function recursivly traverses through the elements in it's array and returns an array of transformed objects.
    ///
    /// - Parameters:
    ///   - groupItems: Array of `LabelGroupItems` types that keeps track of the parent group items of a feature.
    ///   - resultBuilder: Configuration block for creating the return type at the end of the tree
    ///   - filter: Includes the element if the given predicate is satisfied
    func depthFirstCompactMap<T>(groupItems: [LabeledGroupItem] = [],
        resultBuilder:(([LabeledGroupItem], LabeledFeatureItem) -> T),
        filter: ((LabeledFeatureItem) -> Bool) = {_ in true }) -> [T] {

        return self.flatMap { labeledItem -> [T] in
            switch labeledItem {
            case let featureGroup as LabeledGroupItem:
                // Traverse into the group and add the group to nextGroupItems
                var nextGroupItems = groupItems
                nextGroupItems.append(featureGroup)
                return featureGroup.depthFirstCompactMap(groupItems: nextGroupItems, resultBuilder: resultBuilder, filter: filter)
            case let feature as LabeledFeatureItem where filter(feature):
                // For single items, use the result builder to create the required type
                return [resultBuilder(groupItems, feature)]
            default:
                // For any custom subclass which we don't know about, bail.
                return []
            }
        }
    }
}

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

extension FeatureRegistry {

    /// Returns the names for the enabled features in the provided registry.
    /// If a feature is embedded in a Freature Group, the group name is prepended
    /// and formatted like: "feature_group → feature_name"
    /// Primarily used for debugging.
    /// - Parameter featureRegistry: The feature registry that should be used to find enabled features
    @objc public static func enabledFeatures(in featureRegistry: FeatureRegistry) -> [String] {

        return featureRegistry.features.depthFirstCompactMap( resultBuilder: { (groupStack, feature) -> String in
            let mergedString = groupStack.map { $0.label.unCamelCased }.joined(separator: " → ")
            return mergedString.isEmpty ? feature.label.unCamelCased : mergedString + " → \(feature.label.unCamelCased)"
        }) { (featureItem) -> Bool in
            featureItem.feature.enabled
        }
    }
}
