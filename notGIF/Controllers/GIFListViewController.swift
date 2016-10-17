//
//  GIFListViewController.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

private let cellID = "GIFListViewCell"

class GIFListViewController: UIViewController {
    fileprivate var gifs = [NotGIFImage]()
    fileprivate var collectionView: UICollectionView!
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.text = "/jif/"
        label.textColor = .tintColor
        label.textAlignment = .center
        label.font = UIFont(name: "Kenia-Regular", size: 26)
        return label
    }()
    
    fileprivate var hasPaused = false
    fileprivate var shouldPlay = true {
        didSet {
            if shouldPlay != oldValue {
                for cell in collectionView.visibleCells {
                    if let cell = cell as? GIFListViewCell {
                        shouldPlay ? cell.imageView.startAnimating() : cell.imageView.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        navigationItem.titleView = titleLabel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(autoplayItemClicked))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        
        gifs = NotGIFLibrary.shared.checkGIFFromPhotos()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: GIFListLayout(delegate: self))
        collectionView.register(GIFListViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        #if DEBUG
            view.addSubview(FPSLabel())
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !gifs.isEmpty && !hasPaused {
            shouldPlay = true
        }
    }
    
    func autoplayItemClicked() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: shouldPlay ? .play : .pause, target: self, action: #selector(autoplayItemClicked))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        hasPaused = shouldPlay
        shouldPlay = !shouldPlay
    }
}

// MARK: - Collection Delegate
extension GIFListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GIFListViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? GIFListViewCell else { return }
        
        DispatchQueue.main.async {
            cell.imageView.image = self.gifs[indexPath.item]
            self.shouldPlay ? cell.imageView.startAnimating() : cell.imageView.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = GIFDetailViewController()
        detailVC.currentIndex = indexPath.item
        shouldPlay = false
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - GIFListLayout Delegate
extension GIFListViewController: GIFListLayoutDelegate {
    func ratioForImageAtIndexPath(indexPath: IndexPath) -> CGFloat {
        return gifs[indexPath.item].ratio
    }
}
