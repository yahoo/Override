// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

// MARK: - Internal FeatureRegistry Support Wrappers
protocol LabeledItem {
    var label: String { get }
}

protocol LabeledFeatureItemLike: LabeledItem {
    var feature: AnyFeature { get }
}

struct LabeledFeatureItem: LabeledFeatureItemLike, CustomStringConvertible {
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

extension LabeledFeatureItemLike where Self: CustomStringConvertible {
    var description: String {
        let onOff = feature.enabled ? "ON" : "OFF"
        let reason = feature.override == .featureDefault ? "default" : "override"
        return "\(label.unCamelCased) [\(onOff) by \(reason)]"
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

// MARK: – Feature Registry

/// FeatureRegistry is intended to be subclassed at least once by each integration
/// of Override. The registry serves as a container for a collection of Features,
/// and performs internal wiring to ensure that features reflect correct values
/// based on the underlying data FeatureStore.
@objc open class FeatureRegistry: NSObject, FeatureProvider, FeatureExtractableByMirror {

    @objc public let featureStore: FeatureStore

    // Build the features list. This cannot be done prior to initialization due
    // to use of 'self'. We don't use 'allFeatures' directly in the public API
    // because it is a computed var, not stored one-time.
    internal private(set) lazy var features = featureItems
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

// MARK: Feature Tree Traversal
extension Collection where Element == LabeledItem {
    /// This function recursivly traverses through the elements in it's array and returns an array of transformed objects.
    ///
    /// - Parameters:
    ///   - groupItems: Array of `LabelGroupItems` types that keeps track of the parent group items of a feature.
    ///   - resultBuilder: Configuration block for creating the return type at the end of the tree
    ///   - filter: Includes the element if the given predicate is satisfied
    internal func depthFirstCompactMap<T>(groupItems: [LabeledGroupItem] = [],
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

    private func flattenedDescription(enabled: Bool? = nil, overrideStates: [OverrideState]? = nil) -> [String] {
        let overrideStateSet = Set(overrideStates ?? [])

        return depthFirstCompactMap(resultBuilder: { (groupStack, feature) -> String in
            let mergedString = groupStack.map { $0.label.unCamelCased }.joined(separator: " → ")
            return mergedString.isEmpty ? feature.description : "\(mergedString) → \(feature)"
        }) { (featureItem) -> Bool in
            // If enabled flag was provided, filter out non-matches
            if let enabled = enabled, featureItem.feature.enabled != enabled {
                return false
            }

            // If override state was provided, filter out non-matches
            return overrideStates == nil || overrideStateSet.contains(featureItem.feature.override)
        }
    }

    /// Returns the names for the enabled features in the provided list.
    /// If a feature is embedded in a Freature Group, the group name is prepended
    /// and formatted like: "feature_group → feature_name"
    var enabledFeaturesDescription: [String] {
        return flattenedDescription(enabled: true)
    }

    /// Returns the names for the disabled features in the provided list.
    /// If a feature is embedded in a Freature Group, the group name is prepended
    /// and formatted like: "feature_group → feature_name"
    var disabledFeaturesDescription: [String] {
        return flattenedDescription(enabled: false)
    }

    /// Returns the names for any locally overridden features in the provided list.
    /// If a feature is embedded in a Freature Group, the group name is prepended
    /// and formatted like: "feature_group → feature_name"
    var overriddenFeaturesDescription: [String] {
        return flattenedDescription(overrideStates: [ .enabled, .disabled ])
    }

    /// Returns the names for all features in the provided list.
    /// If a feature is embedded in a Freature Group, the group name is prepended
    /// and formatted like: "feature_group → feature_name"
    var featuresDescription: [String] {
        return flattenedDescription()
    }
}
