//
//  ATAlert.swift
//  notGIF
//
//  Created by Atuooo on 13/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

public enum AlertType {
    case noApp(String)
    case noAccount(String)
    case acAccessRejected(String)
    case shareFailed(String)
    case shareSuccess
    case noInternet
}

public enum AlertStyle {
    case alert
    case toast
}

final class ATAlert {

//    class func alert(type: AlertType, style: AlertStyle) {
//        if style == .toast {
//            DispatchQueue.main.async {
//                var message = "", isError = false
//                switch type {
//                    case .shareFailed(let error):
//                        message = "failed: \(error)"
//                        isError = true
//                    case .shareSuccess:
//                        message = "Send successfully"
//                    default:
//                        return
//                }
//                
//                StatusBarToast.shared.show(message: message, isError: isError)
//            }
//            
//        } else {
//                        
//        }
//    }
    
    class func alert(type: AlertType, in viewController: UIViewController, withDismissAction dismissAction: (() -> Void)?) {
        var title = "", message = ""
        var dismissTitle = "Get it"

        switch type {
        case .noAccount(let accountType):
            title = "No \(accountType) Account Found"
            message = "There are no \(accountType) accounts configured. You can add or create a \(accountType) account in \n 'Settings' -> '\(accountType)"
            
        case .acAccessRejected(let accountType):
            title = "Can't Access Your Account"
            message = "You can set in \n 'Settings' -> 'Privacy' -> '\(accountType)' \n to allow access to your account"
        
        case .noApp(let appName):
            title = "You haven't installed \(appName)"
            dismissTitle = "OK"
            
        case .noInternet:
            title = "No Internet. Can't Share"
            message = "You are not connected to the internet!"
            
        default:
            break
        }
        
        alert(title: title, message: message, dismissTitle: dismissTitle, in: viewController, withDismissAction: dismissAction)
    }

    class func alert(title: String, message: String?, dismissTitle: String, in viewController: UIViewController?, withDismissAction dismissAction: (() -> Void)?) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action: UIAlertAction = UIAlertAction(title: dismissTitle, style: .default) { action in
                if let dismissAction = dismissAction {
                    dismissAction()
                }
            }
            alertController.addAction(action)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func tellYou(message: String, in viewController: UIViewController?) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { action in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(action)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func confirmOrCancel(title: String, message: String, confirmTitle: String = "确定", cancelTitle: String = "取消", in viewController: UIViewController?, withConfirmAction confirmAction: @escaping () -> Void, cancelAction: @escaping () -> Void = { }) {
        
        DispatchQueue.main.async {

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancelAction()
            }
            alertController.addAction(cancelAction)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { action in
                confirmAction()
            }
            alertController.addAction(confirmAction)
            
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
}


