//
//  BaseTableViewCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

open class BaseTableViewCell: UITableViewCell {

    open override func awakeFromNib() {
        super.awakeFromNib()
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public var topLineInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }

    public var btmLineInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    public var topLine: UIView = UIView()
    public var btmLine: UIView = UIView()
    public var btmLineHeight: CGFloat = Utils.splitWidth
    
    open func setup() {
        clipsToBounds = false
        contentView.clipsToBounds = true
        selectionStyle = .none
        contentView.addSubview(self.topLine)
        contentView.addSubview(self.btmLine)
        topLine.isHidden = true
        btmLine.isHidden = true
        topLine.layer.zPosition = 999
        btmLine.layer.zPosition = 999
        btmLine.backgroundColor = UIColor(0xEEEEEEFF)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if layer.shadowRadius > 0 {
            layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }

        topLine.frame = CGRect(
            x: topLineInset.left,
            y: 0,
            width: self.bounds.width - self.topLineInset.left - self.topLineInset.right,
            height: Utils.splitWidth
        )
        if !topLine.isHidden {
            contentView.bringSubviewToFront(topLine)
        }

        btmLine.frame = CGRect(
            x: btmLineInset.left,
            y: contentView.bounds.height - btmLineHeight,
            width: bounds.width - btmLineInset.left - btmLineInset.right,
            height: btmLineHeight
        )
        if !btmLine.isHidden {
            contentView.bringSubviewToFront(btmLine)
        }
    }
}

final class Value1TableViewCell: BaseTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class Value2TableViewCell: BaseTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class SubtitleTableViewCell: BaseTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
