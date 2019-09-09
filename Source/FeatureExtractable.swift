// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

protocol FeatureProvider {
    var featureItems: [LabeledItem] { get }
}

/// A protocol for Feature containers that declares the ability
/// to return the list of Features via Swift Mirroring
protocol FeatureExtractableByMirror {
    /// Extract the features from a Mirror, and return them as a Feature list
    ///
    /// - Parameter mirror: The mirror to examine
    /// - Returns: A list of feature (key,value) tuples
    func extractFeatures(fromMirror mirror: Mirror) -> [LabeledItem]
}

/// Concrete extension for generic features-by-mirror extraction code
extension FeatureProvider where Self: FeatureExtractableByMirror {

    var featureItems: [LabeledItem] { return extractFeatures() }

    /// Extract all features from this instance, and it's superclass(es)
    ///
    /// - Returns: A list of feature (key,value) tuples
    //func extractFeatures() -> [LabeledItem]

    /// Extract all features from this instance, and it's superclass(es)
    ///
    /// - Returns: A list of feature (key,value) tuples
    private func extractFeatures() -> [LabeledItem] {
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

    func extractFeatures(fromMirror mirror: Mirror) -> [LabeledItem] {
        return mirror.children.reduce(into: [LabeledItem]()) { (allFeatures, child) in
            guard case let (labelOpt, rawValue) = child,
                let label = labelOpt
                else { return }

            switch rawValue {
            case let feature as AnyFeature:
                //print("Loading feature \(label): \(feature)")
                allFeatures.append(LabeledFeatureItem(label: label, feature: feature))
            case let featureGroup as FeatureGroup:
                //print("Loading feature group: \(label)")
                let groupFeatures = featureGroup.extractFeatures()
                allFeatures.append(LabeledGroupItem(label: label, features: groupFeatures))
            default:
                //print("Skipping property: \(label)")
                return
            }
        }
    }
}
