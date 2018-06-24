// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

/// Protocol for a generic Feature state store
@objc public protocol FeatureStore {
    subscript(key: String) -> OverrideState { get set }
}

/// A Feature store that uses UserDefaults.standard to store state
@objc open class UserDefaultsFeatureStore: NSObject, FeatureStore {

    /// The prefix to use to safely scope any keys in the data store. The default
    /// value is "Override_".
    @objc public let prefix: String

    @objc public let userDefaults: UserDefaults

    @objc open func prefixed(_ key: String) -> String {
        return prefix.appending(key)
    }

    @objc open subscript(key: String) -> OverrideState {
        get {
            guard let stateStr = UserDefaults.standard.string(forKey: prefixed(key))
            else { return .featureDefault }

            return OverrideState.fromString(stateStr)
        }

        set(newValue) {
            UserDefaults.standard.set(newValue.description, forKey: prefixed(key))
        }
    }

    /// Initialize this data store, optionally providing a custom key prefix
    ///
    /// - Parameter userDefaults: the user defaults store to use, defaulting to standard user defaults
    /// - Parameter prefix: A string to prepend to all keys prior to any database
    ///   operations. The default value is "Override_", which means a Feature with
    ///   the key "myFeature" would be stored in UserDefaults as "Override_myFeature".

    @objc public init(withUserDefaults userDefaults: UserDefaults = UserDefaults.standard,
                      withKeyPrefix prefix: String = "Override_") {
        self.prefix = prefix
        self.userDefaults = userDefaults
    }

    @objc public convenience init(withKeyPrefix prefix: String = "Override_") {
        self.init(withUserDefaults: UserDefaults.standard, withKeyPrefix: prefix)
    }
}

/// A simple Feature state store backed by a dictionary. The values are not
/// persisted across launches of the app.
@objc public class EphemeralFeatureStore: NSObject, FeatureStore {

    var states = [String: String]()

    @objc public subscript(key: String) -> OverrideState {
        get {
            guard let stateStr = states[key] as String?
                else { return .featureDefault }
            return OverrideState.fromString(stateStr)
        }

        set(newValue) {
            states[key] = newValue.description
        }
    }
}
