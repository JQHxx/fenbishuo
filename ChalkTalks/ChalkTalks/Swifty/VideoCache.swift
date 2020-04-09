//
//  VideoCache.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

import SDWebImage

@objc(CTVideoCache)
class VideoCache: NSObject {
    
    @objc static let share = VideoCache()
    
    fileprivate let queue = DispatchQueue(label: "com.fenbishuo.ios.video.cache.queue")
    
    fileprivate var cache: SDDiskCache?
    
    private override init() {
        super.init()
        
        cache = SDDiskCache(cachePath: cachePath, config: SDImageCacheConfig.default)
        queue.async {
            self.cache?.removeExpiredData()
        }
    }
    
    private let cachePath: String = {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let directory = cachesDirectory + "/videos/"
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("创建videos文件夹失败 \(error)")
        }
        return directory
    }()
    
    /// 缓存视频
    /// - Parameters:
    ///   - path: 视频路径
    ///   - questionId: 关联question id
    @objc func saveVideo(path: String, questionId: Int) {
        queue.async {
            guard var targetPath = self.cache?.cachePath(forKey: questionId.videoKey) else { return }
            if let fileType = path.split(separator: ".").last {
                targetPath += ".\(fileType)"
            }
            if FileManager.default.fileExists(atPath: targetPath) {
                try? FileManager.default.removeItem(atPath: targetPath)
            }
            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                try FileManager.default.copyItem(atPath: path, toPath: targetPath)
//                self.cache?.setData(data, forKey: questionId.videoKey)
                Logger.debug("缓存视频 \(targetPath)")
            } catch {
                Logger.debug("缓存视频失败 \(error)")
            }
        }
    }
    
    /// 缓存视频封面
    /// - Parameters:
    ///   - image: 封面图片
    ///   - questionId: 关联question id
    @objc func saveVideoCover(image: UIImage, questionId: Int) {
        SDImageCache.shared.removeImage(forKey: questionId.coverKey, withCompletion: nil)
        SDImageCache.shared.store(image, forKey: questionId.coverKey, completion: nil)
        Logger.debug("缓存视频封面")
    }
    
    /// 获取缓存视频
    /// - Parameter questionId: 关联question id
    /// - Return 视频路径
    @objc func getVideo(questionId: Int) -> String? {
        guard
            let path = cache?.cachePath(forKey: questionId.videoKey)?.split(separator: "/").last,
            let files = try? FileManager.default.contentsOfDirectory(atPath: cachePath),
            let file = files.first(where: { $0.contains(path) })
            else { return nil }
        
        return cachePath + file
    }
    
    /// 获取缓存视频封面
    /// - Parameter questionId: 关联question id
    /// - Return 封面图片
    @objc func getVideoCover(questionId: Int) -> UIImage? {
        return SDImageCache.shared.imageFromCache(forKey: questionId.coverKey)
    }
}

fileprivate extension Int {
    
    var videoKey: String {
        return "\(self)-" + UserCache.getCurrentUserID() + "-video"
    }
    
    var coverKey: String {
        return "\(self)-" + UserCache.getCurrentUserID() + "-cover"
    }
}

fileprivate extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles:Bool = true) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
