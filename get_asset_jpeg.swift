import Cocoa
import Photos

/// Create an NSImage at the given size for a given asset.
func getAssetThumbnail(asset: PHAsset, size: Double) -> NSImage {

  // This implementation is based on code in a Stack Overflow answer
  // by Francois Nadeau: https://stackoverflow.com/a/48755517/1558022
  //
  // I've added more comments and error-handling logic.

  let options = PHImageRequestOptions()
  options.isSynchronous = true

  // If i don't set this value, then sometimes I get an error like
  // this in the `info` variable:
  //
  //      Error Domain=PHPhotosErrorDomain Code=3164 "(null)"
  //
  // This means that the asset is in the cloud, and by default Photos
  // isn't allowed to download assets here.  Apple's documentation
  // suggests adding this option as the fix.
  //
  // See https://developer.apple.com/documentation/photokit/phphotoserror/phphotoserrornetworkaccessrequired
  options.isNetworkAccessAllowed = true

  var thumbnail = NSImage()

  PHImageManager.default()
    .requestImage(
      for: asset,
      targetSize: CGSize(width: size, height: size),
      contentMode: .aspectFit,
      options: options,
      resultHandler: { (result, info) -> Void in

        // If we fail to get a result, print a message to the user that
        // includes the value of `info`.  For information about interpreting
        // these keys, see Apple's documentation:
        // https://developer.apple.com/documentation/photokit/phimagemanager/image_result_info_keys
        switch (result, info) {
        case let (result?, _):
          thumbnail = result
        case let (.none, info?):
          fputs("Unable to create thumbnail:\n", stderr)
          fputs("\(info)\n", stderr)
          exit(1)
        case (.none, .none):
          fputs("Unable to create thumbnail:\n", stderr)
          fputs("(unknown error)\n", stderr)
          exit(1)
        }
      })

  return thumbnail
}

func jpegDataFrom(image: NSImage) -> Data {
  let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
  let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
  let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
  return jpegData
}

let arguments = CommandLine.arguments

if arguments.count != 3 {
  fputs("Usage: \(arguments[0]) ASSET_ID SIZE\n", stderr)
  exit(1)
}

let assetId = arguments[1]
let size = Int(arguments[2])

if size == nil {
  fputs("Unrecognised size: \(arguments[2])\n", stderr)
  exit(1)
}

let assetLookup = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)

if assetLookup.count == 0 {
  fputs("Unrecognised asset ID: \(assetId)\n", stderr)
  exit(1)
}

let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject!

let thumbnailPath =
  "/tmp/photos-reviewer/\(asset.localIdentifier.prefix(1))/\(asset.localIdentifier)_\(size!).jpg"

if !FileManager.default.fileExists(atPath: thumbnailPath) {
  let jpegData = jpegDataFrom(image: getAssetThumbnail(asset: asset, size: Double(size!)))

  try! FileManager.default.createDirectory(
    atPath: NSString(string: thumbnailPath).deletingLastPathComponent,
    withIntermediateDirectories: true, attributes: nil)

  try! jpegData.write(to: URL(fileURLWithPath: thumbnailPath), options: [])
}

fputs(thumbnailPath, stdout)
