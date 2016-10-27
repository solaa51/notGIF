//
//  GIFDetailViewController.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import MessageUI
import MBProgressHUD
import ReachabilitySwift
import MobileCoreServices

private let cellID = "GIFDetailViewCell"
private let tmpInfo = "xx Frames\nxx s / xxx"

class GIFDetailViewController: UIViewController {
    var currentIndex: Int!

    fileprivate var gifLibrary = NotGIFLibrary.shared
    fileprivate var infoLabel: GIFInfoLabel!
    fileprivate var collectionView: UICollectionView!

    fileprivate var isHideBar = false {
        didSet {
            shareBar.isHidden = isHideBar
            navigationController?.setNavigationBarHidden(isHideBar, animated: true)
        }
    }
    
    fileprivate lazy var shareBar: GIFShareBar = {
        let bar = GIFShareBar()
        bar.shareHandler = { [weak self] shareType in
            self?.shareGIF(to: shareType)
        }
        return bar
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addSubview(shareBar)
    }
    
    private func makeUI() {
        
        automaticallyAdjustsScrollViewInsets = false
        
        infoLabel = GIFInfoLabel(info: gifLibrary[currentIndex]?.gifInfo ?? tmpInfo)
        navigationItem.titleView = infoLabel
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .bgColor
        collectionView.register(GIFDetailViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.reloadData()
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    deinit {
        println(" deinit GIFDetailViewController ")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .left, animated: false)
    }
    
    func updateUI() {
        func updateInfoLabel() {
            currentIndex = Int(collectionView.contentOffset.x / kScreenWidth)
            infoLabel.info = gifLibrary[currentIndex]?.gifInfo ?? tmpInfo
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            updateInfoLabel()
        }
        
        collectionView.reloadData()
        CATransaction.commit()
    }
    
    // MARK: - Share GIF
    private func shareGIF(to type: ShareType) {
        switch type {
            
        case .twitter, .weibo:
            if let reachability = Reachability(), reachability.isReachable {
                if let gifInfo = gifLibrary.getDataInfo(at: currentIndex) {
                    let composeVC = ComposeViewController(shareType: type, with: gifInfo)
                    composeVC.modalPresentationStyle = .overCurrentContext
                    present(composeVC, animated: true, completion: nil)
                } else {
                    StatusBarToast.shared.show(info: .once(message: "unavailable data, try again", succeed: false))
                }
                
            } else {
                ATAlert.alert(type: .noInternet, in: self, withDismissAction: nil)
            }
            
        case .wechat:
            if OpenShare.canOpen(platform: .wechat) {
                if let gifInfo = gifLibrary.getDataInfo(at: currentIndex) {
                    OpenShare.shareGIF(to: .wechat, with: gifInfo)
                } else {
                    StatusBarToast.shared.show(info: .once(message: "unavailable data, try again", succeed: false))
                }
            } else {
                ATAlert.alert(type: .noApp("Wechat"), in: self, withDismissAction: nil)
            }
            
        case .more:
            
            MBProgressHUD.showAdded(to: view, with: "Preparing")

            NotGIFLibrary.shared.requestGIFData(at: currentIndex) { data in
                if let gifData = data {
                    let activityVC = UIActivityViewController(activityItems: [gifData], applicationActivities: nil)
                    DispatchQueue.main.async {
                        self.present(activityVC, animated: true, completion: nil)
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    StatusBarToast.shared.show(info: .once(message: "unavailable data, try again", succeed: false))
                }
            }

        case .message:
            
            if MFMessageComposeViewController.canSendAttachments() &&
                MFMessageComposeViewController.isSupportedAttachmentUTI(kUTTypeGIF as String) {
                
                MBProgressHUD.showAdded(to: view, with: "Prepareing")
                
                NotGIFLibrary.shared.requestGIFData(at: currentIndex) { data in
                    
                    if let gifData = data {
                        
                        let messageVC = MFMessageComposeViewController()
                        messageVC.messageComposeDelegate = self
                        messageVC.addAttachmentData(gifData, typeIdentifier: kUTTypeGIF as String, filename: "not.gif")
                        DispatchQueue.main.async {
                            self.present(messageVC, animated: true, completion: nil)
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        StatusBarToast.shared.show(info: .once(message: "unavailable data, try again", succeed: false))
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionView Delegate
extension GIFDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifLibrary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GIFDetailViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? GIFDetailViewCell else { return }
        
        gifLibrary.getGIFImage(at: indexPath.item) { gif in
            cell.configureWithImage(image: gif)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isHideBar = !isHideBar
    }
}

// MARK: - UIScrollView Delegate
extension GIFDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / kScreenWidth)
        infoLabel.info = gifLibrary[currentIndex]?.gifInfo ?? tmpInfo
    }
}

// MARK: - MessageViewController Delegate
extension GIFDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
