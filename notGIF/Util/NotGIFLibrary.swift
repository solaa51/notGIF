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

class NotGIFLibrary {
    static let shared = NotGIFLibrary()
    
    var allPhotos: PHFetchResult<PHAsset>!
    var gifAssets = [PHAsset]()
    var gifs = [NotGIFImage]()
    
    func checkGIFFromPhotos() -> [NotGIFImage] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.version = .unadjusted
        
//        var gifs = [NotGIFImage]()
        allPhotos.enumerateObjects({ [weak self] asset, index, shouldStop in
            PHImageManager.default().requestImageData(for: asset, options: requestOptions, resultHandler: { (data, UTI, orientation, info) in
                if UTTypeConformsTo(UTI as! CFString , kUTTypeGIF) {
                    if let sSelf = self,
                       let gifData = data,
                       let gif = NotGIFImage(data: gifData) {
                        sSelf.gifAssets.append(asset)
                        sSelf.gifs.append(gif)
                    }
                }
            })
        })
        
        return gifs
    }
    
    private init() {  }
}
