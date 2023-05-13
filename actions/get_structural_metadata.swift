import Photos

struct AlbumData: Codable {
  var localIdentifier: String
  var localizedTitle: String?
  var assetIdentifiers: [String]
}

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

struct AssetData: Codable {
  var localIdentifier: String
  var creationDate: String?
  var isFavorite: Bool
}

var allAssets: [AssetData] = []

PHAsset
  .fetchAssets(with: PHAssetMediaType.image, options: nil)
  .enumerateObjects({ (asset, _, _) in
    allAssets.append(
      AssetData(
        localIdentifier: asset.localIdentifier,
        creationDate: asset.creationDate?.ISO8601Format(),
        isFavorite: asset.isFavorite
      )
    )
  })

struct Response: Codable {
  var albums: [AlbumData]
  var assets: [AssetData]
}

let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(
  Response(albums: allAlbums, assets: allAssets)
)
let json = String(data: jsonData, encoding: String.Encoding.utf8)
print(json!)
