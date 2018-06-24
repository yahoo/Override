// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

class FeatureSwitchCell: FeatureTableViewCell {

    // Lumping all of the pre- and post-4.2 name changes into a single spot.
    #if swift(>=4.2)
    typealias AttributedStringKey = NSAttributedString.Key
    let underlineStyleSingle = NSUnderlineStyle.single
    #else
    typealias AttributedStringKey = NSAttributedStringKey
    let underlineStyleSingle = NSUnderlineStyle.styleSingle
    #endif

    var labeledFeature: LabeledFeatureItem? {
        didSet {
            guard let feature = labeledFeature?.feature,
                let label = labeledFeature?.label,
                let textLabel = textLabel
                else { return }

            let labelColor = feature.enabled ? UIColor.mulah : UIColor.swedishFish

            let labelString = NSMutableAttributedString(string: label.unCamelCased.capitalized)
            var attrs: [AttributedStringKey: Any] = [
                AttributedStringKey.font: textLabel.font,
                AttributedStringKey.foregroundColor: labelColor
            ]

            // add emphasis if this is locally overridden by underlining the label
            if feature.override != .featureDefault {
                attrs[AttributedStringKey.underlineStyle] = underlineStyleSingle.rawValue
                attrs[AttributedStringKey.underlineColor] = labelColor
            }
            labelString.addAttributes(attrs, range: NSRange(location: 0, length: labelString.length))

            textLabel.attributedText = labelString

            self.setNeedsLayout()
        }
    }
}
