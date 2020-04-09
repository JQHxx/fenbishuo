//
//  MessageHeaderView.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class MessageHeaderView: BaseView {
    
    static let height: CGFloat = 118
    
    fileprivate var _offsetRate: CGFloat = 0
    fileprivate var _xMargin: CGFloat = 0
    
    var tapEvent: PublishSubject<Int> = PublishSubject<Int>()
    
    var buttons: [MessageReddotButton] = []
    
    override func setup() {
        super.setup()

        clipsToBounds = true
        backgroundColor = .white
        
        let width: CGFloat = 44.0
        let height: CGFloat = 72.0
        let topMargin: CGFloat = 16.0
        let count = CGFloat(MessageType.allCases.count)
        let spacing = (Utils.screenPortraitWidth - count * width) / count
        var x = spacing / 2
        _xMargin = x + width / 2
        for (idx, type) in MessageType.allCases.enumerated() {
            let button = MessageReddotButton(type)
            button.frame = CGRect(x: x, y: topMargin, width: width, height: height)
            button.rx.tap.map({ idx }).bind(to: tapEvent).disposed(by: disposeBag)
            x += spacing + width
            addSubview(button)
            buttons.append(button)
        }
        buttons.first?.setTitleColor(UIColor(0xFF6885FF), for: .normal)
    }
    
    func needRedrawLine(_ offsetRate: CGFloat) {
        _offsetRate = offsetRate
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)

        let color = UIColor(0xEEEEEEFF).cgColor
        context.setStrokeColor(color)
        context.setFillColor(color)
        
        let width = Utils.splitWidth * 2
        let offset = width / 2
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        let centerDot: CGFloat = _xMargin + (Utils.screenPortraitWidth - _xMargin * 2) * _offsetRate
        context.move(to: CGPoint(x: 0, y: rect.maxY - offset))
        context.addLine(to: CGPoint(x: centerDot - 10, y: rect.maxY - offset))
        context.addLine(to: CGPoint(x: centerDot, y: rect.maxY - offset - 10))
        context.addLine(to: CGPoint(x: centerDot + 10, y: rect.maxY - offset))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - offset))

        context.drawPath(using: .stroke)

        context.strokePath()

        UIGraphicsPopContext()
    }
}
