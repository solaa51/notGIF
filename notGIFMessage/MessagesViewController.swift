//
//  MessagesViewController.swift
//  notGIFMessage
//
//  Created by Atuooo on 23/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    fileprivate var gifViewControler = GIFListViewController()
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        
        if !childViewControllers.contains(gifViewControler) {
            
            gifViewControler.delegate = self
            addChildViewController(gifViewControler)
            
            gifViewControler.view.frame = view.bounds
            gifViewControler.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(gifViewControler.view)
            
            gifViewControler.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            gifViewControler.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            gifViewControler.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            gifViewControler.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            gifViewControler.didMove(toParentViewController: self)
        }
    }
}

extension MessagesViewController: GIFListViewControllerDelegate {

    func sendGIF(with url: URL) {
        guard let conversation = activeConversation else { return }
        
        conversation.insertAttachment(url, withAlternateFilename: nil) { error in
            
        }
    }
}
