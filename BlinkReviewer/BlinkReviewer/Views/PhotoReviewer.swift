//
//  PhotoReviewer.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

struct PhotoReviewer: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @ObservedObject var fullSizeImage: PHAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize)
    
    @State var selectedAssetIndex: Int
    
    init(selectedAssetIndex: Int) {
        self.selectedAssetIndex = selectedAssetIndex
    }
    
    var body: some View {
        if photosLibrary.isPhotoLibraryAuthorized {
            VStack {
                ThumbnailList(selectedAssetIndex: $selectedAssetIndex)
                    .environmentObject(photosLibrary)
                
                FullSizeImage(image: fullSizeImage)
                    .background(.black)
            }.onAppear {
                fullSizeImage.asset = photosLibrary.assets[selectedAssetIndex]
                
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    handleKeyEvent(event)
                    return event
                }
            }.onChange(of: selectedAssetIndex, perform: { newIndex in
                fullSizeImage.asset = photosLibrary.assets[newIndex]
            })
        } else {
            Text("Waiting for Photos Library authorization…")
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let asset = photosLibrary.assets[selectedAssetIndex]
        
        switch event.keyCode {
            case 123: // Left arrow key
                if selectedAssetIndex > 0 {
                    selectedAssetIndex -= 1
                }
            
            case 124: // Right arrow key
                if selectedAssetIndex < photosLibrary.assets.count - 1 {
                    selectedAssetIndex += 1
                }
            
            case 18, 19, 20: // "1", "2", "3"
                let approved = getAlbum(withName: "Approved")
                let rejected = getAlbum(withName: "Rejected")
                let needsAction = getAlbum(withName: "Needs Action")

                let albums = asset.albums()

                let isApproved = albums.contains(approved)
                let isRejected = albums.contains(rejected)
                let isNeedsAction = albums.contains(needsAction)
            
                try! PHPhotoLibrary.shared().performChangesAndWait {
                    // Strictly speaking, the first condition is a combination of two:
                    //
                    //   1. The action is `toggle-approved` and the photo is approved,
                    //      in which case toggling means un-approving it.
                    //   2. The action is anything else and the photo is approved, in
                    //      which case setting the new status means removing approved.
                    //
                    // Similar logic applies for all three conditions.
                    if isApproved {
                      asset.remove(fromAlbum: approved)
                    } else if event.keyCode == 18 {
                        asset.add(toAlbum: approved)
                    }

                    if isRejected {
                        asset.remove(fromAlbum: rejected)
                    } else if event.keyCode == 19 {
                        asset.add(toAlbum: rejected)
                    }

                    if isNeedsAction {
                        asset.remove(fromAlbum: needsAction)
                    } else if event.keyCode == 20 {
                        asset.add(toAlbum: needsAction)
                    }
                }
            
                if selectedAssetIndex > 0 {
                    selectedAssetIndex -= 1
                }
            
            case 3: // "f"
                try! PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest(for: asset).isFavorite = !asset.isFavorite
                }
            
                photosLibrary.updateAsset(atIndex: selectedAssetIndex)

            case 8: // "c"
                let crossStitch = getAlbum(withName: "Cross stitch")
            
                try! PHPhotoLibrary.shared().performChangesAndWait {
                    asset.toggle(inAlbum: crossStitch)
                }
            
                photosLibrary.updateAsset(atIndex: selectedAssetIndex)

            case 32: // "u"
                if asset.state() != nil {
                    let lastUnreviewed = photosLibrary.assets[0..<selectedAssetIndex].lastIndex(where: { asset in
                        asset.state() == nil
                    })
                    
                    if let theIndex = lastUnreviewed {
                        selectedAssetIndex = theIndex
                    }
                }
            
            
            default:
                print(event)
                break
        }
    }
}
