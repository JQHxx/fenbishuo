//
//  ReddotView.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

final class ReddotView: UIView {
    
    enum DotType {
        
        case tabbar, normal, invite
        
        var size: CGSize {
            switch self {
            case .tabbar:
                return CGSize(width: 9, height: 9)
            case .normal:
                return CGSize(width: 6, height: 6)
            case .invite:
                return CGSize(width: 6, height: 6)
            }
        }
    }
    
    convenience init(_ type: DotType) {
        self.init(frame: CGRect(origin: .zero, size: type.size))
        backgroundColor = .red
        layer.cornerRadius = type.size.height / 2
    }
}
