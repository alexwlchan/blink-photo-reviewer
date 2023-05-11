#!/usr/bin/env swift
// Print a list of album names that contain this photo.
//
// This takes one arguments: the UUID of the photo.
//
// == Usage ==
//
//    $ swift get_albums_for_photo.swift 9D28ABBE-79F6-402F-8750-8674840EDA3D
//    ["Flagged"]
//

import Photos

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
  fputs("Usage: \(arguments[0]) PHOTO_ID\n", stderr)
  exit(1)
}

let photo = getPhotoWith(uuid: arguments[1])

let collections = PHAssetCollection.fetchAssetCollectionsContaining(
  photo, with: .album, options: nil
)

var titles: [String] = []

collections.enumerateObjects({ (album, index, stop) in
  if (album.localizedTitle != nil) {
    titles.append(album.localizedTitle!)
  }
})

print(titles)
