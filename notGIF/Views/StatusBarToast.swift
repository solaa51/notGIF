//
//  StatusAlert.swift
//  3DTest
//
//  Created by Atuooo on 14/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

private let statusHeight = UIApplication.shared.statusBarFrame.height

final class StatusBarToast {
    static let shared = StatusBarToast()
    
    fileprivate var toastWindow: ToastWindow!
    fileprivate var messageLabel: UILabel!
    fileprivate var statusView: UIView!
    fileprivate var dismissWortItem: DispatchWorkItem!
    
    fileprivate var showing = false
    fileprivate var dismissing = false
    
    func show(message: String, isError: Bool = false) {
        if !showing {
            showing = true
            makeToastUI()
            
            messageLabel.text = message
            messageLabel.backgroundColor = isError ? .red : .blue
            toastWindow.rootViewController?.view.addSubview(statusView)
            toastWindow.rootViewController?.view.addSubview(messageLabel)
            
            toastWindow.isHidden = false
            
            dismissWortItem = DispatchWorkItem(block: { [weak self] in
                self!.dismissing = true
                self?.dismissToast()
            })
            
            UIView.animate(withDuration: 0.3, animations: {
                self.statusView.frame = CGRect(x: 0, y: statusHeight, width: kScreenWidth, height: 0)
                self.messageLabel.frame.origin = CGPoint(x: 0, y: 0)
                
            }) { done in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: self.dismissWortItem)
            }
        }
    }
    
    @objc private func didTap(sender: UITapGestureRecognizer) {
        if !dismissing {
            dismissWortItem.cancel()
            dismissToast()
        }
    }
    
    private func dismissToast() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.statusView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: statusHeight)
            self.messageLabel.frame.origin = CGPoint(x: 0, y: -statusHeight)
        }) { done in
                
            self.toastWindow.isHidden = true
            self.messageLabel.removeFromSuperview()
            self.statusView.removeFromSuperview()
            self.messageLabel = nil
            self.statusView = nil
            self.toastWindow = nil
            self.dismissWortItem = nil
            self.showing = false
            self.dismissing = false
        }
    }
    
    private func makeToastUI() {
        toastWindow = ToastWindow(frame: UIScreen.main.bounds)
        toastWindow.windowLevel = UIWindowLevelStatusBar
        toastWindow.backgroundColor = .clear
        toastWindow.isUserInteractionEnabled = true
        toastWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toastWindow.rootViewController = UIViewController()
        
        messageLabel = UILabel(frame: CGRect(x: 0, y: -statusHeight, width: kScreenWidth, height: statusHeight))
        messageLabel.isUserInteractionEnabled = true
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.backgroundColor = .blue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StatusBarToast.didTap(sender:)))
        messageLabel.addGestureRecognizer(tapGesture)
        
//        var snapView: UIView!
//        DispatchQueue.main.sync {
//            snapView = UIScreen.main.snapshotView(afterScreenUpdates: true)
//        }
        
        let snapView = UIScreen.main.snapshotView(afterScreenUpdates: true)

        statusView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: statusHeight))
        statusView.layer.masksToBounds = true
        statusView.addSubview(snapView)
    }
    
    private init() {}
}

private class ToastWindow: UIWindow {
    private override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if UIApplication.shared.statusBarFrame.contains(point) {
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}



