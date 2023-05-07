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

/// Returns a list of album names for albums containing this asset.
func getAlbumsContainingAsset(asset: PHAsset) -> [String] {
  let collections = PHAssetCollection.fetchAssetCollectionsContaining(
    asset, with: .album, options: nil
  )

  var titles: [String] = []

  collections.enumerateObjects({ (album, index, stop) in
    if (album.localizedTitle != nil) {
      titles.append(album.localizedTitle!)
    }
  })

  return titles
}

let options = PHFetchOptions()
options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

let all_assets = PHAsset.fetchAssets(with: options)

let index = IndexSet(integersIn: 750...755)

struct PhotoData: Codable {
  var uuid: String
  var albums: [String]
}

let jsonEncoder = JSONEncoder()

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

var response: [PhotoData] = []

for asset in all_assets.objects(at: index) {
  let data = PhotoData(
    uuid: asset.localIdentifier,
    albums: getAlbumsContainingAsset(asset: asset)
  )

  response.append(data)
}

let jsonData = try jsonEncoder.encode(response)
let json = String(data: jsonData, encoding: String.Encoding.utf8)
print(json!)
