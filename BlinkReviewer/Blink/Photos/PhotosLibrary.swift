import Foundation
import Photos

/// Manage most of the interactions with the Photos Library.
///
/// This includes loading all the asset data, and reacting to changes
/// in the Photos Library (both external and triggered by Blink).
///
class PhotosLibrary: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {

    @Published var isPhotoLibraryAuthorized = false
    
    @Published var assets: PHFetchResult<PHAsset> = PHFetchResult()
    
    @Published var approvedAssets: PHFetchResult<PHAsset> = PHFetchResult()
    @Published var rejectedAssets: PHFetchResult<PHAsset> = PHFetchResult()
    @Published var needsActionAssets: PHFetchResult<PHAsset> = PHFetchResult()
    
    // We publish the latest changes we detect from the Photos library.
    //
    // Views can subscribe to updates with
    //
    // ```swift
    // .onChange(of: photosLibrary.latestChangeDetails, perform: { lastChangeDetails in
    //   ...
    // }
    // ```
    //
    // and then access the individual properties to work out how to rearrange the
    // UI to preserve the user's focused position (if possible).
    //
    // See https://developer.apple.com/documentation/photokit/phfetchresultchangedetails/1613898-enumeratemoves
    @Published var latestChangeDetails: PHFetchResultChangeDetails<PHAsset>? = nil
    
    private lazy var approved = getAlbum(withName: "Approved")
    private lazy var rejected = getAlbum(withName: "Rejected")
    private lazy var needsAction = getAlbum(withName: "Needs Action")
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        getInitialData()
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // If we've just received permission to read the user's Photos Library, go
        // ahead and populate all the initial data structures.
        if !self.isPhotoLibraryAuthorized && PHPhotoLibrary.authorizationStatus() == .authorized {
            getInitialData()
        }
        
        DispatchQueue.main.async {
            let start = DispatchTime.now()
            var elapsed = start

            func printElapsed(_ label: String) -> Void {
              let now = DispatchTime.now()

              let totalInterval = Double(now.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
              let elapsedInterval = Double(now.uptimeNanoseconds - elapsed.uptimeNanoseconds) / 1_000_000_000

              elapsed = DispatchTime.now()

              print("Time to \(label):\n  \(elapsedInterval) seconds (\(totalInterval) total)")
            }
            
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            if let assetsChangeDetails = changeInstance.changeDetails(for: self.assets) {
                self.assets = assetsChangeDetails.fetchResultAfterChanges
                self.latestChangeDetails = assetsChangeDetails
            }
            
            if let approvedChangeDetails = changeInstance.changeDetails(for: self.approvedAssets) {
                self.approvedAssets = approvedChangeDetails.fetchResultAfterChanges
            }
            
            if let rejectedChangeDetails = changeInstance.changeDetails(for: self.rejectedAssets) {
                self.rejectedAssets = rejectedChangeDetails.fetchResultAfterChanges
            }
            
            if let needsActionChangeDetails = changeInstance.changeDetails(for: self.needsActionAssets) {
                self.needsActionAssets = needsActionChangeDetails.fetchResultAfterChanges
            }
            
            printElapsed("get all photos data (update)")
            
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }

    private func getInitialData() {
        DispatchQueue.main.async {
            let start = DispatchTime.now()
            var elapsed = start

            func printElapsed(_ label: String) -> Void {
              let now = DispatchTime.now()

              let totalInterval = Double(now.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
              let elapsedInterval = Double(now.uptimeNanoseconds - elapsed.uptimeNanoseconds) / 1_000_000_000

              elapsed = DispatchTime.now()

              print("Time to \(label):\n  \(elapsedInterval) seconds (\(totalInterval) total)")
            }
            
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
            
            if (self.isPhotoLibraryAuthorized) {
                self.assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)

                self.approvedAssets = PHAsset.fetchAssets(in: self.approved, options: nil)
                self.rejectedAssets = PHAsset.fetchAssets(in: self.rejected, options: nil)
                self.needsActionAssets = PHAsset.fetchAssets(in: self.needsAction, options: nil)
            }
            
            printElapsed("get all photos data (new)")
            
            
        }
    }
    
    func asset(at index: Int) -> PHAsset {
        assets.object(at: index)
    }
    
    func state(of asset: PHAsset) -> ReviewState? {
        if self.rejectedAssets.contains(asset) {
            return .Rejected
        }
        
        if self.needsActionAssets.contains(asset) {
            return .NeedsAction
        }
        
        if self.approvedAssets.contains(asset) {
            return .Approved
        }
        
        return nil
    }
    
    // Implements a basic cache for thumbnail images.
    //
    // Thumbnail images are small and easily reused; I've put them here because
    // we already pass this class around as a shared @EnvironmentObject.
    //
    // For some reason SwiftUI insists on trying to recreate all the thumbnail
    // views when you step between images -- I think there's probably a way to
    // have it cache the views rather than me doing it manually, but I'm not
    // smart enough to debug that.  If I don't cache it, there's a "flash" as
    // it reloads the thumbnails every time.
    //
    // TODO: Investigate using SwiftUI to do this.
    // TODO: If that doesn't work, replace this Dictionary with NSCache or an
    // LRU cache.  For some reason NSCache didn't store entries when I tried it,
    // but I didn't try for very long.
    private var thumbnailCache = Dictionary<PHAsset, PHAssetImage>()
    
    func getThumbnail(for asset: PHAsset) -> PHAssetImage {
        if let cachedThumbnail = thumbnailCache[asset] {
            return cachedThumbnail
        }
        
        let newThumbnail = PHAssetImage(
            asset,
            size: CGSize(width: 70, height: 70),
            deliveryMode: .fastFormat
        )
        
        thumbnailCache[asset] = newThumbnail
        
        return newThumbnail
    }
}
