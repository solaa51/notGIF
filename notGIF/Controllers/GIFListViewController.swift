//
//  GIFListViewController.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import MBProgressHUD

private let cellID = "GIFListViewCell"

class GIFListViewController: UIViewController {
    fileprivate let gifLibrary = NotGIFLibrary.shared
    fileprivate var collectionView: UICollectionView!
    
    fileprivate var indicatorView: IndicatorView? {
        willSet {
            indicatorView?.removeFromSuperview()
        }
    }
    
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
        
        view.backgroundColor = .bgColor
        navigationItem.title = ""
        edgesForExtendedLayout = []
        navigationItem.titleView = titleLabel
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(autoplayItemClicked))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: GIFListLayout(delegate: self))
        collectionView.backgroundColor = .bgColor
        collectionView.register(GIFListViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        gifLibrary.observer = self
        MBProgressHUD.showAdded(to: navigationController!.view, with: "fetching GIFs...",  progressHandler: {
            self.gifLibrary.prepare()
        }, completion: {
            DispatchQueue.main.async {
                self.updateUI()
            }
        })
        
        #if DEBUG
            view.addSubview(FPSLabel())
        #endif
    }
    
    func updateUI() {
        defer {
            collectionView.reloadData()
        }
                
        if gifLibrary.authorizationStatus == .authorized {
            
            if gifLibrary.isEmpty {
                indicatorView = IndicatorView(for: view, type: .noGIF)
                
            } else {
                indicatorView = nil
            }
            
        } else {
            indicatorView = IndicatorView(for: view, type: .denied)
        }
        
        if let detailVC = self.navigationController?.topViewController as? GIFDetailViewController {
            if gifLibrary.isEmpty {
                detailVC.dismiss(animated: true, completion: nil)
            } else {
                detailVC.updateUI()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasPaused {
            shouldPlay = true
        }
    }
    
    deinit {
        gifLibrary.observer = nil
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
                self.shouldPlay ? cell.imageView.startAnimating() : cell.imageView.stopAnimating()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = GIFDetailViewController()
        detailVC.currentIndex = indexPath.item
        shouldPlay = false
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - GIFLibraryChange Observer
extension GIFListViewController: NotGIFLibraryChangeObserver {
    func gifLibraryDidChange() {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}

// MARK: - GIFListLayout Delegate
extension GIFListViewController: GIFListLayoutDelegate {
    func ratioForImageAtIndexPath(indexPath: IndexPath) -> CGFloat {
        return gifLibrary.gifAssets[indexPath.item].ratio
    }
}
