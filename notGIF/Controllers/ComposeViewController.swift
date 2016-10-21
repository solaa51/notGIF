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
    
    deinit {
        println(" deinit ComposeViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.tintColor = .black
        navigationController?.navigationBar.tintColor = .black
    }
    
    // MARK: - Override SLComposeService
    
    override func loadPreviewView() -> UIView! {
        let img = NotGIFLibrary.shared[imgIndex]?.thumbnail
        let scaledImg = img?.aspectFill(toSize: CGSize(width: 75, height: 75))
        return UIImageView(image: scaledImg)
    }
    
    override func configurationItems() -> [Any]! {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Account"
        item.value = selectedAccount?.accountDescription
        item.tapHandler = { [weak self] in
            let accountTableVC = AccountTableViewController(in: self!)
            self?.pushConfigurationViewController(accountTableVC)
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
        guard let account = selectedAccount else {
            ATAlert.alert(type: .noAccount(title!), in: self, withDismissAction: {
                self.dismiss(animated: true, completion: nil)
            })
            
            return
        }

        SLRequestManager.shareGIF(at: imgIndex, to: account, with: contentText)
        dismiss(animated: true, completion: nil)
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
        
        accountStore.requestAccessToAccounts(with: accountType, options: nil) {[weak self] granted, error in
            guard let sSelf = self else { return }
            
            if granted {
                
                sSelf.accounts = accountStore.accounts(with: accountType) as! [ACAccount]
                
                if sSelf.accounts.isEmpty {
                    
                    ATAlert.alert(type: .noAccount(sSelf.title!), in: sSelf, withDismissAction: {
                        sSelf.dismiss(animated: true, completion: nil)
                    })
                    
                } else {
                    
                    sSelf.selectedAccount = sSelf.accounts.first
                    
                    DispatchQueue.main.async {
                        sSelf.reloadConfigurationItems()
                    }
                }
                
            } else {
                
                ATAlert.alert(type: .acAccessRejected(sSelf.title!), in: sSelf, withDismissAction: {
                    sSelf.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}
