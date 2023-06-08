//
//  Helpers.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Foundation
import Photos
import SwiftUI

/// Returns a list of all the images in the Photos Library.
func getAllPhotos() -> [PHAsset] {
    var photos: [PHAsset] = []
    
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    
    PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        .enumerateObjects({ (asset, _, _) in
            photos.append(asset)
        })
    
    return photos
}

extension PHAsset {
    /// Returns a list of all the albums that contain this asset.
    func albums() -> [PHAssetCollection] {
        var result: [PHAssetCollection] = []
        
        PHAssetCollection
            .fetchAssetCollectionsContaining(self, with: .album, options: nil)
            .enumerateObjects({ (collection, index, stop) in
                result.append(collection)
            })
        
        return result
    }
    
    func state() -> ReviewState? {
        var result: ReviewState? = nil
        
        self.albums().forEach { album in
            switch (album.localizedTitle) {
                case "Approved":
                    result = .Approved
                case "Rejected":
                    result = .Rejected
                case "Needs Action":
                    result = .NeedsAction
                default:
                    break
            }
        }
        
        return result
    }
    
    private func getImageForSize(size: CGSize) -> NSImage {
        // This implementation is based on code in a Stack Overflow answer
        // by Francois Nadeau: https://stackoverflow.com/a/48755517/1558022

        let options = PHImageRequestOptions()
        
        // do I still need this?
        options.isSynchronous = true

        // If i don't set this value, then sometimes I get an error like
        // this in the `info` variable:
        //
        //      Error Domain=PHPhotosErrorDomain Code=3164 "(null)"
        //
        // This means that the asset is in the cloud, and by default Photos
        // isn't allowed to download assets here.  Apple's documentation
        // suggests adding this option as the fix.
        //
        // See https://developer.apple.com/documentation/photokit/phphotoserror/phphotoserrornetworkaccessrequired
        options.isNetworkAccessAllowed = true

        var image = NSImage()
        
        PHCachingImageManager()
            .requestImage(
                for: self,
                targetSize: size,
                contentMode: .aspectFill,
                options: options,
                resultHandler: { (result, info) -> Void in
                    image = result!
                }
            )

        return image
    }
    
    func getThumbnail() -> NSImage {
        return getImageForSize(size: CGSize(width: 70, height: 70))
    }
    
    func getImage() -> NSImage {
        return getImageForSize(size: PHImageManagerMaximumSize)
    }
    
    /// Returns true if an asset is in the given album, false otherwise.
    func isInAlbum(_ album: PHAssetCollection) -> Bool {
        return albums().contains(where: { collection in
            collection == album
        })
    }
    
    /// Remove a photo from an album.
    ///
    /// This expects to be run inside a performChangesAndWait change block;
    /// see https://developer.apple.com/documentation/photokit/phphotolibrary/1620747-performchangesandwait.
    func remove(fromAlbum album: PHAssetCollection) -> Void {
      let changeAlbum =
        PHAssetCollectionChangeRequest(for: album)!

      changeAlbum.removeAssets([self] as NSFastEnumeration)
    }

    /// Add a photo to an album.
    ///
    /// This expects to be run inside a performChangesAndWait change block;
    /// see https://developer.apple.com/documentation/photokit/phphotolibrary/1620747-performchangesandwait.
    func add(toAlbum album: PHAssetCollection) -> Void {
      let changeAlbum =
        PHAssetCollectionChangeRequest(for: album)!

      changeAlbum.addAssets([self] as NSFastEnumeration)
    }
    
    /// Toggle a photo's inclusion in an album.
    ///
    /// If the photo is already in the album, remove it.  If the photo isn't
    /// in the album, add it.
    ///
    /// This expects to be run inside a performChangesAndWait change block;
    /// see https://developer.apple.com/documentation/photokit/phphotolibrary/1620747-performchangesandwait.
    func toggle(inAlbum album: PHAssetCollection) -> Void {
      let changeAlbum =
        PHAssetCollectionChangeRequest(for: album)!

      let assets = [self] as NSFastEnumeration

      if self.isInAlbum(album) {
        changeAlbum.removeAssets(assets)
      } else {
        changeAlbum.addAssets(assets)
      }
    }
}
