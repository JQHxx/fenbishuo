//
//  OSSUploader.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

import DKImagePickerController
import AliyunOSSiOS
import RxSwift
import SDWebImage

// MARK: - OSSUploaderInfo

@objc(CTOSSUploaderInfo)
class OSSUploadInfo: NSObject {
    
    @objc var objectKey: String
    
    @objc var objectId: String
    
    @objc var didUpload: Bool = false
    
    @objc var accessKeySecret: String = ""
    @objc var accessToken: String = ""
    @objc var accessKeyId: String = ""
    
    fileprivate var accessExpiration: Double?
    
    /// from draft
    init(objectKey: String, objectId: String) {
        self.objectKey = objectKey
        self.objectId = objectId
        self.didUpload = true
        super.init()
    }
    
    @objc init?(_ json: [String: Any]) {
        guard
            let uploadFile = json["uploadFile"] as? [String: Any],
            let objectKey = uploadFile["objectKey"] as? String
            else { return nil }
        
        if let imageId = uploadFile["imageIdString"] as? String {
            self.objectId = imageId
        } else if let audioId = uploadFile["audioIdString"] as? String {
            self.objectId = audioId
        } else {
            return nil
        }
        
        self.objectKey = objectKey
        
        guard
            let uploadToken = json["uploadToken"] as? [String: Any],
            let accessKeySecret = uploadToken["accessKeySecret"] as? String,
            let accessToken = uploadToken["accessToken"] as? String,
            let accessKeyId = uploadToken["accessKeyId"] as? String
            else {
                self.didUpload = true
                super.init()
                return
        }
        
        self.accessKeySecret = accessKeySecret
        self.accessToken = accessToken
        self.accessKeyId = accessKeyId
        
        if let accessExpiration = uploadToken["accessExpiration"] as? Double {
            self.accessExpiration = accessExpiration
        }
        super.init()
    }
}

// MARK: - OSSUploader

@objc(CTOSSUploader)
class OSSUploader: NSObject {
    
    let endpoint: String = "http://oss-cn-shenzhen.aliyuncs.com"
    
    let client: OSSClient
    
    init?(_ json: [String: Any]) {
        guard
            let accessKeyId = json["accessKeyId"] as? String,
            let secretKeyId = json["accessKeySecret"] as? String,
            let securityToken = json["accessToken"] as? String
            else { return nil }
        
        let provider = OSSStsTokenCredentialProvider(
            accessKeyId: accessKeyId,
            secretKeyId: secretKeyId,
            securityToken: securityToken
        )
        
        let conf = OSSClientConfiguration()
        conf.maxRetryCount = 1 // 网络请求遇到异常失败后的重试次数
        conf.timeoutIntervalForRequest = 30 // 网络请求的超时时间
        conf.timeoutIntervalForResource = 24 * 60 * 60 // 允许资源传输的最长时间

        client = OSSClient(endpoint: endpoint,
                           credentialProvider: provider,
                           clientConfiguration: conf)
        super.init()
    }
    
    fileprivate static func createClient(_ info: OSSUploadInfo) -> OSSClient {
        
        let endpoint: String = "http://oss-cn-shenzhen.aliyuncs.com"
        
        let provider = OSSStsTokenCredentialProvider(
            accessKeyId: info.accessKeyId,
            secretKeyId: info.accessKeySecret,
            securityToken: info.accessToken
        )
        
        let conf = OSSClientConfiguration()
        conf.maxRetryCount = 1 // 网络请求遇到异常失败后的重试次数
        conf.timeoutIntervalForRequest = 30 // 网络请求的超时时间
        conf.timeoutIntervalForResource = 24 * 60 * 60 // 允许资源传输的最长时间

        return OSSClient(endpoint: endpoint,
                         credentialProvider: provider,
                         clientConfiguration: conf)
    }
    
    static func upload(info: OSSUploadInfo, asset: DKAsset, isAudio: Bool) -> Observable<CGFloat> {

        return Observable<CGFloat>.create { [weak asset] observer in
            
            guard let asset = asset else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            if info.didUpload {
                if isAudio {
                    asset.audioUploadInfo = info
                } else {
                    asset.imageUploadInfo = info
                }
                observer.onCompleted()
                return Disposables.create()
            }
            
            let putObject = OSSPutObjectRequest()
            putObject.objectKey = info.objectKey
            
            var callbackBody: String = "{\"bucket\":${bucket},\"object\":${object},\"etag\":${etag},\"size\":${size},\"mimeType\":${mimeType},\"imageHeight\":\"${imageInfo.height}\",\"imageWidth\":\"${imageInfo.width}\",\"imageFormat\":${imageInfo.format},\"businessId\":${x:id}"
            
            var callbackVar: [String: Any] = ["x:id": info.objectId]
            
            if isAudio {
                callbackBody += ",\"duration\":${x:duration}}"
                // 毫秒
                callbackVar["x:duration"] = "\(asset.audioDuration * 1000)"
                asset.audioUploadInfo = info
                putObject.contentType = "audio/mpeg"
                putObject.bucketName = EnvConfig.share.audioBucketName()
                if let audioPath = asset.audioPath.value,
                    let audioData = try? Data(contentsOf: URL(fileURLWithPath: audioPath)) {
                    putObject.uploadingData = audioData
                } else {
                    observer.onCompleted()
                    return Disposables.create()
                }
            } else {
                callbackBody += "}"
                asset.imageUploadInfo = info
                putObject.bucketName = EnvConfig.share.aliBucketName()
                var _imageData: Data?
                if let imagePath = asset.imagePath.value {
                    if asset.fromDraft {
                        let image = UIImage(contentsOfFile: imagePath)
                        _imageData = SDImageIOCoder.shared.encodedData(with: image, format: .JPEG, options: nil)
                    } else {
                        let image = SDImageCache.shared.imageFromCache(forKey: imagePath)
                        _imageData = SDImageIOCoder.shared.encodedData(with: image, format: .JPEG, options: nil)
                    }
                }
                if let imageData = _imageData {
                    putObject.uploadingData = imageData
                } else {
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
            
            var callbackUrl: String = EnvConfig.share.baseUrl()
            if isAudio {
                callbackUrl += "/api/v1/audios/callback"
            } else {
                callbackUrl += "/api/v1/images/callback"
            }
            
            putObject.callbackParam = [
                "callbackUrl": callbackUrl,
                "callbackBody" : callbackBody,
                "callbackBodyType" : "application/json",
            ]
            
            putObject.callbackVar = callbackVar
            
            putObject.uploadProgress = { bytesSent, totalByteSent, totalBytesExpectedToSend in
                let progress = CGFloat(totalByteSent) / CGFloat(totalBytesExpectedToSend)
                DispatchQueue.main.async {
                    observer.onNext(progress)
                }
            }
            
            asset.uploadObject = putObject
            
            let client: OSSClient = self.createClient(info)
            let task: OSSTask = client.putObject(putObject)
            task.continue({ (task: OSSTask) -> Any? in
                if let error = task.error as NSError? {
                    if error.code == OSSClientErrorCODE.codeTaskCancelled.rawValue {
                        // cancel
                    }
                    // 上传失败
                    Logger.error("阿里云上传失败 \(isAudio ? "音频" : "图片") \(error)")
                    observer.onError(error)
                } else {
                    // 上传成功
                    observer.onCompleted()
                }
                return nil
            }).waitUntilFinished()
            
            return Disposables.create()
        }
    }
}
