// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

/// DynamicFeatureRegistry a subclass of FeatureRegistry which provides an interface for using
/// a collection of dynamic features instead of just pre-defined ones. When a feature is added,
/// there is an attempt to apply an override state from the underlying data FeatureStore.
@objc open class DynamicFeatureRegistry: FeatureRegistry {

    /// A local store of the current dynamic features
    private var dynamicFeatures: [String : AnyFeature] = [:]

    override var features: [LabeledItem] {
        let dynamicLabeledItems = dynamicFeatures.values.reduce(into: []) { (result, feature) in
            result.append(LabeledFeatureItem(label: feature.key, feature: feature))
        }
        let staticFeatures = super.features
        /// merge both dynamic and static features
        let allFeatures = dynamicLabeledItems + staticFeatures
        return allFeatures
    }

    /// This method is used to configure and store a dynamic feature. It will attempt to
    /// assign an `override` value from the FeatureStore if it was previously set and then stores it
    /// locally for future use.
    /// - Parameter feature: A new feature
    /// - Returns: The configured feature
    public func configureDynamicFeature(feature: AnyFeature) -> AnyFeature {
        // Bootstrap the last saved override value, if any
        feature.override = featureStore[feature.key]

        // Store feature in `dynamicFeatures` if needed.
        if dynamicFeatures[feature.key] == nil {
            dynamicFeatures[feature.key] = feature
        }

        if let baseFeature = feature as? BaseFeature {
            baseFeature.overrideChangeHandler = featureDidChangeHandler
            baseFeature.overrideChangeHandler = {[unowned self] feature in
                self.featureStore[feature.key] = feature.override
            }
        }
        return feature
    }
}
