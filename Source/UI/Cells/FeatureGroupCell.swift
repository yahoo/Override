// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

class FeatureGroupCell: FeatureTableViewCell {

    // Lumping all of the pre- and post-4.2 name changes into a single spot.
    #if swift(>=4.2)
    typealias AttributedStringKey = NSAttributedString.Key
    let underlineStyleSingle = NSUnderlineStyle.single
    #else
    typealias AttributedStringKey = NSAttributedStringKey
    let underlineStyleSingle = NSUnderlineStyle.styleSingle
    #endif

    var labeledGroup: LabeledGroupItem? {
        didSet {
            guard let label = labeledGroup?.label,
                let textLabel = textLabel
                else { return }

            let labelString = NSMutableAttributedString(string: label.unCamelCased.capitalized)
            let attrs: [AttributedStringKey: Any] = [
                AttributedStringKey.font: textLabel.font,
                AttributedStringKey.foregroundColor: UIColor.darkGray
            ]
            labelString.addAttributes(attrs, range: NSRange(location: 0, length: labelString.length))

            textLabel.attributedText = labelString

            self.setNeedsLayout()
        }
    }

    override init(style: TableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
