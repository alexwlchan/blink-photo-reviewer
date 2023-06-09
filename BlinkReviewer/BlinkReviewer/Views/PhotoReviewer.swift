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
    @ObservedObject var fullSizeImage: PHAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize, deliveryMode: .highQualityFormat)
    
    @State var selectedAssetIndex: Int = -1
    
    @State var showStatistics: Bool = false
    
    var body: some View {
        if photosLibrary.isPhotoLibraryAuthorized {
            ZStack {
                VStack {
                    let binding = Binding {
                        selectedAssetIndex == -1 ? photosLibrary.assets2.count - 1 : selectedAssetIndex
                    } set: {
                        self.selectedAssetIndex = $0
                    }
                    
                    ThumbnailList(selectedAssetIndex: binding)
                        .environmentObject(photosLibrary)
                        .background(.gray.opacity(0.3))
                    
                    FullSizeImage(image: fullSizeImage)
                        .background(.black)
                }
                .background(.black)
                .onAppear {
                    selectedAssetIndex = photosLibrary.assets2.count - 1
                    
                    fullSizeImage.asset = photosLibrary.assets2.object(at: photosLibrary.assets2.count - 1 - selectedAssetIndex)

                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        handleKeyEvent(event)
                        return event
                    }
                }.onChange(of: selectedAssetIndex, perform: { newIndex in
                    fullSizeImage.asset = photosLibrary.assets2.object(at: photosLibrary.assets2.count - 1 - newIndex)
                })
                
                if showStatistics {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Spacer()
                            
                            Statistics().environmentObject(photosLibrary)
                        }
                        .padding()
                    }.padding()
                }
            }
        } else {
            Text("Waiting for Photos Library authorization…")
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let asset = photosLibrary.assets2.object(at: selectedAssetIndex)
        
        switch event.keyCode {
            case 123: // Left arrow key
                if selectedAssetIndex > 0 {
                    selectedAssetIndex -= 1
                }
            
            case 124: // Right arrow key
                if selectedAssetIndex < photosLibrary.assets2.count - 1 {
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
            
                photosLibrary.updateAsset(atIndex: selectedAssetIndex)
            
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
                print("not implemented yet!")
//                if photosLibrary.state(for: asset) != nil {
//                    let lastUnreviewed = photosLibrary.assets2
//
//                    [0..<selectedAssetIndex].lastIndex(where: { asset in
//                        photosLibrary.state(for: asset) == nil
//                    })
//
//                    if let theIndex = lastUnreviewed {
//                        selectedAssetIndex = theIndex
//                    }
//                }
            
            case 1: // "s"
                showStatistics.toggle()
            
            default:
                print(event)
                break
        }
    }
}
