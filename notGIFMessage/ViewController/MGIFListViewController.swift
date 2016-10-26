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

protocol MGIFListViewControllerDelegate: class {
    func sendGIF(with url: URL)
}

class MGIFListViewController: UIViewController {
    weak var delegate: MGIFListViewControllerDelegate?
    
    fileprivate var indicatorView: IndicatorView? {
        willSet {
            indicatorView?.removeFromSuperview()
        }
    }
    
    fileprivate let gifLibrary = NotGIFLibrary.shared
    fileprivate var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: GIFListLayout(delegate: self))
        collectionView.backgroundColor = .bgColor
        collectionView.register(MGIFListViewCell.self, forCellWithReuseIdentifier: cellID)
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
                self.updateUI()
            }
        })
    }
    
    func updateUI() {
        if gifLibrary.authorizationStatus == .authorized {
            
            defer {
                collectionView.reloadData()
            }
            
            if gifLibrary.isEmpty {
                indicatorView = IndicatorView(for: view, type: .noGIF, isHostApp: false)
                
            } else {
                indicatorView = nil
            }
            
        } else {
            
            indicatorView = IndicatorView(for: view, type: .denied, isHostApp: false)
        }
    }

    deinit {
        gifLibrary.observer = nil
    }
}

// MARK: - Collection Delegate
extension MGIFListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifLibrary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MGIFListViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? MGIFListViewCell else { return }

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
extension MGIFListViewController: NotGIFLibraryChangeObserver {
    func gifLibraryDidChange() {
        DispatchQueue.main.async {
            guard let collectionView = self.collectionView else { return }
            collectionView.reloadData()
        }
    }
}

// MARK: - GIFListLayout Delegate
extension MGIFListViewController: GIFListLayoutDelegate {
    func ratioForImageAtIndexPath(indexPath: IndexPath) -> CGFloat {
        return gifLibrary.gifAssets[indexPath.item].ratio
    }
}
