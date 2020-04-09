//
//  UILabel+Extensions.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/17.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// 中文两端对齐文本
    var cnText: String? {
        set {
            guard let value = newValue else {
                attributedText = nil
                text = nil
                return
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .justified
            paragraphStyle.lineSpacing = 2
            
            let attrString = NSAttributedString(
                string: value,
                attributes: [
                    NSAttributedString.Key.foregroundColor: self.textColor!,
                    NSAttributedString.Key.font: self.font!,
//                    NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.baselineOffset: 0,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
            ])
            
            attributedText = attrString
        }
        get {
            return attributedText?.string
        }
    }
}

extension String {
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
