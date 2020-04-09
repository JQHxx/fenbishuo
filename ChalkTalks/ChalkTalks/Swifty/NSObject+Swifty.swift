//
//  NSObject+Swifty.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import Foundation

extension SwiftyCore where Base: NSObject {

    @discardableResult
    public func prepare(_ handler: ((_ obj: Base) -> Void)) -> Base {
        handler(self.base)
        return self.base
    }
}

extension SwiftyCore where Base: NSObject {

    public static var className: String {
        return "\(Base.self)"
    }

    public var className: String {
        return "\(type(of: self.base))"
    }
}
