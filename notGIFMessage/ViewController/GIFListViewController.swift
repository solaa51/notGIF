//
//  GIFListViewController.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD

private let cellID = "GIFListViewCell"

protocol GIFListViewControllerDelegate: class {
    func sendGIF(with url: URL)
}

class GIFListViewController: UIViewController {
    weak var delegate: GIFListViewControllerDelegate?
    
    fileprivate let gifLibrary = NotGIFLibrary.shared
    fileprivate var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .bgColor
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: GIFListLayout(delegate: self))
        collectionView.register(GIFListViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        gifLibrary.observer = self
        
        MBProgressHUD.showAdded(to: view, with: "fetching GIFs...",  progressHandler: {
            self.gifLibrary.prepare()
        }, completion: {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    deinit {
        gifLibrary.observer = nil
    }
}

// MARK: - Collection Delegate
extension GIFListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifLibrary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GIFListViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? GIFListViewCell else { return }

        gifLibrary.getGIFImage(at: indexPath.item) { gif in
            DispatchQueue.main.async {
                cell.imageView.image = gif
                cell.imageView.startAnimating()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = gifLibrary.gifAssets[indexPath.item]
        asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
            if let input = eidtingInput, let gifURL = input.fullSizeImageURL {
                self.delegate?.sendGIF(with: gifURL)
            }
        }
    }
}

// MARK: - GIFLibraryChange Observer
extension GIFListViewController: NotGIFLibraryChangeObserver {
    func gifLibraryDidChange() {
        DispatchQueue.main.async {
            guard let collectionView = self.collectionView else { return }
            collectionView.reloadData()
        }
    }
}

// MARK: - GIFListLayout Delegate
extension GIFListViewController: GIFListLayoutDelegate {
    func ratioForImageAtIndexPath(indexPath: IndexPath) -> CGFloat {
        return gifLibrary.gifAssets[indexPath.item].ratio
    }
}
