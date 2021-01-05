// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

public enum DynamicFeatureRegistryError: Error {
    case staticFeatureAlreadyExists
}

/// DynamicFeatureRegistry a subclass of FeatureRegistry which provides an interface for using
/// a collection of dynamic features instead of just pre-defined ones. When a feature is added,
/// there is an attempt to apply an override state from the underlying data FeatureStore.
@objc open class DynamicFeatureRegistry: FeatureRegistry {

    /// A local store of the current dynamic features
    private var dynamicFeatures: [String : AnyFeature] = [:]

    override var features: [LabeledItem] {

        let dynamicLabeledItems = dynamicFeatures.values.map {
            LabeledFeatureItem(label: $0.key, feature: $0)
        }
        let staticFeatures = super.features
        /// merge both dynamic and static features
        let allFeatures = staticFeatures + dynamicLabeledItems
        return allFeatures
    }

    /// This method is used to add a dynamic feature to the store. It will attempt to
    /// assign an `override` value from the FeatureStore if it was previously set and then stores it
    /// locally for future use.
    ///
    /// - Parameter feature: A new feature to add to the store
    /// - Parameter forced: When `true`, if the provided feature conflicts with an already stored dynamic feature, it will
    /// replace that feature in the store. If `false`, the new feature is ignored. Default value is `false`.
    /// - Throws: If the provided feature conflicts with an already defined static feature, an exemption will be thrown and
    /// it will not be added.
    public func add(feature: AnyFeature, forced: Bool = false) throws {

        /// We can't add a dynamic feature which conflicts which conflicts with a static one.
        guard !(super.features.contains(where: { return $0.label == feature.key })) else {
            throw DynamicFeatureRegistryError.staticFeatureAlreadyExists
        }
        /// If the feature is already stored and `forced` is `false`, there is no reason to contine
        guard dynamicFeatures[feature.key] == nil || forced else { return }

        /// Bootstrap the last saved override value, if any
        feature.override = featureStore[feature.key]

        /// Store feature in `dynamicFeatures`
        dynamicFeatures[feature.key] = feature

        if let baseFeature = feature as? BaseFeature {
            baseFeature.overrideChangeHandler = featureDidChangeHandler
            baseFeature.overrideChangeHandler = {[weak self] feature in
                guard let self = self else { return }
                self.featureStore[feature.key] = feature.override
            }
        }
    }

    /// Provides an interface for retrieving a dynamic feature. If no matching features are found, this returns nil.
    /// - Parameter key: The key used to store the feature
    /// - Returns: The dynamic feature which matches the provided key.
    public func dynamicFeature(with key: String) -> AnyFeature? {
        return dynamicFeatures[key]
    }
}
