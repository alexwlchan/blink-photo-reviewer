import Cocoa
import Photos

let assetId = "55CF4C5B-8BE3-4216-B158-3EF86AAAC5C5/L0/001"

let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject!

// https://stackoverflow.com/a/48755517/1558022
func getAssetThumbnail(asset: PHAsset, size: Double) -> NSImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var thumbnail = NSImage()
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

let thumbnailPath = "/tmp/photos-reviewer/\(asset.localIdentifier.prefix(1))/\(asset.localIdentifier)_65.jpg"

if !FileManager.default.fileExists(atPath: thumbnailPath) {
  let jpegData = jpegDataFrom(image: getAssetThumbnail(asset: asset, size: 65.0))

  try! FileManager.default.createDirectory(atPath: NSString(string: thumbnailPath).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)

  try! jpegData.write(to: URL(fileURLWithPath: thumbnailPath), options: [])
}

print(thumbnailPath)
