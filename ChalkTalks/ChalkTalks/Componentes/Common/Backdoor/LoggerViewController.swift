//
//  LoggerViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/26.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

final class LoggerViewController: BaseViewController {
    
    fileprivate let textView: UITextView = UITextView()
    
    override func setup() {
        super.setup()
        navItem.title = "查看日志"
        showBackButton = true
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        textView.ss.prepare { (view) in
            view.font = UIFont.systemFont(ofSize: 12)
            view.isEditable = false
            contentView.addSubview(view)
            view.snp.makeConstraints({ $0.edges.equalToSuperview() })
            do {
                let fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: Logger.filePath))
                let data = fileHandle.readDataToEndOfFile()
                view.text = String(data: data, encoding: .unicode)
                fileHandle.closeFile()
            } catch {
                view.text = "日志读取失败\n\(error)"
            }
        }
        
        let clearButton = BaseButton(type: .custom).ss.prepare { (button) in
            button.setTitle("清除日志", for: .normal)
            button.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
            button.rx.tap
                .subscribe(onNext: { [weak self] (_) in
                    do {
                        let fileHandle = try FileHandle(forUpdating: URL(fileURLWithPath: Logger.filePath))
                        fileHandle.truncateFile(atOffset: 0)
                        self?.textView.text = "日志清理完毕。"
                        fileHandle.closeFile()
                    } catch {
                        if let view = self?.contentView {
                            HUD.show(to: view, text: "日志清理失败\(error)")
                        }
                    }
                }).disposed(by: disposeBag)
        }
        navItem.rightBarButtonItem = UIBarButtonItem(customView: clearButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
}
