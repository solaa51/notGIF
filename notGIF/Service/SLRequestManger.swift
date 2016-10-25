//
//  SLRequestManger.swift
//  notGIF
//
//  Created by Atuooo on 15/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//
import UIKit
import Photos
import Social
import Accounts
import MobileCoreServices

fileprivate typealias JSON = [String: AnyObject]
fileprivate typealias Completion = (_ result: Result) -> ()

fileprivate enum Result {
    case success(JSON)
    case wrong(String)
    case failed(String)
}

final class SLRequestManager {
    
    class func shareGIF(asset: PHAsset, to account: ACAccount, with message: String) {
        
        StatusBarToast.shared.show(info: .continue(message: "sending  ", shouldLoading: true))
        
        PHImageManager.requestGIFData(for: asset) { data in
        
            if let gifData = data {
                
                switch account.accountType.identifier {
                    
                case ACAccountTypeIdentifierTwitter: // 👉 https://dev.twitter.com/rest/reference/post/media/upload
                    // 先上传 media 获取 media_id
                    let uploadURL = URL(string: "https://upload.twitter.com/1.1/media/upload.json")!
                    let dataString = gifData.base64EncodedString(options: .lineLength64Characters)
                    
                    guard let getMediaIDRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                                                      requestMethod: .POST,
                                                      url: uploadURL,
                                                      parameters: ["media": dataString]) else {

                        StatusBarToast.shared.show(info: .end(message: "invalid request", succeed: false))
                        return
                    }
                    
                    getMediaIDRequest.account = account
                    
                    SLRequestManager.perform(getMediaIDRequest) { result in
                        
                        switch result {
                        case .success(let info):
                            guard let mediaID = info["media_id_string"] as? String else {
                                StatusBarToast.shared.show(info: .end(message: "api error", succeed: false))
                                return
                            }
                            
                            var parameters = Dictionary<String, String>()
                            parameters["status"] = message
                            parameters["media_ids"] = mediaID
                            
                            let tweetURL = URL(string: "https://api.twitter.com/1.1/statuses/update.json")!
                            guard let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                                                         requestMethod: .POST,
                                                         url: tweetURL,
                                                         parameters: parameters) else {
                                                            
                                StatusBarToast.shared.show(info: .end(message: "invalid request", succeed: false))
                                return
                            }
                            
                            tweetRequest.account = account
                            
                            SLRequestManager.perform(tweetRequest) { result in
                                var toastInfo: ToastInfoType
                                
                                switch result {
                                case .success:
                                    toastInfo = .end(message: "Successful :)", succeed: true)
                                case .wrong(let info):
                                    toastInfo = .end(message: "error: \(info)", succeed: false)
                                case .failed(let info):
                                    toastInfo = .end(message: "failed: \(info)", succeed: false)
                                }
                                
                                StatusBarToast.shared.show(info: toastInfo)
                            }
                        
                        case .wrong(let info):
                            StatusBarToast.shared.show(info: .end(message: "error: \(info)", succeed: false))
                            
                        case .failed(let info):
                            StatusBarToast.shared.show(info: .end(message: "failed: \(info)", succeed: false))
                        }
                    }

                case ACAccountTypeIdentifierSinaWeibo:    // 👉 http://open.weibo.com/wiki/2/statuses/upload

                    let uploadURL = URL(string: "https://upload.api.weibo.com/2/statuses/upload.json")!
                    guard let uploadRequest = SLRequest(forServiceType: SLServiceTypeSinaWeibo,
                                                  requestMethod: .POST,
                                                  url: uploadURL,
                                                  parameters: ["status": message]) else {
                        StatusBarToast.shared.show(info: .end(message: "invalid request", succeed: false))
                        return
                    }
                    
                    uploadRequest.account = account
                    uploadRequest.addMultipartData(gifData, withName: "pic", type: "image/gif", filename: nil)
                    
                    SLRequestManager.perform(uploadRequest) { result in
                        var toastInfo: ToastInfoType
                        
                        switch result {
                        case .success:
                            toastInfo = .end(message: "Successful :)", succeed: true)
                        case .wrong(let info):
                            toastInfo = .end(message: "error: \(info)", succeed: false)
                        case .failed(let info):
                            toastInfo = .end(message: "failed: \(info)", succeed: false)
                        }
                        
                        StatusBarToast.shared.show(info: toastInfo)
                    }
                    
                default:
                    StatusBarToast.shared.show(info: .end(message: "invalid account", succeed: false))
                }
                
            } else {
                StatusBarToast.shared.show(info: .end(message: "unavailable data", succeed: false))
            }
        }
    }
    
    fileprivate class func perform(_ request: SLRequest, completion: @escaping Completion) {
        request.perform { (data, response, error) in
            
            if let error = error {
                completion(.failed(error.localizedDescription))
                
            } else {
                
                if let data = data, let response = response,
                    let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSON {
                    
                    let statusCode = response.statusCode
                    
                    if (200...299) ~= statusCode {
                        completion(.success(json))
                    } else {
                        
                        let accountType = request.account.accountType.identifier!
                        
                        switch accountType {
                        case ACAccountTypeIdentifierTwitter: // 👉 https://dev.twitter.com/overview/api/response-codes
                            
                            if let error = (json["errors"] as? Array<JSON>)?.first,
                                let message = error["message"] as? String {
                                
                                completion(.wrong(message))
                                
                            } else {
                                
                                let localizedString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                                completion(.wrong(localizedString))
                            }
                            
                        case ACAccountTypeIdentifierSinaWeibo:  // 👉 http://open.weibo.com/wiki/Error_code
                            
                            if let message = json["error"] as? String {
                                completion(.wrong(message))

                            } else {
                                
                                let localizedString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                                completion(.wrong(localizedString))
                            }
                            
                        default:
                            completion(.wrong("errorType: \(accountType)"))
                        }
                    }
                    
                } else {
                    
                    completion(.failed("can't parse response"))
                }
            }
        }
    }
}

