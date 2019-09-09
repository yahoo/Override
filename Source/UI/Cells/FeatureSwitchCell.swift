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

            let labelString = NSMutableAttributedString(string: label.unCamelCased)
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

    var featurePath: [LabeledGroupItem]? {
        didSet {
            guard let featurePath = featurePath,
                let detailLabel = self.detailTextLabel
                else { return }

            let mergedString = featurePath.map { $0.label.unCamelCased }.joined(separator: " → ")

            let labelString = NSMutableAttributedString(string: mergedString)
            let attrs: [AttributedStringKey: Any] = [
                AttributedStringKey.font: detailLabel.font,
                AttributedStringKey.foregroundColor: UIColor.lightGray
            ]

            labelString.addAttributes(attrs, range: NSRange(location: 0, length: labelString.length))

            detailLabel.attributedText = labelString

            self.setNeedsLayout()
        }
    }

    override func prepareForReuse() {
        self.detailTextLabel?.attributedText = nil
        self.textLabel?.attributedText = nil
        super.prepareForReuse()
    }

    override init(style: TableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
