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
        
        allPhotos.enumerateObjects({ [weak self] asset, index, shouldStop in
            PHImageManager.default().requestImageData(for: asset, options: requestOptions, resultHandler: { (data, UTI, orientation, info) in
                if let uti = UTI, UTTypeConformsTo(uti as CFString , kUTTypeGIF),
                   let gifData = data, let gif = NotGIFImage(data: gifData), let sSelf = self {

                    sSelf.gifAssets.append(asset)
                    sSelf.gifs.append(gif)
                }
            })
        })
        
        return gifs
    }
    
    func requestGIFData(at index: Int, doneHandler: @escaping (Data?, String?) -> Void) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .unadjusted
        
        PHImageManager.default().requestImageData(for: gifAssets[index], options: requestOptions) { (data, UTI, orientation, info) in
            doneHandler(data, UTI)
        }
    }
    
    private init() {  }
}
