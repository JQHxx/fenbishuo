//
//  UIViewController+Extensions.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @objc open var topVC: UIViewController {

        if let vc = self.presentedViewController {

            return vc.topVC

        } else if self.isKind(of: UITabBarController.self), let vc = (self as! UITabBarController).selectedViewController {

            return vc.topVC

        } else if self.isKind(of: UINavigationController.self), let vc = (self as! UINavigationController).visibleViewController {

            return vc.topVC
        }

        return self
    }
}
