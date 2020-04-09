//
//  BackdoorViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

@objc(CTBackdoorViewController)
final class BackdoorViewController: BaseTableViewController {
    
    static let phoneLoginStoreKey = "com.douya.ios.env.phone.login.key"
    
    fileprivate enum AppInfo: String, CaseIterable {
        case channel, version, build
        
        var title: String {
            switch self {
            case .channel:
                return "渠道"
            case .version:
                return "版本"
            case .build:
                return "构建"
            }
        }
        
        var valueText: String {
            switch self {
            case .channel:
                return EnvConfig.share.channel.rawValue
            case .version:
                return Utils.appVersion
            case .build:
                return Utils.buildVersion
            }
        }
    }
    
    #if DEBUG
    override func willDealloc() -> Bool {
        return false
    }
    #endif
    
    @objc class func showBackdoor() {
        
        #if DEBUG || ADHOC
        Utils.topVC?.navigationController?.pushViewController(BackdoorViewController(), animated: true)
        return
        #else
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let alert = UIAlertController(title: "CT", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { [unowned alert] _ in
            guard
                let tf = alert.textFields?.first,
                let text = tf.text,
                text == "8086"
                else { return }

            Utils.topVC?.navigationController?.pushViewController(BackdoorViewController(), animated: true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
            textField.placeholder = ""
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        })
        alert.popoverPresentationController?.sourceView = window
        alert.popoverPresentationController?.sourceRect = window.bounds

        Utils.topVC?.present(alert, animated: true, completion: nil)
        #endif
    }
    
    override func tableViewStyle() -> UITableView.Style {
        if #available(iOS 13.0, *) {
            return .insetGrouped
        } else {
            return .grouped
        }
    }
    
    override func setup() {
        super.setup()
        navItem.title = Utils.appName
        showBackButton = true
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        tableView.ss.registerCell(Value1TableViewCell.self)
        tableView.ss.registerCell(SwitchTableViewCell.self)
    }
    
    override func prepareRx() {
        super.prepareRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.flush()
    }
    
    // MARK: - Table
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return AppInfo.allCases.count
        case 1:
            return EnvType.allCases.count
        case 2, 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: BaseTableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.ss.dequeueCell(indexPath) as Value1TableViewCell
            let type = AppInfo.allCases[indexPath.row]
            cell.textLabel?.text = type.title
            cell.detailTextLabel?.text = type.valueText
        case 1:
            cell = tableView.ss.dequeueCell(indexPath) as BaseTableViewCell
            let type = EnvType.allCases[indexPath.row]
            cell.textLabel?.text = type.rawValue
            if EnvConfig.share.envType == type {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case 2:
            cell = tableView.ss.dequeueCell(indexPath) as BaseTableViewCell
            cell.textLabel?.text = "查看日志"
        case 3:
            cell = tableView.ss.dequeueCell(indexPath) as SwitchTableViewCell
            cell.textLabel?.text = "假装没有安装微信😁"
            (cell as? SwitchTableViewCell)?.prepare(BackdoorViewController.phoneLoginStoreKey)
        default:
            cell = tableView.ss.dequeueCell(indexPath) as BaseTableViewCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // 测试入口
//            NotificationAlert.showAuthReq()
//            PushManager.share.showAuthReqAlertIfNeed()
            break
        case 1:
            let type = EnvType.allCases[indexPath.row]
            EnvConfig.share.update(type: type)
            tableView.reloadData()
        case 2:
            navigationController?.pushViewController(LoggerViewController(), animated: true)
        default:
            break
        }
    }
}

fileprivate final class SwitchTableViewCell: BaseTableViewCell {
    
    let switchControl: UISwitch = UISwitch()
    var bag: DisposeBag!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        
        switchControl.ss.prepare { (view) in
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-16)
            }
        }
    }
    
    func prepare(_ key: String) {
        let value = UserDefaults.standard.string(forKey: key) != nil
        switchControl.isOn = value
        
        bag = DisposeBag()
        switchControl.rx
            .isOn
            .subscribe(onNext: { (value) in
                if value {
                    UserDefaults.standard.set("", forKey: key)
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }).disposed(by: bag)
    }
}
