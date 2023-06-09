//
//  AlbumHelpers.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Foundation
import Photos

/// Looks up an album by name.
///
/// This assumes that album names are globally unique.
func getAlbum(withName name: String) -> PHAssetCollection {
  let collections =
    PHAssetCollection
        .fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)

  var thisAssetCollection: PHAssetCollection? = nil

  collections.enumerateObjects({ (album, index, stop) in
    let assetCollection = album

    if assetCollection.localizedTitle == Optional(name) {
      thisAssetCollection = assetCollection
    }
  })

  if let assetCollection = thisAssetCollection {
    return assetCollection
  } else {
    fatalError("Unable to find album with name: \(name).\n")
  }
}
