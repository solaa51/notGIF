//
//  AccountTableViewController.swift
//  notGIF
//
//  Created by Atuooo on 13/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import Accounts

private let cellID = "reuseIdentifier"

class AccountTableViewController: UITableViewController {
    fileprivate var composeVC: ComposeViewController!
    
    init(in viewController: ComposeViewController) {
        super.init(style: .plain)
        
        self.composeVC = viewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        println(" deinit AccountTableViewControlelr")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tintColor = .black
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return composeVC.accounts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let account = composeVC.accounts[indexPath.item]
        cell.textLabel?.text = account.accountDescription
        cell.accessoryType = account == composeVC.selectedAccount ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        composeVC.selectedAccount = composeVC.accounts[indexPath.item]
        composeVC.reloadConfigurationItems()
        composeVC.popConfigurationViewController()
    }
}
