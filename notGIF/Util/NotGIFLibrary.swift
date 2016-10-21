//
//  NotGIFLibrary.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import Foundation
import ImageIO
import Photos
import MobileCoreServices

//typealias NotGIFLibraryChangeResult = (removed: IndexSet, inserted: IndexSet)

protocol NotGIFLibraryChangeObserver: NSObjectProtocol {
    func gifLibraryDidChange()
}

class NotGIFLibrary: NSObject {
    static let shared = NotGIFLibrary()
    weak var observer: NotGIFLibraryChangeObserver?

    var gifAssets = [PHAsset]()

    var count: Int {
        return gifAssets.count
    }
    
    subscript(index: Int) -> NotGIFImage? {
        return gifPool[gifAssets[index].localIdentifier]
    }
    
    fileprivate var gifPool = [String: NotGIFImage]()
    fileprivate var fetchResult: PHFetchResult<PHAsset>!
    
    func getGIFLibrary() -> NotGIFLibrary {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        fetchResult.enumerateObjects(options: .concurrent) { [weak self] asset, index, shouldStop in
            guard let sSelf = self else { return }
            if asset.isGIF {
                sSelf.gifAssets.append(asset)
            }
        }
        
        return self
    }
    
    func requestGIFData(at index: Int, doneHandler: @escaping (Data?, String?) -> Void) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.version = .original
        
        PHImageManager.default().requestImageData(for: gifAssets[index], options: requestOptions) { (data, UTI, orientation, info) in
            doneHandler(data, UTI)
        }
    }
    
    func getGIFImage(at index: Int, doneHandler: @escaping (NotGIFImage) -> Void) {
        let gifKey = gifAssets[index].localIdentifier
        
        if let gif = gifPool[gifKey] {
            doneHandler(gif)
        } else {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.version = .original
            
            PHImageManager.default().requestImageData(for: gifAssets[index], options: requestOptions) { (data, UTI, orientation, info) in
                if let uti = UTI, UTTypeConformsTo(uti as CFString , kUTTypeGIF),
                    let gifData = data, let gif = NotGIFImage(data: gifData) {
                    
                    self.gifPool[gifKey] = gif
                    doneHandler(gif)
                }
            }
        }
    }
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension NotGIFLibrary: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        fetchResult = changes.fetchResultAfterChanges
        
        if changes.hasIncrementalChanges {
            
            let removedGIF = changes.removedObjects.filter({ $0.isGIF })
            let insertedGIF = changes.insertedObjects.filter({ $0.isGIF })
            
            if !removedGIF.isEmpty || !insertedGIF.isEmpty {    // curt
                
                gifAssets.removeAll()
                
                fetchResult.enumerateObjects(options: .concurrent, using: { [weak self] asset, index, shouldStop in
                    guard let sSelf = self else { return }
                    if asset.isGIF {
                        sSelf.gifAssets.append(asset)
                    }
                })
                
                observer?.gifLibraryDidChange()
            }
        }
    }
}

extension PHAsset {
    var ratio: CGFloat {
        return CGFloat(pixelWidth) / CGFloat(pixelHeight)
    }
    
    var isGIF: Bool {
        guard let assetSource = PHAssetResource.assetResources(for: self).first else {
            return false
        }
        
        let uti = assetSource.uniformTypeIdentifier as CFString
        return UTTypeConformsTo(uti, kUTTypeGIF) || assetSource.originalFilename.hasSuffix("GIF")
    }
}
