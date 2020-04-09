//
//  MessageViewDetailController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

/// 分类详情页
final class MessageViewDetailController: MessageViewBaseController {
    
    override func setup() {
        super.setup()
        navItem.title = type.title
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        tableView.ss.registerCell(MessageInviteTypeCell.self)
        tableView.ss.registerCell(MessageLikeTypeCell.self)
    }
    
    override func didLoadData() {
        super.didLoadData()
        tableView.reloadData()
        showLoadMoreIfNeed()
    }
    
    // MAKR: - TableView
    
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
            switch type {
            case .invite:
                cell = tableView.ss.dequeueCell(indexPath) as MessageInviteTypeCell
            case .like, .reply:
                cell = tableView.ss.dequeueCell(indexPath) as MessageLikeTypeCell
            default:
                cell = tableView.ss.dequeueCell(indexPath) as MessageBaseCell
            }
            cell.parentController = self
            cell.prepare(data)
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
                
        switch type {
        case .invite:
            guard let questionId = data.question?.id else { break }
            let param = [
                "questionId": questionId
            ]
            showTopicDetail(param, data)
        default:
            showDetailViewIfNeed(data)
        }
    }
}
