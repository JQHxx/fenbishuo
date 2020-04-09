//
//  MessageViewSubController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import MJRefresh

import RxSwift
import RxCocoa

final class MessageViewSubController: MessageViewBaseController {
    
    fileprivate var headerView: UIView = UIView()
    fileprivate var headerTitleLabel: UILabel?
    fileprivate var headerReadButton: BaseButton?
    fileprivate var headerLoadingView: UIImageView?
    
    override func setup() {
        super.setup()
        showNavBar = false
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        headerView.ss.prepare { (view) in
            view.backgroundColor = .white
            headerTitleLabel = UILabel().ss.prepare({ (label) in
                label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                label.textColor = UIColor(0x999999FF)
                headerView.addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.leading.equalToSuperview().offset(16)
                }
            })
            headerReadButton = BaseButton(type: .custom).ss.prepare({ (button) in
                button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                button.setTitleColor(UIColor(0x999999FF), for: .normal)
                button.hitTestInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
                button.rx.tap.subscribe(onNext: { [weak self] (_) in
                    self?.readAllCategoryMessages()
                }).disposed(by: disposeBag)
                headerView.addSubview(button)
                button.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-16)
                }
            })
            headerLoadingView = UIImageView().ss.prepare({ (view) in
                view.image = UIImage(named: "icon_msg_loading")
                view.isHidden = true
                headerView.addSubview(view)
                view.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.trailing.equalTo(headerReadButton!.snp.leading).offset(-6)
                    make.size.equalTo(CGSize(width: 16, height: 16))
                }
            })
            contentView.addSubview(headerView)
            headerView.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(44)
            }
            headerView.isHidden = true
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        
        tableView.ss.registerCell(MessageNormalTypeCell.self)
        tableView.ss.registerCell(MessageSystemTypeCell.self)
    }
    
    /// 二级页面返回标记全部已读
    fileprivate var needReadCategoryMessage: MessageType?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ct = needReadCategoryMessage {
            readAllCategoryMessages(ct)
            needReadCategoryMessage = nil
        }
    }
    
    override func didLoadData() {
        super.didLoadData()
        updateHeaderSection()
        tableView.reloadData()
        showLoadMoreIfNeed()
    }
    
    func updateHeaderSection() {
        guard !viewModel.details.isEmpty else {
            headerView.isHidden = true
            return
        }
        
        headerView.isHidden = false
        
        var unread = 0
        if let unreadCount = parentController?.unreadCount.value {
            switch type {
            case .information:
                unread = unreadCount.information
            case .system:
                unread = unreadCount.system
            default:
                break
            }
        }
        
        switch type {
        case .information:
            headerTitleLabel?.text = "消息列表" + (unread > 0 ? "（\(unread)未读）" : "")
        case .system:
            headerTitleLabel?.text = "通知列表" // + (unread > 0 ? "（\(unread)未读）" : "")
        default:
            break
        }
        
        if unread > 0 {
            headerReadButton?.setTitle("全部标为已读", for: .normal)
            headerReadButton?.setTitleColor(UIColor(0xFF6885FF), for: .normal)
            headerReadButton?.isEnabled = true
        } else {
            headerReadButton?.setTitle("全部已读", for: .normal)
            headerReadButton?.setTitleColor(UIColor(0x999999FF), for: .normal)
            headerReadButton?.isEnabled = false
        }
    }
    
    override func beginReadAll() {
        super.beginReadAll()
        guard let loadingView = headerLoadingView else { return }
        loadingView.isHidden = false
        rotateView(targetView: loadingView)
    }
    
    override func endReadAll(_ success: Bool) {
        super.endReadAll(success)
        headerLoadingView?.layer.removeAllAnimations()
        headerLoadingView?.isHidden = true
        if !success {
            HUD.show(to: view, text: "操作失败，请检查网络")
        }
    }
    
    private func rotateView(targetView: UIView, duration: Double = 0.6) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat.pi)
        }) { finished in
            self.rotateView(targetView: targetView, duration: duration)
        }
    }
}

extension MessageViewSubController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.details.isEmpty && !didFirstAppear {
            let cell = tableView.ss.dequeueCell(indexPath) as BaseTableViewCell
            return cell
        } else if viewModel.details.isEmpty {
            let cell = tableView.ss.dequeueCell(indexPath) as MessageEmptyCell
            return cell
        } else {
            let data = viewModel.details[indexPath.row]
            let cell: MessageBaseCell
            if type == .system {
                cell = tableView.ss.dequeueCell(indexPath) as MessageSystemTypeCell
            } else {
                cell = tableView.ss.dequeueCell(indexPath) as MessageNormalTypeCell
            }
            cell.prepare(data)
            cell.parentController = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !viewModel.details.isEmpty else {
            return
        }
        
        // 埋点
        MobClick.event(type.itemEvent)
        
        let data = viewModel.details[indexPath.row]
        
        if let itemType = data.itemType {
            if itemType == .follower {
                let vc = CTFMineFansListVC()
                vc.schemaArgu = ["userId": UserCache.getUserInfo().userId]
                vc.monitorPull = true;
                vc.hidesBottomBarWhenPushed = true
                // vc.parentController = parentController
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = MessageViewDetailController(type: itemType, pvc: self.parentController)
                navigationController?.pushViewController(vc, animated: true)
            }
            needReadCategoryMessage = itemType
            return
        }
        
        showDetailViewIfNeed(data)
    }
}
