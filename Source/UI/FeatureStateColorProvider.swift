// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

/// A container for feature state colors
@objc public class FeatureStateColors: NSObject {
    @objc public let enabledColor: UIColor
    @objc public let disabledColor: UIColor

    @objc public init(enabledColor: UIColor, disabledColor: UIColor) {
        self.enabledColor = enabledColor
        self.disabledColor = disabledColor
        super.init()
    }

    @objc public static let defaultStateColors: FeatureStateColors = {
        FeatureStateColors(enabledColor: .mulah, disabledColor: .swedishFish)
    }()
}

/// A protocol for providing colors based on feature state.
/// Implement this protocol to customize colors for enabled and disabled feature states.
@objc public protocol FeatureStateColorProvider: NSObjectProtocol {
    /// Returns the colors to use for a given feature's enabled and disabled states.
    ///
    /// - Parameter feature: The feature to resolve colors for
    /// - Returns: A FeatureStateColors object containing the enabled color and disabled color
    func colors(for feature: AnyFeature) -> FeatureStateColors
}

/// Default implementation that uses the standard mulah (green) and swedishFish (red) colors.
@objc public class DefaultFeatureStateColorProvider: NSObject, FeatureStateColorProvider {
    @objc public override init() {
        super.init()
    }
    
    @objc public func colors(for feature: AnyFeature) -> FeatureStateColors {
        FeatureStateColors.defaultStateColors
    }
}

/// Adapter that allows using a closure as a FeatureStateColorProvider
public class ClosureFeatureStateColorProvider: NSObject, FeatureStateColorProvider {
    private let resolver: (AnyFeature) -> FeatureStateColors

    public init(_ resolver: @escaping (AnyFeature) -> FeatureStateColors) {
        self.resolver = resolver
        super.init()
    }

    public func colors(for feature: AnyFeature) -> FeatureStateColors {
        return resolver(feature)
    }
}
