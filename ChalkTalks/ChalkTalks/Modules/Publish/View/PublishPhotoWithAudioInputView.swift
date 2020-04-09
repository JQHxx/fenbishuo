//
//  PublishPhotoWithAudioInputView.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/20.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

final class PublishPhotoWithAudioInputView: BaseView, UITextViewDelegate {
    
    static let textViewHeight: CGFloat = 39
    
    static let viewHeight: CGFloat = textViewHeight + Utils.bottomHeight + 40
    
    let textView: UITextView = UITextView()
    
    fileprivate let tipsLabel: UILabel = UILabel()
    
    fileprivate let placeholderText: String = "不妨加一句说明…"
    fileprivate let placeholderColor: UIColor = UIColor(0xCCCCCCFF)
    fileprivate let surpassColor: UIColor = UIColor(0xFF5757FF)
    
    var textValidity: Bool {
        guard let _text = text else {
            return true
        }
        return _text.count <= maxTextSize
    }
    
    var text: String? {
        if textView.textColor == placeholderColor {
            return nil
        } else {
            return textView.text
        }
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = .white
        let margin: CGFloat = 22
        
        // top line
        UIView().ss.prepare { (view) in
            addSubview(view)
            view.backgroundColor = UIColor(0xEEEEEEFF)
            view.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        
        // bottom line
        UIView().ss.prepare { (view) in
            addSubview(view)
            view.backgroundColor = UIColor(0xEEEEEEFF)
            view.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(margin)
                make.trailing.equalToSuperview().offset(-margin)
                make.height.equalTo(1)
                make.bottom.equalToSuperview().offset(-8 - Utils.bottomHeight)
            }
        }
        
        tipsLabel.ss.prepare { (view) in
            addSubview(view)
            view.text = "0/40"
            view.textColor = placeholderColor
            view.font = UIFont.systemFont(ofSize: 12)
            view.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview().offset(-margin)
                make.bottom.equalToSuperview().offset(-12 - Utils.bottomHeight)
            }
        }
        
        textView.ss.prepare { (view) in
            addSubview(view)
            view.text = placeholderText
            view.textColor = placeholderColor
            view.font = UIFont.systemFont(ofSize: 14)
            view.delegate = self
            view.isEditable = false
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(showInputToolAction(_:)))
            view.addGestureRecognizer(tap)
            view.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(12)
                make.leading.equalToSuperview().offset(margin)
                make.trailing.equalToSuperview().offset(-margin)
                make.height.equalTo(PublishPhotoWithAudioInputView.textViewHeight)
            }
        }
        
        textView.rx.text
            .subscribe(onNext: { [weak self] (text) in
                // 有高亮的正在输入的字符，不做任何处理
                guard let self = self, self.textView.markedTextRange == nil else { return }
                if text?.count ?? 0 > 40 {
                    self.tipsLabel.textColor = self.surpassColor
                    self.tipsLabel.text = "已超过\((text?.count ?? 0) - 40)个字"
                } else {
                    self.tipsLabel.textColor = self.placeholderColor
                    if self.textView.textColor == self.placeholderColor {
                        self.tipsLabel.text = "0/40"
                    } else {
                        self.tipsLabel.text = "\(text?.count ?? 0)/40"
                    }
                }
            }).disposed(by: disposeBag)
        /*
        NotificationCenter.default.rx
            .notification(UITextView.textDidChangeNotification, object: textView)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                if self.textView.text.count > self.maxTextSize {
                    let selectRange = self.textView.markedTextRange
                    if let selectRange = selectRange {
                        let position =  self.textView.position(from: (selectRange.start), offset: 0)
                        if (position != nil) {
                            // 高亮部分不进行截取，否则中文输入会把高亮区域的拼音强制截取为字母，等高亮取消后再计算字符总数并截取
                            return
                        }
                    }
                    let index = String.UTF16View.Index(utf16Offset: self.maxTextSize, in: self.textView.text)
                    self.textView.text = String(self.textView.text[..<index])

                    // TODO: 模拟器上不生效
                    // 对于粘贴文字的case，粘贴结束后若超出字数限制，则让光标移动到末尾处
                    self.textView.selectedRange = NSRange(location: self.textView.text.count, length: 0)
                }
            }).disposed(by: disposeBag)
           */
    }
    
    @objc func showInputToolAction(_ sender: UITapGestureRecognizer) {
        let content = textView.text == placeholderText ? "" : textView.text
        CTFCommentToolView.showCommentInputView(withFrame: CGRect(x: 0,y: Utils.screenPortraitHeight,width: Utils.screenPortraitWidth,height: 127), type: CTFInputToolViewTypeAudioImage, isAuthor: false, name: nil, content: content, submit: nil) { (value) in
            self.textView.text = value
            if self.textView.text.isEmpty {
                self.textView.textColor = self.placeholderColor
                self.textView.text = self.placeholderText
            } else {
                self.textView.textColor = .black
            }
        }
    }
    
    // MARK: - TextView Delegate
    
    let maxTextSize: Int = 40
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 高亮控制
        /*
        let selectedRange = textView.markedTextRange
        if let selectedRange = selectedRange {
            let position =  textView.position(from: (selectedRange.start), offset: 0)
            if position != nil {
                let startOffset = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                let endOffset = textView.offset(from: textView.beginningOfDocument, to: selectedRange.end)
                let offsetRange = NSMakeRange(startOffset, endOffset - startOffset) // 高亮部分起始位置
                if offsetRange.location < maxTextSize {
                    // 高亮部分先不进行字数统计
                    return true
                } else {
                    return false
                }
            }
        }

        
        // 在最末添加
        if range.location >= maxTextSize {
            return false
        }

        // 在其他位置添加
        if textView.text.count >= maxTextSize && range.length <  text.count {
            return false
        }
        */
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderColor {
            textView.textColor = .black
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = placeholderColor
            textView.text = placeholderText
        }
    }
}
