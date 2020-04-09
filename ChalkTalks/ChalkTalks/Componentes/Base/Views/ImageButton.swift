//
//  ImageButton.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

open class ImageButton: BaseButton {

    public enum ImagePosition {
        case top
        case left
        case bottom
        case right

        case topEdge
        case leftEdge
        case bottomEdge
        case rightEdge

        case topOffset

        case rightBottom

        case leftEdgeReverse
        case rightEdgeReverse

        case leftFill
        case rightFill

        case sideToSide
        case sideToSideReverse

        case none
    }
    
    public var spacing: CGFloat
    public var position: ImagePosition
    public var imageSize: CGSize? = nil

    public init(position: ImagePosition, spacing: CGFloat) {

        self.position = position
        self.spacing = spacing

        super.init(frame: CGRect.zero)

        self.setup()
    }

    public required init?(coder aDecoder: NSCoder) {

        self.position = .left
        self.spacing = 0.0

        super.init(coder: aDecoder)

        self.setup()
    }

    open func setup() {

    }

    open override func layoutSubviews() {

        super.layoutSubviews()

        self.titleLabel?.sizeToFit()
        let labelSize = self.titleLabel?.frame.size ?? CGSize.zero
        let imageSize = self.imageSize ?? self.imageView?.frame.size ?? CGSize.zero

        let totalWidth = labelSize.width + imageSize.width + self.spacing
        let totalHeight = labelSize.height + imageSize.height + self.spacing

        var imageFrame = CGRect.zero
        var labelFrame = CGRect.zero

        switch self.position {
        case .left:
            imageFrame = CGRect(x: self.bounds.width / 2.0 - totalWidth / 2.0,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: imageFrame.maxX + self.spacing,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)

        case .right:
            labelFrame = CGRect(x: self.bounds.width / 2.0 - totalWidth / 2.0,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
            imageFrame = CGRect(x: labelFrame.maxX + self.spacing,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
        case .top:
            imageFrame = CGRect(x: self.bounds.width / 2.0 - imageSize.width / 2.0,
                                y: self.bounds.height / 2.0 - totalHeight / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: 5,
                                y: imageFrame.maxY + self.spacing,
                                width: self.bounds.width - 10,
                                height: labelSize.height)
        case .bottom:
            labelFrame = CGRect(x: 5,
                                y: self.bounds.height / 2.0 - totalHeight / 2.0,
                                width: self.bounds.width - 10,
                                height: labelSize.height)
            imageFrame = CGRect(x: self.bounds.width / 2.0 - imageSize.width / 2.0,
                                y: labelFrame.maxY + self.spacing,
                                width: imageSize.width,
                                height: imageSize.height)
        case .leftEdge:
            imageFrame = CGRect(x: 0,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: imageSize.width + self.spacing,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
        case .rightEdge:
            imageFrame = CGRect(x: self.bounds.maxX - imageSize.width,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: imageFrame.minX - self.spacing - labelSize.width,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
        case .leftEdgeReverse:
            labelFrame = CGRect(x: 0,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
            imageFrame = CGRect(x: labelFrame.width + self.spacing,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
        case .rightEdgeReverse:
            labelFrame = CGRect(x: self.bounds.maxX - labelSize.width,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
            imageFrame = CGRect(x: labelFrame.minX - self.spacing - imageSize.width,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
        case .topEdge:
            imageFrame = CGRect(x: self.bounds.width / 2.0 - imageSize.width / 2.0,
                                y: 0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: 5,
                                y: imageSize.height + self.spacing,
                                width: self.bounds.width - 10,
                                height: labelSize.height)
        case .bottomEdge:
            labelFrame = CGRect(x: 5,
                                y: self.bounds.height - imageSize.height - labelSize.height - self.spacing,
                                width: self.bounds.width - 10,
                                height: labelSize.height)
            imageFrame = CGRect(x: self.bounds.width / 2.0 - imageSize.width / 2.0,
                                y: self.bounds.height - imageSize.height,
                                width: imageSize.width,
                                height: imageSize.height)
        case .topOffset:
            imageFrame = CGRect(x: self.bounds.width / 2.0 - imageSize.width / 2.0,
                                y: self.spacing,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: 5,
                                y: self.bounds.height - labelSize.height - 2,
                                width: self.bounds.width - 10,
                                height: labelSize.height)
        case .rightBottom:
            labelFrame = CGRect(x: self.bounds.width / 2.0 - totalWidth / 2.0,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
            imageFrame = CGRect(x: labelFrame.maxX,
                                y: self.bounds.height - imageSize.height - self.spacing,
                                width: imageSize.width,
                                height: imageSize.height)
        case .leftFill:
            imageFrame = CGRect(x: 0,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: imageSize.width + self.spacing,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: self.bounds.width - imageSize.width - self.spacing,
                                height: labelSize.height)
        case .rightFill:
            imageFrame = CGRect(x: self.bounds.maxX - imageSize.width,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: 0,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: self.bounds.width - imageSize.width - self.spacing,
                                height: labelSize.height)
        case .sideToSide:
            imageFrame = CGRect(x: 0,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: self.bounds.width - labelSize.width,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
        case .sideToSideReverse:
            imageFrame = CGRect(x: self.bounds.width - imageSize.width,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: 0,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
        default:
            return
        }

        self.titleLabel?.frame = labelFrame
        self.imageView?.frame = imageFrame
    }

    open func rotateUp() {

        guard let imageView = imageView else { return }

        UIView.animate(withDuration: 0.3) {
            imageView.transform = CGAffineTransform.identity
        }
    }

    open func rotateDown() {

        guard let imageView = imageView else { return }

        UIView.animate(withDuration: 0.3) {
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
}
