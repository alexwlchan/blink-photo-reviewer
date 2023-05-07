#!/usr/bin/env swift
// Remove a photo from a photo album.
//
// This takes two arguments: the name of the album, and the UUID of
// the photo in the album.  It assumes the album name is globally unique.
//
// == Usage ==
//
// Pass the album name as the first argument, and the UUID as the second:
//
//    $ remove_image_from_album "Flagged" "9D28ABBE-79F6-402F-8750-8674840EDA3D"
//

import Photos

func getAlbumWith(name: String) -> PHAssetCollection {
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

  if thisAssetCollection != nil {
    return thisAssetCollection!
  } else {
    fputs("Unable to find album with name: \(name).\n", stderr)
    exit(1)
  }
}

func getPhotoWith(uuid: String) -> PHAsset {
  let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [uuid], options: nil)

  if fetchResult.count == 1 {
    return fetchResult.firstObject!
  } else {
    fputs("Unable to find photo with ID: \(uuid).\n", stderr)
    exit(1)
  }
}

let arguments = CommandLine.arguments

if arguments.count != 2 {
  fputs("Usage: \(arguments[0]) ALBUM_NAME PHOTO_ID\n", stderr)
  exit(1)
}

let album = getAlbumWith(name: arguments[1])
let photo = getPhotoWith(uuid: arguments[2])

try PHPhotoLibrary.shared().performChangesAndWait {
  let request =
    PHAssetCollectionChangeRequest(for: album)

  request!.removeAssets([photo] as NSFastEnumeration)
}
