//
//  Helpers.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Foundation
import Photos

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
    
    func originalFilename() -> String {
        PHAssetResource.assetResources(for: self).first!.originalFilename
    }

    /// Returns true if an asset is in the given album, false otherwise.
    private func isInAlbum(_ album: PHAssetCollection) -> Bool {
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
