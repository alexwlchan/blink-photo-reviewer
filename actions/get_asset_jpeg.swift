#!/usr/bin/env swift
/// This script creates a JPEG for a photo in my Photos Library.
///
/// It takes two arguments: the localIdentifier for the asset, and a
/// target size.  It prints a path to the generated JPEG.
///
///     $ swift get_asset_jpeg.swift ADC872E4-A7B3-4E4F-95AE-BA96C359F532/L0/001 2048
///     /tmp/photos-reviewer/A/ADC872E4-A7B3-4E4F-95AE-BA96C359F532/L0/001_2048.jpg⏎
///

import Cocoa
import Photos

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
  /// Create an NSImage at the given size.
  func getImage(atSize size: Double) -> NSImage {
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

    var image = NSImage()

    PHImageManager.default()
      .requestImage(
        for: self,
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
            image = result
          case let (.none, info?):
            fputs("Unable to create image:\n", stderr)
            fputs("\(info)\n", stderr)
            exit(1)
          case (.none, .none):
            fputs("Unable to create image:\n", stderr)
            fputs("(unknown error)\n", stderr)
            exit(1)
          }
        })

    return image
  }
}

extension NSImage {
  func jpegData() -> Data {
    let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    return bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
  }
}

func jpegDataFrom(image: NSImage) -> Data {
  let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
  let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
  let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
  return jpegData
}

let arguments = CommandLine.arguments

guard arguments.count == 3 {
  fputs("Usage: \(arguments[0]) ASSET_ID SIZE\n", stderr)
  exit(1)
}

let localIdentifier = arguments[1]
let size = Int(arguments[2])

if size == nil || size <= 0 {
  fputs("Unrecognised size: \(arguments[2])\n", stderr)
  exit(1)
}

let asset = getPhoto(withLocalIdentifier: localIdentifier)

let thumbnailPath =
  "/tmp/photos-reviewer/\(localIdentifier.prefix(1))/\(localIdentifier)_\(size!).jpg"

if !FileManager.default.fileExists(atPath: thumbnailPath) {
  try! FileManager.default.createDirectory(
    atPath: NSString(string: thumbnailPath).deletingLastPathComponent,
    withIntermediateDirectories: true, attributes: nil)

  try! asset
    .getImage(atSize: Double(size!))
    .jpegData()
    .write(to: URL(fileURLWithPath: thumbnailPath), options: [])
}

fputs(thumbnailPath, stdout)
