//
//  SkeletonDelegate.swift
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/15.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

@objc(CTFSkeletonDelegate)
protocol SkeletonDelegate : SkeletonTableViewDelegate, SkeletonTableViewDataSource {

    @objc optional func numSections(in collectionSkeletonView: UITableView) -> Int
    @objc optional func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int
    @objc func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier

}
