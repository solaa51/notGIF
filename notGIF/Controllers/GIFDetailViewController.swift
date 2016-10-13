//
//  GIFDetailViewController.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

private let cellID = "GIFDetailViewCell"

class GIFDetailViewController: UIViewController {
    var currentIndex: Int!

    fileprivate var collectionView: UICollectionView!
    fileprivate var gifs = [NotGIFImage]()
    
    fileprivate var infoLabel: GIFInfoLabel!

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
        
        gifs = NotGIFLibrary.shared.gifs
        makeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addSubview(shareBar)
    }
    
    private func makeUI() {
        
        automaticallyAdjustsScrollViewInsets = false
        
        infoLabel = GIFInfoLabel(info: gifs[currentIndex].gifInfo)
        navigationItem.titleView = infoLabel
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(GIFDetailViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .left, animated: false)
    }
    
    deinit {
        println(" deinit GIFDetailViewController ") 
    }
    
    // MARK: - Share GIF
    private func shareGIF(to type: ShareType) {
        let composeVC = ComposeViewController(shareType: type, imgIndex: currentIndex)
        composeVC.modalPresentationStyle = .overCurrentContext
        present(composeVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate
extension GIFDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GIFDetailViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? GIFDetailViewCell else { return }
        
        cell.configureWithImage(image: gifs[indexPath.item])
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
        infoLabel.info = gifs[currentIndex].gifInfo
    }
}
