//
//  PhotoReviewer.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

struct PhotoReviewer: View {
    var assets: [PHAsset]
    @State var selectedAssetIndex: Int
    
    var body: some View {
        VStack {
            ThumbnailList(assets: assets, selectedAssetIndex: $selectedAssetIndex)
            
            PreviewImage(asset: assets[selectedAssetIndex])
                .background(.black)
        }.onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                handleKeyEvent(event)
                return event
            }
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let asset = assets[selectedAssetIndex]
        
        switch event.keyCode {
            case 123: // Left arrow key
                if selectedAssetIndex > 0 {
                    selectedAssetIndex -= 1
                }
            
            case 124: // Right arrow key
                if selectedAssetIndex < assets.count - 1 {
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
            
            default:
                print(event)
                break
        }
    }
}
