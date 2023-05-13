#!/usr/bin/env swift

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

func isPhotoInAlbum(photo: PHAsset, collection: PHAssetCollection) -> Bool {
  let collections = PHAssetCollection.fetchAssetCollectionsContaining(
    photo, with: .album, options: nil
  )

  var result = false

  collections.enumerateObjects({ (album, index, stop) in
    if (album == collection) {
      result = true
    }
  })

  return result
}

let arguments = CommandLine.arguments

guard arguments.count == 3 else {
  fputs("Usage: \(arguments[0]) PHOTO_ID ACTION\n", stderr)
  exit(1)
}

let action = arguments[2]

let flagged = getAlbumWith(name: "Flagged")
let rejected = getAlbumWith(name: "Rejected")
let needsAction = getAlbumWith(name: "Needs Action")
let crossStitch = getAlbumWith(name: "Cross stitch")

let photo = getPhotoWith(uuid: arguments[1])

try PHPhotoLibrary.shared().performChangesAndWait {
  let changeAsset = PHAssetChangeRequest(for: photo)

  let changeFlagged =
    PHAssetCollectionChangeRequest(for: flagged)!
  let changeRejected =
    PHAssetCollectionChangeRequest(for: rejected)!
  let changeNeedsAction =
    PHAssetCollectionChangeRequest(for: needsAction)!
  let changeCrossStitch =
    PHAssetCollectionChangeRequest(for: crossStitch)!

  let assets = [photo] as NSFastEnumeration

  if action == "toggle-favorite" {
    changeAsset.isFavorite = !photo.isFavorite
  } else if action == "toggle-flagged" {
    changeRejected.removeAssets(assets)
    changeNeedsAction.removeAssets(assets)

    if (isPhotoInAlbum(photo: photo, collection: flagged)) {
      changeFlagged.removeAssets(assets)
    } else {
      changeFlagged.addAssets(assets)
    }
  } else if action == "toggle-rejected" {
    changeFlagged.removeAssets(assets)
    changeNeedsAction.removeAssets(assets)

    if (isPhotoInAlbum(photo: photo, collection: rejected)) {
      changeRejected.removeAssets(assets)
    } else {
      changeRejected.addAssets(assets)
    }
  } else if action == "toggle-needs-action" {
    changeFlagged.removeAssets(assets)
    changeRejected.removeAssets(assets)

    if (isPhotoInAlbum(photo: photo, collection: needsAction)) {
      changeNeedsAction.removeAssets(assets)
    } else {
      changeNeedsAction.addAssets(assets)
    }
  } else if action == "toggle-cross-stitch" {
    print("GO GO GO")
    print(crossStitch)
    print(isPhotoInAlbum(photo: photo, collection: crossStitch))
    if (isPhotoInAlbum(photo: photo, collection: crossStitch)) {
      changeCrossStitch.removeAssets(assets)
    } else {
      changeCrossStitch.addAssets(assets)
    }
  } else {
    fputs("Unrecognised action: \(action)\n", stderr)
    exit(1)
  }
}
