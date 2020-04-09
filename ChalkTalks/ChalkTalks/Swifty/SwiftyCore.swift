//
//  SwiftyCore.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import Foundation

/// Swift Style
public class SwiftyCore<Base> {

    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

public protocol SwiftyCoreCompatible {

    associatedtype CompatibleType

    static var ss: SwiftyCore<CompatibleType>.Type { get set }

    var ss: SwiftyCore<CompatibleType> { get set }
}

extension SwiftyCoreCompatible {

    public static var ss: SwiftyCore<Self>.Type {
        get {
            return SwiftyCore<Self>.self
        }
        set {
        }
    }

    public var ss: SwiftyCore<Self> {
        get {
            return SwiftyCore(self)
        }
        set {
        }
    }
}

extension NSObject: SwiftyCoreCompatible {}
