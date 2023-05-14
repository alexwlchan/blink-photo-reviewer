#!/usr/bin/env swift
/// This script makes changes to my Photos library.
///
/// It takes two argument: an asset ID, and the name of the action to
/// perform in my Photos library.
///
/// The asset ID is the 'localIdentifier' property of a PHAsset.
///
/// The available actions are as follows:
///
///     toggle-favorite
///       If an image is already a favorite, unmark it as such.
///       If an image isn't a favorite, mark it as a favorite.
///
///     toggle-approved
///     toggle-rejected
///     toggle-needs-action
///       When I review an image, it gets sorted into one of three buckets,
///       which have corresponding albums in Photos: Approved, Rejected,
///       Needs Action.
///
///       These actions add an asset to the appropriate album, and remove it
///       from the other albums.  If you run it a second time, it gets
///       removed from the album, resetting it to zero.
///
///     toggle-cross-stitch
///       Toggles an image's inclusion in my "Cross stitch" album.
///

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
    fputs("Unable to find album with name: \(name).\n", stderr)
    exit(1)
  }
}

/// Returns the PHAsset with the given identifier, or throws if it
/// can't be found.
func getPhoto(withLocalIdentifier localIdentifier: String) -> PHAsset {
  let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)

  if let firstObject = fetchResult.firstObject {
    return firstObject
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
  func toggle(inAlbum album: PHAssetCollection) -> Void {
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

let photo = getPhoto(withLocalIdentifier: arguments[1])

try PHPhotoLibrary.shared().performChangesAndWait {
  switch action {
    case "toggle-favorite":
      let changeAsset = PHAssetChangeRequest(for: photo)
      changeAsset.isFavorite = !photo.isFavorite

    case "toggle-approved", "toggle-rejected", "toggle-needs-action":
      let approved = getAlbum(withName: "Approved")
      let rejected = getAlbum(withName: "Rejected")
      let needsAction = getAlbum(withName: "Needs Action")

      if action == "toggle-approved" {
        photo.toggle(inAlbum: approved)
      } else {
        photo.remove(fromAlbum: approved)
      }

      if action == "toggle-rejected" {
        photo.toggle(inAlbum: rejected)
      } else {
        photo.remove(fromAlbum: rejected)
      }

      if action == "toggle-needs-action" {
        photo.toggle(inAlbum: needsAction)
      } else {
        photo.remove(fromAlbum: needsAction)
      }

    case "toggle-cross-stitch":
      let crossStitch = getAlbum(withName: "Cross stitch")
      photo.toggle(inAlbum: crossStitch)

    default:
      fputs("Unrecognised action: \(action)\n", stderr)
      exit(1)
  }
}
