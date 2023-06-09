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
    
    private let approved = getAlbum(withName: "Approved")
    private let rejected = getAlbum(withName: "Rejected")
    private let needsAction = getAlbum(withName: "Needs Action")

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        updateStatus()
    }
    
    func updateAsset(atIndex index: Int) {
        self.assets[index] = PHAsset.fetchAssets(withLocalIdentifiers: [self.assets[index].localIdentifier], options: nil).firstObject!
        
        // This is an optimisation to make the UI feel snappy -- calling photoLibraryDidChange
        // takes ~1s to finish, which introduces noticeable latency. :(
        let asset = self.assets[index]
        
        let newAlbums = Set(asset.albums())
        
        if (newAlbums.contains(approved)) {
            approvedAssets.insert(asset)
        } else {
            approvedAssets.remove(asset)
        }
        
        if (newAlbums.contains(rejected)) {
            rejectedAssets.insert(asset)
        } else {
            rejectedAssets.remove(asset)
        }
        
        if (newAlbums.contains(needsAction)) {
            needsActionAssets.insert(asset)
        } else {
            needsActionAssets.remove(asset)
        }
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("calling photoLibraryDidChange")
        print(changeInstance.description)
        updateStatus()
    }

    private func updateStatus() {
        DispatchQueue.main.async {
            self.assets = getAllPhotos()
            
            self.approvedAssets = self.getPhotosIn(album: self.approved)
            self.rejectedAssets = self.getPhotosIn(album: self.rejected)
            self.needsActionAssets = self.getPhotosIn(album: self.needsAction)
            
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
