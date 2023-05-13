#!/usr/bin/env swift

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

  if thisAssetCollection != nil {
    return thisAssetCollection!
  } else {
    fputs("Unable to find album with name: \(name).\n", stderr)
    exit(1)
  }
}

/// Returns the PHAsset with the given identifier, or throws if it
/// can't be found.
func getPhoto(withLocalIdentifier localIdentifier: String) -> PHAsset {
  let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)

  if fetchResult.count == 1 {
    return fetchResult.firstObject!
  } else {
    fputs("Unable to find photo with ID: \(localIdentifier).\n", stderr)
    exit(1)
  }
}

extension PHAsset {
  /// Returns true if an asset is in the given album, false otherwise.
  func isInAlbum(_ album: PHAssetCollection) -> Bool {
    var result = false

    PHAssetCollection
      .fetchAssetCollectionsContaining(self, with: .album, options: nil)
      .enumerateObjects({ (collection, index, stop) in
        if (album == collection) {
          result = true
        }
      })

    return result
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

  /// Toggle a photo's inclusion in an album.
  ///
  /// If the photo is already in the album, remove it.  If the photo isn't
  /// in the album, add it.
  ///
  /// This expects to be run inside a performChangesAndWait change block;
  /// see https://developer.apple.com/documentation/photokit/phphotolibrary/1620747-performchangesandwait.
  func toggle(inAlbum album: String) -> Void {
    let changeAlbum =
      PHAssetCollectionChangeRequest(for: album)!

    let assets = [self] as NSFastEnumeration

    if photo.isInAlbum(album) {
      changeAlbum.removeAssets(assets)
    } else {
      changeAlbum.addAssets(assets)
    }
  }
}

let arguments = CommandLine.arguments

guard arguments.count == 3 else {
  fputs("Usage: \(arguments[0]) PHOTO_ID ACTION\n", stderr)
  exit(1)
}

let action = arguments[2]

let flagged = getAlbum(withName: "Flagged")
let rejected = getAlbum(withName: "Rejected")
let needsAction = getAlbum(withName: "Needs Action")
let crossStitch = getAlbum(withName: "Cross stitch")

let photo = getPhoto(withLocalIdentifier: arguments[1])

try PHPhotoLibrary.shared().performChangesAndWait {
  let changeAsset = PHAssetChangeRequest(for: photo)

  if action == "toggle-favorite" {
    changeAsset.isFavorite = !photo.isFavorite
  } else if action == "toggle-flagged" {
    photo.toggle(inAlbum: flagged)
    photo.remove(fromAlbum: rejected)
    photo.remove(fromAlbum: needsAction)
  } else if action == "toggle-rejected" {
    photo.remove(fromAlbum: flagged)
    photo.toggle(inAlbum: rejected)
    photo.remove(fromAlbum: needsAction)
  } else if action == "toggle-needs-action" {
    photo.remove(fromAlbum: flagged)
    photo.remove(fromAlbum: rejected)
    photo.toggle(inAlbum: needsAction)
  } else if action == "toggle-cross-stitch" {
    photo.toggle(inAlbum: crossStitch)
  } else {
    fputs("Unrecognised action: \(action)\n", stderr)
    exit(1)
  }
}
