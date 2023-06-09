//
//  PhotosLibrary.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 09/06/2023.
//

import Foundation
import Photos

class PhotosLibrary: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {

    @Published var assets = getAllPhotos()
    @Published var isPhotoLibraryAuthorized = false
    
    @Published var approvedAssets: Set<PHAsset> = Set()
    @Published var rejectedAssets: Set<PHAsset> = Set()
    @Published var needsActionAssets: Set<PHAsset> = Set()

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        updateStatus()
    }
    
    func updateAsset(atIndex index: Int) {
        self.assets[index] = PHAsset.fetchAssets(withLocalIdentifiers: [self.assets[index].localIdentifier], options: nil).firstObject!
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        updateStatus()
    }

    private func updateStatus() {
        DispatchQueue.main.async {
            self.assets = getAllPhotos()
            
            self.approvedAssets = self.getPhotosIn(album: getAlbum(withName: "Approved"))
            self.rejectedAssets = self.getPhotosIn(album: getAlbum(withName: "Rejected"))
            self.needsActionAssets = self.getPhotosIn(album: getAlbum(withName: "Needs Action"))
            
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }
    
    private func getPhotosIn(album: PHAssetCollection) -> Set<PHAsset> {
        var result: Set<PHAsset> = Set()
        
        PHAsset.fetchAssets(in: album, options: nil)
            .enumerateObjects({ (asset, _, _) in
                result.insert(asset)
            })
        
        return result
    }
    
    func state(for asset: PHAsset) -> ReviewState? {
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
}
