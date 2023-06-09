import SwiftUI
import Photos

/// This view gets an NSImage for a PHAsset.
///
/// When you get a photo from the Photos library, it may not be available
/// immediately -- for example, if the image has to be downloaded from
/// iCloud first.  Downstream views can create an instance of this object,
/// and then watch the `image` property -- this will be populated with the
/// appropriate image as it loads.
///
/// You can use this class in two ways:
///
///   1. Create a new instance for every PHAsset you want to render
///   2. Create a single instance and update the `asset` property; the `image`
///      property will be updated shortly after
///
/// Note: PhotoKit may return multiple versions of an image, e.g. a low-res
/// version immediately and a high-res version later.  You can inspect the
/// `isDegraded` property -- this will tell you if Photos has returned a
/// low quality image now and expects to return a higher quality image later.
class PHAssetImage: NSObject, ObservableObject {

    @Published var image = NSImage()
    @Published var isDegraded = false

    init(_ asset: PHAsset?, size: CGSize, deliveryMode: PHImageRequestOptionsDeliveryMode) {
        self.size = size
        self.deliveryMode = deliveryMode
        self.imageCache = Dictionary()
        
        super.init()
        
        self.asset = asset
    }
    
    private var _asset: PHAsset?
    private var size: CGSize
    private var deliveryMode: PHImageRequestOptionsDeliveryMode
    
    // Often we'll be retrieving the same image repeatedly, as the user shuttles
    // back and forth between a few images they're comparing.  In this case, we
    // don't want to go back to Photos every time -- so we keep a cache of images
    // we've retrieved previously.
    //
    // In theory the `PHCachingImageManager` does this for us; in practice the app
    // feels snappier to me with this additional cache.
    //
    // TODO: Replace this Dictionary with an LRU cache of some sort; this could
    // allow the app's memory usage to balloon indefinitely.
    private var imageCache: Dictionary<PHAsset, NSImage>
    
    var asset: PHAsset? {
        get {
            self._asset
        }
        
        set {
            self._asset = newValue
            regenerateImage()
        }
    }
        
    private func regenerateImage() {
        if let thisAsset = asset {
            if let nsImage = imageCache[thisAsset] {
                self.image = nsImage
                return
            }

            print("regenerating image for \(thisAsset.localIdentifier)")

            
            // This implementation is based on code in a Stack Overflow answer
            // by Francois Nadeau: https://stackoverflow.com/a/48755517/1558022
            
            let options = PHImageRequestOptions()
            
            options.isSynchronous = false
            options.deliveryMode = deliveryMode
            
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
            
            PHCachingImageManager.default()
                .requestImage(
                    for: thisAsset,
                    targetSize: size,
                    contentMode: .aspectFill,
                    options: options,
                    resultHandler: { (result, info) -> Void in
                        if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool {
                            self.isDegraded = isDegraded
                        }
                        
                        if let imageResult = result {
//                            print("got image!")
                            self.image = imageResult
                            
                            if !self.isDegraded {
                                self.imageCache[thisAsset] = imageResult
                            }
                        } else {
                            print("Error getting image: \(info)")
                        }
                    }
                )
        }
    }
}
