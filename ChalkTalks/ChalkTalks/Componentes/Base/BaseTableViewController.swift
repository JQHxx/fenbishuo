//
//  BaseTableViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    public lazy var tableView: UITableView = {
        return UITableView(frame: CGRect.zero, style: self.tableViewStyle())
    }()
    
    open func tableViewStyle() -> UITableView.Style {
        return .plain
    }
    
    override func setup() {
        super.setup()
        
        tableView.ss.registerCell(UITableViewCell.self)
        tableView.ss.registerCell(BaseTableViewCell.self)
        tableView.ss.registerView(UITableViewHeaderFooterView.self)
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.ss.prepare { (view) in
            view.estimatedRowHeight = 0
            view.rowHeight = UITableView.automaticDimension
            view.separatorStyle = .none
            
            if #available(iOS 11, *) {
                view.contentInsetAdjustmentBehavior = .never

                view.estimatedRowHeight = 0
                view.estimatedSectionFooterHeight = 0
                view.estimatedSectionHeaderHeight = 0
            }

            if view.tableHeaderView == nil {
                view.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0.001))
            }
            if view.tableFooterView == nil {
                view.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0.001))
            }

            view.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
            }
        }
    }
}

extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().ss.prepare { $0.backgroundColor = .clear }
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().ss.prepare { $0.backgroundColor = .clear }
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.ss.dequeueCell(indexPath) as UITableViewCell
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableViewStyle() == .grouped ? CGFloat.leastNormalMagnitude : 0
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableViewStyle() == .grouped ? CGFloat.leastNormalMagnitude : 0
    }
}
