//
//  ComposeViewController.swift
//  notGIF
//
//  Created by Atuooo on 13/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import Social
import Accounts

class ComposeViewController: SLComposeServiceViewController {
    public var accounts = [ACAccount]()
    public var selectedAccount: ACAccount? = nil

    fileprivate var shareType: ShareType!
    fileprivate var imgIndex: Int!
    
    convenience init(shareType: ShareType, imgIndex: Int) {
        self.init()
        
        self.shareType = shareType
        self.imgIndex = imgIndex
        
        getAccounts(of: shareType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.tintColor = UIColor.black
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    // MARK: - Override SLComposeService
    
    override func loadPreviewView() -> UIView! {
        let img = NotGIFLibrary.shared.gifs[imgIndex].thumbnail
        let scaledImg = img.aspectFill(toSize: CGSize(width: 75, height: 75))
        return UIImageView(image: scaledImg)
    }
    
    override func configurationItems() -> [Any]! {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Account"
        item.value = selectedAccount?.username
        item.tapHandler = {
            let accountTableVC = AccountTableViewController(in: self)
            self.pushConfigurationViewController(accountTableVC)
        }
        return [item]
    }
    
    override func isContentValid() -> Bool {
        let remainingCount = 140 - contentText.characters.count
        charactersRemaining =  NSNumber(value: remainingCount)
        return remainingCount < 0 ? false : true
    }
    
    override func didSelectCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didSelectPost() {
        sendRequest(to: shareType)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Send Request
    private func sendRequest(to type: ShareType) {
        
        NotGIFLibrary.shared.requestGIFData(at: imgIndex) { gifData in
            switch type {
                
            case .twitter: // Doc: https://dev.twitter.com/rest/reference/post/media/upload
                // 先上传 media 获取 media_id
                let uploadURL = URL(string: "https://upload.twitter.com/1.1/media/upload.json")!
                let dataString = gifData.base64EncodedString(options: .lineLength64Characters)
                
                let getMediaIDRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: uploadURL, parameters: ["media": dataString])
                getMediaIDRequest?.account = self.selectedAccount
                
                getMediaIDRequest?.perform(handler: { (data, response, error) in
                    if let error = error {
                        println(error.localizedDescription)
                    } else {
                        if let data = data,
                            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                            let mediaID = json?["media_id_string"] as? String {
                            
                            var parameters = Dictionary<String, String>()
                            parameters["status"] = self.contentText
                            parameters["media_ids"] = mediaID
                            
                            // tweet
                            let tweetURL = URL(string: "https://api.twitter.com/1.1/statuses/update.json")!
                            let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: tweetURL, parameters: parameters)
                            tweetRequest?.account = self.selectedAccount
                            tweetRequest?.perform(handler: { (data, response, error) in
                                print(data, response, error)
                            })
                        } else {
                            
                        }
                    }
                })
                
            case .weibo:    // Doc: http://open.weibo.com/wiki/2/statuses/upload
                let uploadURL = URL(string: "https://upload.api.weibo.com/2/statuses/upload.json")!
                let uploadRequest = SLRequest(forServiceType: SLServiceTypeSinaWeibo, requestMethod: .POST, url: uploadURL, parameters: ["status": self.contentText])
                uploadRequest?.account = self.selectedAccount
                uploadRequest?.addMultipartData(gifData, withName: "pic", type: "image/gif", filename: nil)
                
                uploadRequest?.perform(handler: { (data, response, error) in
                    if let error = error {
                        
                    } else {
                        
                    }
                })

            default:
                break
            }
        }
    }
    
    // MARK: - Get Account
    private func getAccounts(of type: ShareType) {
        let accountStore = ACAccountStore()
        var accountType = ACAccountType()
        
        switch type {
        case .twitter:
            accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        case .weibo:
            accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierSinaWeibo)
        default:
            break
        }
        
        title = accountType.accountTypeDescription
        
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { granted, error in
            if granted {
                
                self.accounts = accountStore.accounts(with: accountType) as! [ACAccount]
                
                if self.accounts.isEmpty {
                    
                    ATAlert.alert(type: .noAccount(self.title!), in: self, withDismissAction: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                } else {
                    
                    self.selectedAccount = self.accounts.first
                    
                    DispatchQueue.main.async {
                        self.reloadConfigurationItems()
                    }
                }
                
            } else {
                
                ATAlert.alert(type: .acAccessRejected(self.title!), in: self, withDismissAction: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}
