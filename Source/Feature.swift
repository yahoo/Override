// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

internal typealias FeatureOverrideHandler = (_ feature: AnyFeature, _ oldState: OverrideState) -> Void

@objc public enum OverrideState: Int, CaseIterable, CustomDebugStringConvertible {
    case featureDefault
    case disabled
    case enabled

    public var debugDescription: String { description }

    var description: String {
        switch self {
        case .featureDefault:
            return "Default"
        case .enabled:
            return "ON"
        case .disabled:
            return "OFF"
        }
    }

    static func fromString(_ str: String) -> OverrideState {
        switch str {
        case "ON":
            return .enabled
        case "OFF":
            return .disabled
        default:
            return .featureDefault
        }
    }
}

@objc public protocol AnyFeature: NSObjectProtocol {
    var key: String! { get }

    var requiresRestart: Bool { get }

    var defaultState: Bool { get }

    var enabled: Bool { get }

    var override: OverrideState { get set }
}

extension AnyFeature {
    public var hash: Int { return self.key.hashValue }
}

@objc public protocol ComputedDefaultState: NSObjectProtocol {
    var computedDefaultState: (_ feature: AnyFeature) -> Bool { get }
}

@objc open class BaseFeature: NSObject, AnyFeature {

    @objc public internal(set) var key: String!

    @objc public let requiresRestart: Bool

    @objc internal let underlyingDefaultState: Bool

    /// defaultState is a stored referencing a static variable to preserve the
    /// ability of subclass implementations to override with a computed value
    @objc public var defaultState: Bool { return self.underlyingDefaultState }

    @objc public var enabled: Bool {
        switch override {
        case .enabled:
            return true
        case .disabled:
            return false
        case .featureDefault:
            return defaultState
        }
    }

    @objc public dynamic var override: OverrideState = .featureDefault {
        didSet {
            self.overrideChangeHandler?(self)
        }
    }

    @objc internal var overrideChangeHandler: ((_ feature: BaseFeature) -> Void)?

    @objc init(key: String?, requiresRestart: Bool, defaultState: Bool) {
        self.key = key
        self.requiresRestart = requiresRestart
        self.underlyingDefaultState = defaultState
    }
}

@objc open class Feature: BaseFeature {
    @objc override open var description: String {
        let enabledString = enabled ? "ON" : "OFF"
        return "\(key ?? "UNKNOWN"):[\(enabledString)] - Override: \(override.description), Default: \(defaultState)"
    }

    @objc public convenience init(requiresRestart: Bool = false, defaultState: Bool = false) {
        self.init(key: nil, requiresRestart: requiresRestart, defaultState: defaultState)
    }

    @objc public override init(key: String?, requiresRestart: Bool = false, defaultState: Bool = false) {
        super.init(key: key, requiresRestart: requiresRestart, defaultState: defaultState)
    }
}

@objc open class DynamicFeature: BaseFeature, ComputedDefaultState {

    @objc public private(set) var computedDefaultState: (_ feature: AnyFeature) -> Bool

    @objc public override var defaultState: Bool {
        return computedDefaultState(self)
    }

    @objc public init(key: String? = nil,
                      requiresRestart: Bool = false,
                      computedDefault: @escaping (_ feature: AnyFeature) -> Bool) {
        self.computedDefaultState = computedDefault
        super.init(key: key, requiresRestart: requiresRestart, defaultState: false)
    }
}

// SWIFT-ONLY VERSION
//
// Below are version of Feature and DynamicFeature built entirely in Swift. This
// Allow for a very elegant solution where the default implementations are provided
// via Protocol extensions, and classes formed using Protocol composition.
// ...however are not compatible with Objective-C due to use of protocol extensions.

/*
public protocol AnyFeature: class, CustomStringConvertible, CustomDebugStringConvertible {
    var key: String { get }
    
    var requiresRestart: Bool { get }
    
    var defaultState: Bool { get }
    
    var enabled: Bool { get }
    
    var override: OverrideState { get set }
}

public protocol ComputedDefaultState {
    var computedDefaultState: (_ feature: AnyFeature) -> Bool { get }
}
 
public extension AnyFeature {
    var enabled: Bool {
        switch override {
        case .on:
            return true
        case .off:
            return false
        case .featureDefault:
            return defaultState
        }
    }

    var description: String { return debugDescription }

    var debugDescription: String {
        let enabledString = enabled ? "ON" : "OFF"
        return "\(key):[\(enabledString)] - Override: \(override.description), Default: \(defaultState)"
    }
}
public extension AnyFeature where Self: ComputedDefaultState {
    var defaultState: Bool {
        return computedDefaultState(self)
    }
}

public class DynamicFeature: AnyFeature, ComputedDefaultState {

    public let computedDefaultState: (_ feature: AnyFeature) -> Bool

    public var override: OverrideState = .featureDefault

    public let key: String

    public let requiresRestart: Bool

    public init(key: String, requiresRestart: Bool = false, defaultState: @escaping (_ feature: AnyFeature) -> Bool) {
        self.key = key
        self.requiresRestart = requiresRestart
        self.computedDefaultState = defaultState
    }
}

public class Feature: AnyFeature {

    public let defaultState: Bool

    public var override: OverrideState = .featureDefault

    public let key: String

    public let requiresRestart: Bool

    public init(key: String, requiresRestart: Bool = false, defaultState: Bool = false) {
        self.key = key
        self.requiresRestart = requiresRestart
        self.defaultState = defaultState
    }
}
*/
