// Copyright 2021, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

protocol AnyFeatureFlag {
    var projectedValue: AnyFeature { get }
}

/// Property wrapper for declaring a Feature.
///
/// Here is how some Feature declarations could be represented using FeatureFlag:
/// ```
/// let flag1 = Feature()
/// @FeatureFlag var flag1
///
/// let flag2 = Feature(defaultState: true)
/// @FeatureFlag var flag2 = true
///
/// let flag3 = Feature(requiresRestart: true)
/// @FeatureFlag(requiresRestart: true) flag3
///
/// let flag4 = Feature(key: "awesome-flag-key")
/// @FeatureFlag(key: "awesome-flag-key") flag4
///
/// let flag5 = Feature(requiresRestart: false, defaultState: true)
/// @FeatureFlag(requiresRestart: false) flag5 = true
/// ```
@propertyWrapper public struct FeatureFlag: AnyFeatureFlag {

    public var wrappedValue: Bool {
        return projectedValue.enabled
    }

    public let projectedValue: AnyFeature

    public init() {
        projectedValue = Feature()
    }

    public init(wrappedValue: Bool) {
        projectedValue = Feature(requiresRestart: false, defaultState: wrappedValue)
    }

    public init(wrappedValue: Bool = false, key: String? = nil, requiresRestart: Bool = false, defaultState: Bool = false) {
        projectedValue = Feature(key: key, requiresRestart: requiresRestart, defaultState: defaultState)
    }
}

/// Property wrapper for declaring a DyanmicFeature.
///
/// This property wrapper does not permit assigning an intitial value. See Rationale below
/// for details.
///
/// Here is how some DynamicFeature declarations could be represented using DynamicFeatureFlag:
/// ```
/// let flag1 = DynamicFeature(computedDefault: { _ in false })
/// @DynamicFeatureFlag({ _ in false }) var flag1
///
/// let flag2 = DynamicFeature(computedDefault: { _ in false })
/// @DynamicFeatureFlag(requiresRestart: true, { _ in false }) var flag2
///
/// let flag3 = DynamicFeature(computedDefault: { _ in false })
/// @DynamicFeatureFlag({ _ in false }) var flag3
///
/// // THIS ONE DOES NOT WORK:
/// let flag4 = DynamicFeature(computedDefault: { _ in false })
/// @DynamicFeatureFlag var flag4 = { _ in false }
/// ```
///
/// Rationale: The type of wrappedValue (bool) must match the initial value
/// set to the property when it is initialized as a instance variable. For example:
/// `@DynamicFeatureFlag var myFlag = false`
/// However since the default value of a DynamicFeature cannot by defintion be
/// determined at initialization time, this format falls apart when we try to provide
/// the closure that DynamicFeature requires. Hence this:
/// `let myFlag = DynamicFeature  { _ in /* work... */ true }`
/// does not equal:
/// `@DynamicFeatureFlag var myFlag = { _ in /* work... */ true }`
/// since `myFlag`'s wrappedValue will be typed to `(AnyFeature) -> Bool` vs `Bool`.
@propertyWrapper public struct DynamicFeatureFlag: AnyFeatureFlag {

    public var wrappedValue: Bool {
        return projectedValue.enabled
    }

    public let projectedValue: AnyFeature

    public init(_ computedDefault: @escaping (_ feature: AnyFeature) -> Bool) {
        projectedValue = DynamicFeature(computedDefault: computedDefault)
    }

    public init(key: String? = nil, requiresRestart: Bool = false,
                computedDefault: @escaping (_ feature: AnyFeature) -> Bool) {
        projectedValue = DynamicFeature(key: key, requiresRestart: requiresRestart, computedDefault: computedDefault)
    }
}
