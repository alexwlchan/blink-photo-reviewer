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

let index = IndexSet(integersIn: 0...5)

struct PhotoData: Codable {
  var uuid: String
  var albums: [String]
  var thumbnailPath: String
  // var thumbnail: String
}

import Cocoa

typealias UIImage = NSImage

// https://stackoverflow.com/a/48755517/1558022
func getAssetThumbnail(asset: PHAsset, size: Double) -> NSImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
    })
    return thumbnail
}

func jpegDataFrom(image:NSImage) -> Data {
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
    return jpegData
}

var response: [PhotoData] = []

for asset in all_assets.objects(at: index) {
  let thumbnailPath = "/tmp/photos-reviewer/\(asset.localIdentifier)_65.jpg"

  let data = PhotoData(
    uuid: asset.localIdentifier,
    albums: getAlbumsContainingAsset(asset: asset),
    thumbnailPath: thumbnailPath
    // thumbnail: getAssetThumbnail(asset: all_assets.firstObject!, size: 65.0).base64String!
  )

  if !FileManager.default.fileExists(atPath: thumbnailPath) {
    let jpegData = jpegDataFrom(image: getAssetThumbnail(asset: asset, size: 65.0))

    try! FileManager.default.createDirectory(atPath: NSString(string: thumbnailPath).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)

    try! jpegData.write(to: URL(fileURLWithPath: thumbnailPath), options: [])
  }

  response.append(data)
}

let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(response)
let json = String(data: jsonData, encoding: String.Encoding.utf8)
print(json!)

// print()
//