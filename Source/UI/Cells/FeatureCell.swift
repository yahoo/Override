// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import UIKit

extension String {
    var unCamelCased: String {
        return replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression, range: nil)
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
