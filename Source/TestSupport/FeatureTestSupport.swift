// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import YMOverride

@objc public class FeatureTestSupport: NSObject {

    let features: [BaseFeature]

    @objc public init(_ features: [BaseFeature]) {
        self.features = features
    }

    @objc public var enabled: (() -> Void) -> Void {
        return { block in
            self.runWithState(state: .enabled, block)
        }
    }

    @objc public var disabled: (() -> Void) -> Void {
        return { block in
            self.runWithState(state: .disabled, block)
        }
    }

    func runWithState(state: OverrideState, _ block: () -> Void) {
        let originalStates = features.map { $0.override }
        defer {
            let originalStates = zip(features, originalStates).map { $0.override = $1 }
        }

        features.forEach { $0.override = state }
        block()
    }
}

public func withFeature(_ feature: BaseFeature) -> FeatureTestSupport {
    return withFeatures([feature])
}

public func withFeatures(_ features: [BaseFeature]) -> FeatureTestSupport {
    return FeatureTestSupport(features)
}
