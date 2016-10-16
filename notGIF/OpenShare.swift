//
//  OpenShare.swift
//  notGIF
//
//  Created by Atuooo on 16/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import MobileCoreServices

public enum Platform: String {
    case wechat = "weixin://"
    
    var url: URL {
        return URL(string: rawValue)!
    }
    
    var appID: String {
        switch self {
        case .wechat:
            return "wxb073e64ef4cef14f"
        }
    }
}

final class OpenShare {
    
    class func canOpen(platform: Platform) -> Bool {
        
        switch platform {
        case .wechat:
            return UIApplication.shared.canOpenURL(platform.url)
        }
    }
    
    class func shareGIF(at index: Int, to platform: Platform) {
        NotGIFLibrary.shared.requestGIFData(at: index) { (data, UTI) in
            if let gifData = data, let uti = UTI, UTTypeConformsTo(uti as CFString, kUTTypeGIF),
                let thumbData = NotGIFLibrary.shared.gifs[index].thumbnail.monkeyking_compressedImageData {
                
                switch platform {
                case .wechat:
                    var wechatMessageInfo: [String: Any] = [
                        "result": "1",
                        "returnFromApp": "0",
                        "scene": "0",
                        "sdkver": "1.5",
                        "command": "1010",
                    ]
                    
                    wechatMessageInfo["objectType"] = "8"   // emoticon
                    wechatMessageInfo["thumbData"] = thumbData
                    wechatMessageInfo["fileData"] = gifData
                    
                    let wechatMessage = [platform.appID: wechatMessageInfo]
                    guard let messageData = try? PropertyListSerialization.data(fromPropertyList: wechatMessage, format: .binary, options: 0) else {
                        ATAlert.alert(type: .shareFailed("unavailable data"), style: .toast)
                        return
                    }
                    
                    UIPasteboard.general.setData(messageData, forPasteboardType: "content")
                    
                    let openURL = URL(string: "weixin://app/\(platform.appID)/sendreq/?")!
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(openURL)
                    }
                }
                
            } else {
                ATAlert.alert(type: .shareFailed("unavailable data"), style: .toast)
            }
        }
    }
}

private extension UIImage {
    
    var monkeyking_compressedImageData: Data? {
        
        var compressionQuality: CGFloat = 0.7
        
        func compressedDataOfImage(_ image: UIImage) -> Data? {
            
            let maxHeight: CGFloat = 240.0
            let maxWidth: CGFloat = 240.0
            var actualHeight: CGFloat = image.size.height
            var actualWidth: CGFloat = image.size.width
            var imgRatio: CGFloat = actualWidth/actualHeight
            let maxRatio: CGFloat = maxWidth/maxHeight
            
            if actualHeight > maxHeight || actualWidth > maxWidth {
                
                if imgRatio < maxRatio { // adjust width according to maxHeight
                    
                    imgRatio = maxHeight / actualHeight
                    actualWidth = imgRatio * actualWidth
                    actualHeight = maxHeight
                    
                } else if imgRatio > maxRatio { // adjust height according to maxWidth
                    
                    imgRatio = maxWidth / actualWidth
                    actualHeight = imgRatio * actualHeight
                    actualWidth = maxWidth
                    
                } else {
                    actualHeight = maxHeight
                    actualWidth = maxWidth
                }
            }
            
            let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
            UIGraphicsBeginImageContext(rect.size)
            defer {
                UIGraphicsEndImageContext()
            }
            image.draw(in: rect)
            
            let imageData = UIGraphicsGetImageFromCurrentImageContext().flatMap({
                UIImageJPEGRepresentation($0, compressionQuality)
            })
            return imageData
        }
        
        let fullImageData = UIImageJPEGRepresentation(self, compressionQuality)
        
        guard var imageData = fullImageData else {
            return nil
        }
        
        let minCompressionQuality: CGFloat = 0.01
        let dataLengthCeiling: Int = 31500
        
        while imageData.count > dataLengthCeiling && compressionQuality > minCompressionQuality {
            
            compressionQuality -= 0.1
            
            guard let image = UIImage(data: imageData) else {
                break
            }
            
            if let compressedImageData = compressedDataOfImage(image) {
                imageData = compressedImageData
            } else {
                break
            }
        }
        
        return imageData
    }
}

