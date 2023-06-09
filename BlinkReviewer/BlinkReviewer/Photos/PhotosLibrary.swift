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
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }
    
    func countApproved() -> Int {
        let album = getAlbum(withName: "Approved")
        
        return PHAsset.fetchAssets(in: album, options: nil).count
    }
    
    func countRejected() -> Int {
        let album = getAlbum(withName: "Rejected")
        
        return PHAsset.fetchAssets(in: album, options: nil).count
    }
    
    func countNeedsAction() -> Int {
        let album = getAlbum(withName: "Needs Action")
        
        return PHAsset.fetchAssets(in: album, options: nil).count
    }
}
