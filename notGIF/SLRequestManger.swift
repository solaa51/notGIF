//
//  SLRequestManger.swift
//  notGIF
//
//  Created by Atuooo on 15/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//
import Accounts
import Social
import MobileCoreServices
import UIKit

final class SLRequestManager {

    class func shareGIF(at index: Int, to account: ACAccount, with message: String) {
        
        NotGIFLibrary.shared.requestGIFData(at: index) { (data, UTI) in
            if let gifData = data, let uti = UTI, UTTypeConformsTo(uti as CFString, kUTTypeGIF) {
                
                switch account.accountType.identifier {
                    
                case ACAccountTypeIdentifierTwitter: // 👉 https://dev.twitter.com/rest/reference/post/media/upload
                    // 先上传 media 获取 media_id
                    let uploadURL = URL(string: "https://upload.twitter.com/1.1/media/upload.json")!
                    let dataString = gifData.base64EncodedString(options: .lineLength64Characters)
                    
                    let getMediaIDRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                                                      requestMethod: .POST,
                                                      url: uploadURL,
                                                      parameters: ["media": dataString])
                    
                    getMediaIDRequest?.account = account
                    
                    getMediaIDRequest?.perform(handler: { (data, response, error) in
                        debugPrint("\n============mediaID===response==========\n\(response)\n\(error)")
                        
                        if let error = error {
                            ATAlert.alert(type: .shareFailed(error.localizedDescription), style: .toast)
                            
                        } else {
                            if let data = data,
                                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary,
                                let mediaID = json?["media_id_string"] as? String {
                                
                                var parameters = Dictionary<String, String>()
                                parameters["status"] = message
                                parameters["media_ids"] = mediaID
                                
                                // tweet
                                let tweetURL = URL(string: "https://api.twitter.com/1.1/statuses/update.json")!
                                let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                                                             requestMethod: .POST,
                                                             url: tweetURL,
                                                             parameters: parameters)
                                
                                tweetRequest?.account = account
                                
                                tweetRequest?.perform(handler: { (data, response, error) in
                                    debugPrint("\n============tweet===response==========\n\(response)\n\(error)")
                                    
                                    if let error = error {
                                        ATAlert.alert(type: .shareFailed(error.localizedDescription), style: .toast)

                                    } else {
                                        ATAlert.alert(type: .shareSuccess, style: .toast)
                                    }
                                })
                                
                            } else {
                                ATAlert.alert(type: .shareFailed("why"), style: .toast)
                            }
                        }
                    })
                    
                case ACAccountTypeIdentifierSinaWeibo:    // 👉 http://open.weibo.com/wiki/2/statuses/upload
                    let uploadURL = URL(string: "https://upload.api.weibo.com/2/statuses/upload.json")!
                    let uploadRequest = SLRequest(forServiceType: SLServiceTypeSinaWeibo,
                                                  requestMethod: .POST,
                                                  url: uploadURL,
                                                  parameters: ["status": message])
                    
                    uploadRequest?.account = account
                    uploadRequest?.addMultipartData(gifData, withName: "pic", type: "image/gif", filename: nil)
                    
                    uploadRequest?.perform(handler: { (data, response, error) in
                        
                        debugPrint("\n=======Weibo======response=======\n\(response)\n\(error)")
                        
                        if let error = error {
                            ATAlert.alert(type: .shareFailed(error.localizedDescription), style: .toast)
                            
                        } else {
                            
                            ATAlert.alert(type: .shareSuccess, style: .toast)
                        }
                    })
                    
                default:
                    break
                }
                
            } else {
                
                ATAlert.alert(type: .shareFailed("no gif data"), style: .toast)
            }
        }
    }
}
