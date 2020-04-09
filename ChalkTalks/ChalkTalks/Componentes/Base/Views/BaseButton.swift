//
//  BaseButton.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

open class BaseButton: UIButton {
    
    public var hitTestInset: UIEdgeInsets? = nil
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        if let inset = self.hitTestInset {
            return self.bounds.inset(by: inset).contains(point)
        }

        return super.point(inside: point, with: event)
    }
}
