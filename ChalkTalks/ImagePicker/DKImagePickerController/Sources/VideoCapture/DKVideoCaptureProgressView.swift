//
//  DKVideoCaptureProgressView.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/8.
//

import UIKit

import SnapKit

class DKVideoCaptureProgressView: UIView {
    
    // 最大最小录制时间
    static let minDuration: CGFloat = 5
    static let maxDuration: CGFloat = 300
    
    let backgroudView: UIView = UIView()
    let progressView: UIView = UIView()
    
    var sectionDots: [DotView] = []
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    class DotView: UIView {
        var position: CGFloat = 0
        var url: URL?
        convenience init(position: CGFloat, url: URL? = nil) {
            self.init(frame: .zero)
            self.position = position
            self.url = url
            self.backgroundColor = .white
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        setup()
    }
    
    func setup() {
        addSubview(backgroudView)
        backgroudView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        let position = DKVideoCaptureProgressView.minDuration / DKVideoCaptureProgressView.maxDuration
        let firstDotView = DotView(position: position)
        addSubview(firstDotView)
        sectionDots.append(firstDotView)
        
        addSubview(progressView)
        progressView.backgroundColor = UIColor(red: 1, green: 0.41, blue: 0.52, alpha: 1)
    }
    
    func addDot(_ url: URL) {
        if let last = sectionDots.last, (last.bounds.maxX + 6) > progress * bounds.width {
            return // 相隔太近不添加
        }
        let new = DotView(position: progress, url: url)
        addSubview(new)
        sectionDots.append(new)
        setNeedsDisplay()
    }
    
    func removeDot(_ url: URL) {
        guard let lastUrl = sectionDots.last?.url, lastUrl == url else { return } // 保留第一个点
        let last = sectionDots.removeLast()
        last.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroudView.frame = bounds
        let pRect = CGRect(x: 0, y: 0, width: progress * bounds.width, height: bounds.height)
        progressView.frame = pRect
        
        for dot in sectionDots {
            dot.frame = CGRect(x: dot.position * bounds.width, y: 0, width: bounds.height, height: bounds.height)
        }
    }
}
