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
    
    // These lists/sets allow us to do some fast lookups for getting the
    // state of an image, without going back to the Photos database.
    // Individual database calls are fast; 25,000 if you need to retrieve
    // all the thumbnails adds noticeable latency.
    //
    // 99% of the time, these match the PHFetchResult data; they differ when
    // somebody has just modified state (e.g. reviewed a photo as "approved").
    // We can update the internal set as soon as the PHChangeRequest completes,
    // without waiting to get the update back from the Photos Library.
    // That might not seem like much, but the latency is enough to feel
    // noticeable, and tracking our own copy of that state makes the UI
    // feel much more responsive.
    @Published var assetIdentifiers: [String] = []
    
    private var approvedAssetIdentifiers: Set<String> = Set()
    private var rejectedAssetIdentifiers: Set<String> = Set()
    private var needsActionAssetIdentifiers: Set<String> = Set()
    
    private var favoriteAssetIdentifiers: Set<String> = Set()
    
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
    
    /// Get the initial batch of data from the Photos Library when the app starts.
    ///
    /// This is populating all the cached data structures.
    ///
    /// You may see this method called twice, if you're running the app for the first time:
    ///
    ///    - When the app initially starts, we don't have permission to read the user's
    ///      Photos Library.  This method runs pretty quickly, because we skip fetching
    ///      anything from the database -- it'll appear empty to us.
    ///
    ///    - After the user grants permission, we'll call this method a second time, when
    ///      we can actually get all the data.
    ///
    private func getInitialData() {
        DispatchQueue.main.async {
            var timer = Timer()
            
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
            
            if (self.isPhotoLibraryAuthorized) {
                self.assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)

                self.approvedAssets = PHAsset.fetchAssets(in: self.approved, options: nil)
                self.rejectedAssets = PHAsset.fetchAssets(in: self.rejected, options: nil)
                self.needsActionAssets = PHAsset.fetchAssets(in: self.needsAction, options: nil)
                
                self.regenerateAssetIdentifiers()
                
                self.approvedAssetIdentifiers = getSetOfIdentifiers(fetchResult: self.approvedAssets)
                self.rejectedAssetIdentifiers = getSetOfIdentifiers(fetchResult: self.rejectedAssets)
                self.needsActionAssetIdentifiers = getSetOfIdentifiers(fetchResult: self.needsActionAssets)
            }
            
            timer.printTime("get initial Photos data (isPhotoLibraryAuthorized = \(self.isPhotoLibraryAuthorized))")
        }
    }
    
    /// React to changes from the Photos Library.
    ///
    /// The PhotoKit APIs give us a bunch of information about deltas and updates,
    /// so we don't need to reload all the information from scratch -- we can apply
    /// partial updates to our local data.
    ///
    /// Note: this method is carefully tuned to balance accuracy and speed; we always
    /// want to have the right data from Photos, but it can add noticeable latency
    /// to UI updates if it's inefficient.
    ///
    /// See https://developer.apple.com/documentation/photokit/phphotolibrarychangeobserver
    ///
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // If we've just received permission to read the user's Photos Library, go
        // ahead and populate all the initial data structures.
        if !self.isPhotoLibraryAuthorized && PHPhotoLibrary.authorizationStatus() == .authorized {
            getInitialData()
            
            // This is wrapped in an async dispatch to fix a warning from Xcode:
            //
            //     Publishing changes from background threads is not allowed; make sure
            //     to publish values from the main thread (via operators like receive(on:))
            //     on model updates.
            //
            DispatchQueue.main.async {
                self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
            }
            
            return
        }
        
        DispatchQueue.main.async {
            var timer = Timer()
            
            if let assetsChangeDetails = changeInstance.changeDetails(for: self.assets) {
                self.assets = assetsChangeDetails.fetchResultAfterChanges
                
                assetsChangeDetails.changedObjects.forEach { asset in
                    if asset.isFavorite {
                        self.favoriteAssetIdentifiers.insert(asset.localIdentifier)
                    } else {
                        self.favoriteAssetIdentifiers.remove(asset.localIdentifier)
                    }
                }
                
                if assetsChangeDetails.hasMoves {
                    self.regenerateAssetIdentifiers()
                }
                
                self.latestChangeDetails = assetsChangeDetails
            }
            
            if let approvedChangeDetails = changeInstance.changeDetails(for: self.approvedAssets) {
                self.approvedAssets = approvedChangeDetails.fetchResultAfterChanges
                
                approvedChangeDetails.insertedObjects.forEach { asset in
                    self.approvedAssetIdentifiers.insert(asset.localIdentifier)
                }
                
                approvedChangeDetails.removedObjects.forEach { asset in
                    self.approvedAssetIdentifiers.remove(asset.localIdentifier)
                }
            }
            
            if let rejectedChangeDetails = changeInstance.changeDetails(for: self.rejectedAssets) {
                self.rejectedAssets = rejectedChangeDetails.fetchResultAfterChanges
                
                rejectedChangeDetails.insertedObjects.forEach { asset in
                    self.rejectedAssetIdentifiers.insert(asset.localIdentifier)
                }
                
                rejectedChangeDetails.removedObjects.forEach { asset in
                    self.rejectedAssetIdentifiers.remove(asset.localIdentifier)
                }
            }
            
            if let needsActionChangeDetails = changeInstance.changeDetails(for: self.needsActionAssets) {
                self.needsActionAssets = needsActionChangeDetails.fetchResultAfterChanges
                
                needsActionChangeDetails.insertedObjects.forEach { asset in
                    self.needsActionAssetIdentifiers.insert(asset.localIdentifier)
                }
                
                needsActionChangeDetails.removedObjects.forEach { asset in
                    self.needsActionAssetIdentifiers.remove(asset.localIdentifier)
                }
            }
            
            timer.printTime("process change to Photos data")
            
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }
    
    /// Retrieve an asset at a particular position.
    ///
    /// Just a convenience wrapper around PHFetchResult.object(at: Int).
    ///
    func asset(at index: Int) -> PHAsset {
        assets.object(at: index)
    }
    
    /// Get the review state of a given asset.
    ///
    /// These methods are called repeatedly on every view (when we get the
    /// state of thumbnails), so they need to be *fast*.
    ///
    /// This is why we cache the list of rejected/needs action/approved assets --
    /// to make this method fast and performant.
    ///
    /// Note: it's possibly for an asset to be in multiple albums if the user
    /// fiddles with it, so we show the "most destructive" state first -- the
    /// state that might cause data loss if the user deletes all their rejected
    /// images.  If they toggle the state in the app, we'll fix it.
    ///
    /// TODO: Log a warning here? Resolve somehow?
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
    
    func state(ofAssetAtIndex index: Int) -> ReviewState? {
        state(of: asset(at: index))
    }
    
    func state(ofLocalIdentifier localIdentifier: String) -> ReviewState? {
        if self.rejectedAssetIdentifiers.contains(localIdentifier) {
            return .Rejected
        }
        
        if self.needsActionAssetIdentifiers.contains(localIdentifier) {
            return .NeedsAction
        }
        
        if self.approvedAssetIdentifiers.contains(localIdentifier) {
            return .Approved
        }
        
        return nil
    }
    
    /// Set the review state of an asset.
    ///
    /// This will record the change in the Photos Library and update any internal
    /// data structures.
    /// 
    func setState(ofAsset asset: PHAsset, to newState: ReviewState) -> Void {
        let existingState = self.state(of: asset)
    
        try! PHPhotoLibrary.shared().performChangesAndWait {
            // The first condition is a combination of two:
            //
            //      -- the photo is already approved and you hit the "approve" hotkey,
            //      -- so un-approve it
            //      state == .Approved && e.characters == "1"
            //
            //      -- the photo is already approved and you selected a different review
            //      -- state, so unapprove it
            //      state == .Approved && e.characters != "1"
            //
            // We can optimise it into a single case, but it does make sense!
            //
            // Similar logic applies for all three conditions.
            if existingState == .Approved {
                asset.remove(fromAlbum: self.approved)
            } else if newState == .Approved {
                asset.add(toAlbum: self.approved)
            }

            if existingState == .Rejected {
                asset.remove(fromAlbum: self.rejected)
            } else if newState == .Rejected {
                asset.add(toAlbum: self.rejected)
            }

            if existingState == .NeedsAction {
                asset.remove(fromAlbum: self.needsAction)
            } else if newState == .NeedsAction {
                asset.add(toAlbum: self.needsAction)
            }
        }
        
        if existingState == .Approved {
            self.approvedAssetIdentifiers.remove(asset.localIdentifier)
        } else if newState == .Approved {
            self.approvedAssetIdentifiers.insert(asset.localIdentifier)
        }

        if existingState == .Rejected {
            self.rejectedAssetIdentifiers.remove(asset.localIdentifier)
        } else if newState == .Rejected {
            self.rejectedAssetIdentifiers.insert(asset.localIdentifier)
        }

        if existingState == .NeedsAction {
            self.needsActionAssetIdentifiers.remove(asset.localIdentifier)
        } else if newState == .NeedsAction {
            self.needsActionAssetIdentifiers.insert(asset.localIdentifier)
        }
    }
    
    /// Returns true if this asset is a favorite, false otherwise.
    func isFavorite(localIdentifier: String) -> Bool {
        self.favoriteAssetIdentifiers.contains(localIdentifier)
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
    // TODO: Investigate the SwiftUI caching behaviour.
    //
    // Note: the size of both this and the following cache are designed to balance
    // memory usage and performance.  Everything on the screen and just off it
    // should be kept in cache, so I can e.g. switch between all the variants
    // of a single shot, but I don't need more than that.
    //
    // On my M2 MacBook Air, these numbers mean the app peaks at ~250MB of memory,
    // which seems pretty reasonable.
    private var thumbnailCache = LRUCache<PHAsset, PHAssetImage>(withMaxSize: 500)
    
    func getThumbnail(for asset: PHAsset) -> PHAssetImage {
        if thumbnailCache[asset] == nil {
            let newImage = PHAssetImage(
                asset,
                size: CGSize(width: 70, height: 70),
                deliveryMode: .opportunistic
            )
            
            thumbnailCache[asset] = newImage
        }

        return thumbnailCache[asset]!
    }
    
    // Implement a similar cache for full-sized images.
    //
    // This is to avoid having to rebuild the PHAssetImage every time --
    // which causes a brief "pop" as it starts by loading the low-res fuzzy image,
    // then the high-res image pops in a second or so later.
    //
    // TODO: Surely it should be possible to make SwiftUI cache views like
    // this for us?
    private var fullSizeImageCache = LRUCache<PHAsset, PHAssetImage>(withMaxSize: 10)
    
    func getFullSizedImage(for asset: PHAsset) -> PHAssetImage {
        if fullSizeImageCache[asset] == nil {
            let newImage = PHAssetImage(
                asset,
                size: PHImageManagerMaximumSize,
                deliveryMode: .opportunistic
            )
            
            fullSizeImageCache[asset] = newImage
        }

        return fullSizeImageCache[asset]!
    }
    
    private func regenerateAssetIdentifiers() -> Void {
        var assetIdentifiers: [String] = []
        var favoriteAssetIdentifiers: Set<String> = Set()
        
        self.assets.enumerateObjects { asset, _, _ in
            assetIdentifiers.append(asset.localIdentifier)
            
            if asset.isFavorite {
                favoriteAssetIdentifiers.insert(asset.localIdentifier)
            }
        }
        
        self.assetIdentifiers = assetIdentifiers
        self.favoriteAssetIdentifiers = favoriteAssetIdentifiers
    }
}

func getSetOfIdentifiers(fetchResult: PHFetchResult<PHAsset>) -> Set<String> {
    var result: Set<String> = Set()
    
    fetchResult.enumerateObjects { asset, _, _ in
        result.insert(asset.localIdentifier)
    }
    
    return result
}
