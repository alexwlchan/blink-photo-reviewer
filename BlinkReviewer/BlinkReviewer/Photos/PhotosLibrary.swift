//
//  PhotosLibrary.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 09/06/2023.
//

import Foundation
import Photos

class PhotosLibrary: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {

//    @Published var assets = getAllPhotos()
    @Published var isPhotoLibraryAuthorized = false
    
    @Published var assets2: PHFetchResult<PHAsset> = PHFetchResult()
    
    @Published var approvedAssets: PHFetchResult<PHAsset> = PHFetchResult()
    @Published var rejectedAssets: PHFetchResult<PHAsset> = PHFetchResult()
    @Published var needsActionAssets: PHFetchResult<PHAsset> = PHFetchResult()
    
    private let approved = getAlbum(withName: "Approved")
    private let rejected = getAlbum(withName: "Rejected")
    private let needsAction = getAlbum(withName: "Needs Action")

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
        updateStatus(isChange: false)
    }
    
    func updateAsset(atIndex index: Int) {
//        self.assets[index] = PHAsset.fetchAssets(withLocalIdentifiers: [self.assets[index].localIdentifier], options: nil).firstObject!
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("calling photoLibraryDidChange")
        print(changeInstance.description)
        updateStatus(isChange: true)
    }

    private func updateStatus(isChange: Bool) {
        DispatchQueue.main.async {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.fetchLimit = 500
            
            self.assets2 = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)

            self.approvedAssets = PHAsset.fetchAssets(in: self.approved, options: nil)
            self.rejectedAssets = PHAsset.fetchAssets(in: self.rejected, options: nil)
            self.needsActionAssets = PHAsset.fetchAssets(in: self.needsAction, options: nil)
            
            self.isPhotoLibraryAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }
    
    func state(for asset: PHAsset) -> ReviewState? {
        if asset.localIdentifier == "CBF9AD6F-F885-4538-9012-3DC5EEEBACBE/L0/001" {
            print("evaluating state for \(asset.localIdentifier)")
        }
        
        if self.rejectedAssets.contains(asset) {
            return .Rejected
        }
        
        if self.needsActionAssets.contains(asset) {
            return .NeedsAction
        }
        
        if self.approvedAssets.contains(asset) {
            if asset.localIdentifier == "CBF9AD6F-F885-4538-9012-3DC5EEEBACBE/L0/001" {
                print(" -> state is approved!")
            }
            
            return .Approved
        }
        
        return nil
    }
}
