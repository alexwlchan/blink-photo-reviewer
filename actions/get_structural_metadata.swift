#!/usr/bin/env swift
/// This script gets some metadata from my Photos Library, in particular:
///
///   - a list of all my albums
///   - a list of all my photos
///
/// This data takes the form of the `Response` struct shown below, and is
/// formatted as JSON printed to stdout.

import Photos

struct AlbumData: Codable {
  var localIdentifier: String
  var localizedTitle: String?
  var assetIdentifiers: [String]
}

struct AssetData: Codable {
  var localIdentifier: String
  var creationDate: String?
  var isFavorite: Bool
}

struct Response: Codable {
  var albums: [AlbumData]
  var assets: [AssetData]
}

/// Get data for all the albums in my library.
func getAllAlbums() -> [AlbumData] {
  var allAlbums: [AlbumData] = []

  PHAssetCollection
    .fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
    .enumerateObjects({ (album, _, _) in
      var assetIdentifiers: [String] = []

      PHAsset
        .fetchAssets(in: album, options: nil)
        .enumerateObjects({ (asset, _, _) in
          assetIdentifiers.append(asset.localIdentifier)
        })

      allAlbums.append(
        AlbumData(
          localIdentifier: album.localIdentifier,
          localizedTitle: album.localizedTitle,
          assetIdentifiers: assetIdentifiers
        )
      )
    })

  return allAlbums
}

/// Gets data for all the photos in my library.
func getAllAssets() -> [AssetData] {
  var allPhotos: [AssetData] = []

  PHAsset
    .fetchAssets(with: PHAssetMediaType.image, options: nil)
    .enumerateObjects({ (asset, _, _) in

      allPhotos.append(
        AssetData(
          localIdentifier: asset.localIdentifier,
          creationDate: asset.creationDate?.ISO8601Format(),
          isFavorite: asset.isFavorite
        )
      )
    })

  return allPhotos
}

class ChangeListener : NSObject, PHPhotoLibraryChangeObserver {
  public override init() {
    super.init()
    PHPhotoLibrary.shared().register(self)
  }

  public func photoLibraryDidChange(_ changeInstance: PHChange) {
    print(changeInstance)
    getAllStructuralMetadata()
  }
}

/// Gets all the structural metadata, and returns a JSON-formatted string.
func getAllStructuralMetadata() -> Void {
  let arguments = CommandLine.arguments

  guard arguments.count == 2 else {
    fputs("Usage: \(arguments[0]) METADATA_PATH\n", stderr)
    exit(1)
  }

  let metadataPath = arguments[1]

  let jsonEncoder = JSONEncoder()
  let jsonData = try! jsonEncoder.encode(
    Response(albums: getAllAlbums(), assets: getAllAssets())
  )

  let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!

  try! jsonString.write(to: URL(fileURLWithPath: metadataPath), atomically: true, encoding: String.Encoding.utf8)
}


let listener = ChangeListener()

getAllStructuralMetadata()

sleep(100)
