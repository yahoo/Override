// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

protocol FeatureExtractable {
    var featureItems: [LabeledItem] { get }
}

/// A protocol for Feature containers that declares the ability
/// to return the list of Features via Swift Mirroring
protocol FeatureExtractableByMirror: FeatureExtractable {
    /// Extract all features from this instance, and it's superclass(es)
    ///
    /// - Returns: A list of feature (key,value) tuples
    func extractFeatures() -> [LabeledItem]

    /// Extract the features from a Mirror, and return them as a Feature list
    ///
    /// - Parameter mirror: The mirror to examine
    /// - Returns: A list of feature (key,value) tuples
    func extractFeatures(fromMirror mirror: Mirror) -> [LabeledItem]
}

/// Concrete extension for generic features-by-mirror extraction code
extension FeatureExtractableByMirror {
    /// Extract all features from this instance, and it's superclass(es)
    ///
    /// - Returns: A list of feature (key,value) tuples
    func extractFeatures() -> [LabeledItem] {
        var features = [LabeledItem]()

        var mirror: Mirror? = Mirror(reflecting: self)
        while let thisMirror = mirror {
            let theseFeatures = extractFeatures(fromMirror: thisMirror)
            // Combine results with accumulator
            features.append(contentsOf: theseFeatures)
            mirror = thisMirror.superclassMirror
        }

        return features
    }
}

/// Glue FeatureExtractableByMirror protocol to the FeatureExtractable protocol
extension FeatureExtractableByMirror where Self: FeatureExtractable {
    var featureItems: [LabeledItem] { return extractFeatures() }
}
