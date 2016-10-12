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
    var currentIndex: IndexPath!

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
        
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifs = NotGIFLibrary.shared.gifs
        makeUI()
    }
    
    private func makeUI() {
        
        automaticallyAdjustsScrollViewInsets = false
        
        infoLabel = GIFInfoLabel(info: gifs[currentIndex.item].gifInfo)
        navigationItem.titleView = infoLabel
//        navigationItem.backBarButtonItem?.title = ""
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -60), for: .default)

        collectionView.scrollToItem(at: currentIndex, at: .left, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addSubview(shareBar)
    }
    
    deinit {
        println(" deinit GIFDetailViewController ")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let index = Int(scrollView.contentOffset.x / kScreenWidth)
        infoLabel.info = gifs[index].gifInfo
    }
}
