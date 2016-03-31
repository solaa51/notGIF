//
//  GifViewController.swift
//  GifViewer
//
//  Created by Atuooo on 9/10/15.
//  Copyright © 2015 atuooo. All rights reserved.

import UIKit
import ImageIO
import Photos
import LTMorphingLabel

private let reuseIdentifier = "Cell"
private let themeColor  = UIColor.color(withHex: 0x444444, alpha: 0.5)
private let fontColor   = UIColor.color(withHex: 0xFBFBFB, alpha: 0.95)
private let buttonColor = UIColor.grayColor()

class ATGIFViewController: UICollectionViewController {
    
    var precachedGIFs = [YLGIFImage]()
    var gifLibrary    = GIFLibrary()
    
    var refreshControl = UIRefreshControl()
    
    var didRefresh = false
    var didShowNoGIF = false
    var didChange = false // set If GIFLibrary Changed
    var isShowing = false // set If show DetailView
    
    var autoPlay = true {
        didSet {
            for cell in self.collectionView?.visibleCells() as! [PhotoCell] {
                autoPlay ? cell.imageView.startAnimating() : cell.imageView.stopAnimating()
                cell.shouldPlay = self.autoPlay ? true : false
            }
        }
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = themeColor
        collectionView?.alwaysBounceVertical = true // set to show refreshControl when having little images
        collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
        // set layout
        if let layout = collectionView?.collectionViewLayout as? ATGIFLayout {
            layout.delegate = self
        }
        
        setNavigation()
        
        refreshControl.tintColor = UIColor.clearColor()
        self.collectionView?.addSubview(refreshControl)
        
        // observer GIFs and update the UI
        gifLibrary.registerChangeObserver(self)
        updateUI()
    }
    
    deinit {
        refreshControl.removeFromSuperview()
    }
    
}

// MARK: - UICollectionViewDataSource

extension ATGIFViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return precachedGIFs.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCell
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            cell.shouldPlay = self.autoPlay ? true : false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = self.precachedGIFs[indexPath.item]
                cell.imageView.highlighted = true
                self.autoPlay ? cell.imageView.startAnimating() : cell.imageView.stopAnimating()
            })
        })
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ATGIFViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        let frame = self.collectionView!.convertRect(cell.frame, toView: self.view)
        
        let popView = PopDetailView.init(frame: frame, inView: self.view, ofView: self.collectionView!, theCell: cell)
        self.view.addSubview(popView)
        
        popView.showAnimation()
        isShowing = true
        popView.delegate = self
    }
}

// MARK:- ATGIFLayout Delegate

extension ATGIFViewController: ATGIFLayoutDelegate {
    func collectionView(collectionView:UICollectionView, sizeForPhotoAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return precachedGIFs[indexPath.item].size
    }
    
    func collectionView(collectionView: UICollectionView, sizesForPhotosAtSameRow indexPath: NSIndexPath) -> [CGSize] {
        if indexPath.item == precachedGIFs.count - 1 {
            return [precachedGIFs[indexPath.item].size]
        } else {
            let image0 = precachedGIFs[indexPath.item].size
            let image1 = precachedGIFs[indexPath.item+1].size
            return [image0, image1]
        }
    }
}

// MARK: - PopDetailView Delegate
extension ATGIFViewController: DetailViewDelegate {
    func didDismissDetailView() { // 防止当在显示 detailView 时 updateUI，UI会混乱
        if didChange {
            updateUI()
            didChange = false
            isShowing = false
        }
    }
}

// MARK: - Pull To Refresh Delegate

extension ATGIFViewController: PullToRefreshLabelViewDelegate {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if refreshControl.refreshing {
            if !didRefresh {     // To sure only show refresh view once
                let refreshView = PullToRefreshLabelView(frame: CGRectMake(0, 0, self.view.frame.width, refreshControl.frame.height))
                refreshView.delegate = self
                refreshControl.addSubview(refreshView)
                didRefresh = true
                collectionView?.scrollEnabled = false
            }
        } else {
            collectionView?.scrollEnabled = true
            if didRefresh {
                didRefresh = false
            }
        }
    }
    
    // PullToRefreshLabelView Delegate
    
    func refreshLabelViewDidComplete() {
        refreshControl.endRefreshing()
    }
}


// MARK: - GIF Library Change Observer

extension ATGIFViewController: GIFLibraryChangeObserver {
    
    func gifLibraryDidChange() {
        if isShowing {
            didChange = true
        } else {
            updateUI()
        }
    }
    
    func updateUI() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if status == .Authorized {
                    let hud = MBProgressHUD(view: self.view)
                    self.view.addSubview(hud)
                    hud.dimBackground = true
                    
                    hud.showAnimated(true, whileExecutingBlock: { [unowned self] in
                        self.preCacheGIFs(self.gifLibrary.fetchGIFData())
                        self.collectionView?.reloadData()
                        self.collectionView?.collectionViewLayout.invalidateLayout()
                    }, onQueue: dispatch_get_main_queue(), completionBlock: {
                        hud.removeFromSuperview()
                    })
                }
            })
        }
    }
    
    func preCacheGIFs(gifDatas: [NSData]) {
        for data in gifDatas {
            let gif = YLGIFImage(data: data)
            precachedGIFs.append(gif!)
        }
    }
}

// MARK: - Set Navigation

extension ATGIFViewController {

    func setAutoPlayButton() {
        let autoPlayButton = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(ATGIFViewController.diaTapAutoPlayButton))
        self.navigationItem.setRightBarButtonItem(autoPlayButton, animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = buttonColor
    }
    
    func diaTapAutoPlayButton() {
        autoPlay = !autoPlay
        if autoPlay {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(ATGIFViewController.diaTapAutoPlayButton))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(ATGIFViewController.diaTapAutoPlayButton))
        }
        self.navigationItem.rightBarButtonItem?.tintColor = buttonColor
    }
    
    func setNavigation() {
        
        setAutoPlayButton()
        
        self.navigationItem.title = "/jif/"

        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Kenia-Regular", size: 26)!, //Bradley Hand
            NSForegroundColorAttributeName: fontColor]
    }
}











