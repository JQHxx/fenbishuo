//
//  UIColor+Extensions.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

extension UIColor {

    public convenience init(hred: Int, hgreen: Int, hblue: Int, alpha: CGFloat = 1.0) {
        assert(hred >= 0 && hred <= 255, "Invalid red component")
        assert(hgreen >= 0 && hgreen <= 255, "Invalid green component")
        assert(hblue >= 0 && hblue <= 255, "Invalid blue component")
        assert(alpha >= 0.0 && alpha <= 1.0, "Invalid alpha component")

        self.init(red: CGFloat(hred) / 255.0,
                  green: CGFloat(hgreen) / 255.0,
                  blue: CGFloat(hblue) / 255.0,
                  alpha: CGFloat(alpha))
    }

    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(hred: (hex >> 16) & 0xFF,
                  hgreen: (hex >> 8) & 0xFF,
                  hblue: hex & 0xFF,
                  alpha: alpha)
    }

    public convenience init(_ rgba: UInt32) {
        self.init(
            hred: Int(rgba >> 24) & 0xFF,
            hgreen: Int(rgba >> 16) & 0xFF,
            hblue: Int(rgba >> 8) & 0xFF,
            alpha: CGFloat(rgba & 0xFF) / 255.0
        )
    }
}
