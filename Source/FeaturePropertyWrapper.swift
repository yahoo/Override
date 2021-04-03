// Copyright 2021, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation

@propertyWrapper public struct Feature1 {

    public var wrappedValue: Bool {
        return projectedValue.enabled
    }

    public let projectedValue: Feature

    public init() {
        projectedValue = Feature()
    }

    public init(wrappedValue: Bool) {
        projectedValue = Feature(requiresRestart: false, defaultState: wrappedValue)
    }

    public init(wrappedValue: Bool, key: String?, requiresRestart: Bool = false, defaultState: Bool = false) {
        projectedValue = Feature(key: key, requiresRestart: requiresRestart, defaultState: defaultState)
    }
}
