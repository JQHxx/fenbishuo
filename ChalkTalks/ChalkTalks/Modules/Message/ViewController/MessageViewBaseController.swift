//
//  MessageViewBaseController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import MJRefresh

import RxSwift
import RxCocoa

class MessageViewBaseController: BaseTableViewController {
    
    let type: MessageType
    
    let viewModel: MessageViewModel
    
    weak var parentController: MessageViewController?
    
    var didFirstAppear: Bool = false
    
    init(type: MessageType, pvc: MessageViewController?) {
        self.type = type
        self.viewModel = MessageViewModel(type)
        self.parentController = pvc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !didFirstAppear && !(tableView.mj_header?.isRefreshing ?? true) {
            tableView.mj_header?.beginRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        didFirstAppear = true
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        tableView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
            self?.loadData(true)
            guard
                let self = self,
                !self.viewModel.details.isEmpty,
                [.information, .system].contains(self.type)
                else { return }
            self.parentController?.loadUnreadCount()
        })
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.ss.registerCell(MessageEmptyCell.self)
        tableView.ss.registerCell(MessageBaseCell.self)
    }
    
    func loadData(_ isFirstPage: Bool = false) {
        if viewModel.isLoading.value || UserCache.isUserLogined() == .notLogin {
            if isFirstPage {
                tableView.mj_header?.endRefreshing()
            }
            return
        }
        
        viewModel.loadData(needResetPage: isFirstPage)
        .subscribe(onNext: { [weak self] (msg) in
            self?.tableView.mj_header?.endRefreshing()
            self?.tableView.mj_footer?.endRefreshing()
            self?.didLoadData()
        }).disposed(by: disposeBag)
    }
    
    func didLoadData() {
        
    }
    
    func showLoadMoreIfNeed() {
        if viewModel.hasMoreData() {
            tableView.mj_footer = RefreshFooter(refreshingBlock: { [weak self] in
                if self?.viewModel.hasMoreData() ?? false {
                    self?.loadData()
                }
            })
        } else if !viewModel.details.isEmpty {
            let footer = RefreshFooter(refreshingBlock: {})
            tableView.mj_footer = footer
            footer.state = .noMoreData
        } else {
            tableView.mj_footer = nil
        }
    }
    
    func readAllCategoryMessages(_ categoryType: MessageType? = nil) {
        beginReadAll()
        let request = CTFMessageApi.readAll(categoryType?.rawValue ?? type.rawValue)
        request.requstApiComplete { [weak self] (success, _, _) in
            if success {
                guard let self = self else { return }
                if let ct = categoryType, let detail = self.viewModel.details.first(where: { $0.itemType == ct }) {
                    detail.isRead.accept(true)
                } else {
                    self.viewModel.details.forEach({ (detail) in
                        detail.isRead.accept(true)
                    })
                }
                self.parentController?.didReadCagegory(categoryType ?? self.type)
            }
            self?.endReadAll(success)
        }
    }
    
    func beginReadAll() {
        
    }
    
    func endReadAll(_ success: Bool) {
        
    }
    
    func readMessage(data: MessageDetailInfo) {
        guard !data.isRead.value else { return }
        let request = CTFMessageApi.read([data.id])
        request.requstApiComplete { [weak self] (success, _, _) in
            if success {
                data.isRead.accept(true)
                if let type = self?.type {
                    self?.parentController?.didReadOneMessage(type)
                }
            }
        }
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(viewModel.details.count, 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.details.isEmpty ? MessageEmptyCell.height : UITableView.automaticDimension
    }
    
    // MARK: - WebView & Block
    
    func showDetailViewIfNeed(_ data: MessageDetailInfo) {
        
        if data.action.hasPrefix("SYSTEM_BLOCK_") {
            showBlockedWebView(data); return
        }
        
        var param: [String: Int]?
        switch data.contentType {
        case .answer:
            guard
                let answer = data.answer,
                let qid = answer.questionId
                else { break }
            if type == .system && answer.isBlocked {
                showBlockedWebView(data); return
            }
            param = [
                "questionId": qid,
                "answerId": answer.id
            ]
        case .question:
            guard let question = data.question else {
                break
            }
            if type == .system && question.isBlocked {
                showBlockedWebView(data); return
            }
            param = [
                "questionId": question.id
            ]
        case .comment:
            guard
                let comment = data.comment,
                let aid = comment.answerId,
                let qid = comment.questionId
                else { break }
            if type == .system && comment.isBlocked {
                showBlockedWebView(data)
                readMessage(data: data)
            } else {
                param = [
                    "questionId": qid,
                    "answerId": aid
                ]
            }
        case .system:
            if data.question?.isBlocked ?? false {
                showBlockedWebView(data)
                readMessage(data: data)
            } else if let url = data.url {
                showWebView(url: url, data: data)
                readMessage(data: data)
            }
        default:
            break
        }
        
        if let param = param {
            showTopicDetail(param, data)
        }
    }
    
    func showTopicDetail(_ param: [String: Int], _ data: MessageDetailInfo) {
        let topic = CTFTopicDetailsVC()
        topic.schemaArgu = param
        topic.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(topic, animated: true)
        PushManager.share.metricsReport(type: data.contentType.rawValue, tid: "\(data.taskId)", isPush: false)
        readMessage(data: data)
    }
    
    func showBlockedWebView(_ data: MessageDetailInfo) {
        let urlStr = EnvConfig.share.h5BaseUrl() + "/appview/protocol/content_restriction"
        let webVC = WebViewController(url: URL(string: urlStr))
        navigationController?.pushViewController(webVC, animated: true)
        PushManager.share.metricsReport(type: data.contentType.rawValue, tid: "\(data.taskId)", isPush: false)
    }
    
    func showWebView(url: URL, data: MessageDetailInfo) {
        let webVC = WebViewController(url: url)
        navigationController?.pushViewController(webVC, animated: true)
        PushManager.share.metricsReport(type: data.contentType.rawValue, tid: "\(data.taskId)", isPush: false)
    }
}
