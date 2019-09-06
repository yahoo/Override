// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

extension String {

    /// Concert camel cased strings "newURLFormatHere" into seperate words "New URL Format Here"
    var unCamelCased: String {
        // Split camel-cased string into words at each "hump"
        // "newURLFormat" -> "new URLFormat"
        let phase1 = replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression, range: nil)
        // Split words that appear connected to abbreviations
        // "new URLFormat" -> "new URL Format"
        let phase2 = phase1.replacingOccurrences(of: "([A-Z]+)([A-Z][a-z])", with: "$1 $2", options: .regularExpression, range: nil)
        // Capitalize the first letter
        // "new URL Format" -> "New URL Format"
        return phase2.prefix(1).uppercased() + phase2.dropFirst()
    }
}

class FeatureTableViewCell: UITableViewCell {

    // Lumping all of the pre- and post-4.2 name changes into a single spot.
    #if swift(>=4.2)
    typealias TableViewCellStyle = UITableViewCell.CellStyle
    typealias FontTextStyle = UIFont.TextStyle
    #else
    typealias TableViewCellStyle = UITableViewCellStyle
    typealias FontTextStyle = UIFontTextStyle
    #endif

    override init(style: TableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let font = UIFont.systemFont(ofSize: 30, weight: .medium)
        if #available(iOS 11, tvOS 11, *) {
            textLabel?.font = UIFontMetrics(forTextStyle: FontTextStyle.body).scaledFont(for: font)
        } else {
            textLabel?.font = font
        }
        textLabel?.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
}
