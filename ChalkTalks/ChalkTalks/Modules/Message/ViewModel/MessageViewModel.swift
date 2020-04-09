//
//  MessageViewModel.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

class MessageViewModel: BaseViewModel {
    
    var currentPage: Int = 0
    
    // 消息总数
    fileprivate var itemCount = 0
    // 页码总数
    fileprivate var pageCount = 1
    
    override class func pageSize() -> Int {
        return 30
    }
    
    override func hasMoreData() -> Bool {
        return itemCount > details.count
    }
    
    let type: MessageType
    
    var details: [MessageDetailInfo] = []
        
    init(_ type: MessageType) {
        self.type = type
        super.init()
    }
    
    var isLoading: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    func loadData(needResetPage: Bool = false) -> Observable<String?> {
        return Observable.create { [weak self] observer in
            guard let self = self, !self.isLoading.value else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.isLoading.accept(true)
            
            let request = CTFMessageApi.getMessageList(self.type.rawValue,
                                                       pageIdx: needResetPage ? 1 : self.currentPage,
                                                       pageSize: MessageViewModel.pageSize())
            request.requstApiComplete { [weak self] (success, data, error) in
                guard let self = self else { return }
                if success,
                    let json = data as? [String: Any],
                    let paging = json["paging"] as? [String: Any],
                    let total = paging["total"] as? Int,
                    let count = paging["count"] as? Int,
                    let msgList = json["data"] as? [[String: Any]] {
                    
                    self.itemCount = total
                    self.pageCount = count
                    
                    if !needResetPage, total > 0, self.details.count >= total {
                        Logger.debug("[Message] 数据重复。")
                        observer.onNext(nil)
                        observer.onCompleted()
                        self.isLoading.accept(false)
                        return
                    }
                    
                    if needResetPage {
                        self.currentPage = 2
                        self.details = []
                    } else {
                        self.currentPage += 1
                    }
                    
                    for msg in msgList {
                        if let detail = MessageDetailInfo(msg) {
                            self.details.append(detail)
                        }
                    }
                    observer.onNext(nil)
                } else if let error = error {
                    self.handlerError(error)
                    observer.onNext(self.apiErrorString)
                } else {
                    observer.onNext(nil)
                }
                observer.onCompleted()
                self.isLoading.accept(false)
            }
            
            return Disposables.create()
        }
    }
}
