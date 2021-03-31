//
//  PHFetchResult + IndexPath.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation
import Photos

internal extension PHFetchResult where ObjectType == PHAsset {
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 { return [] }
        var assets: [PHAsset] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            let asset = self[indexPath.item]
            assets.append(asset)
        }
        return assets
    }
}

internal extension PHFetchResult {
    
    @objc func adjustedIndex(_ index: Int) -> Int {
        return count - index - 1
    }
    
    @objc func assetAtIndex(_ index: Int) -> ObjectType {
        // Reverse order
        return self[adjustedIndex(index)]
    }
    
}
