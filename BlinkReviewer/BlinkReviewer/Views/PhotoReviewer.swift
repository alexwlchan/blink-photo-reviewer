//
//  PhotoReviewer.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import OSLog
import SwiftUI
import Photos

struct PhotoReviewer: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @ObservedObject var fullSizeImage: PHAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize, deliveryMode: .highQualityFormat)
    
    // Which asset is currently in focus?
    //
    // i.e. scrolled to in the thumbnail pane, showing a big preview.
    //
    // This is 0-indexed and counts from the right -- that is, the rightmost item
    // is the 0th.
    @State var focusedAssetIndex: Int = 0
    
    var focusedAsset: PHAsset {
        photosLibrary.assets2.object(at: focusedAssetIndex)
    }
    
    @State var showStatistics: Bool = false
    @State var showDebug: Bool = false
    
    // This contains the big image that is currently in focus.  See the comments
    // on FocusedImage for why this state is defined outside that view.
    @ObservedObject var focusedAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize, deliveryMode: .highQualityFormat)
    
    var body: some View {
        if !photosLibrary.isPhotoLibraryAuthorized {
            Text("Waiting for Photos Library authorization…")
        } else if photosLibrary.assets2.count == 0 {
            Text("Waiting for Photos Library data…")
        } else {
            ZStack {
                VStack {
                    ThumbnailList(focusedAssetIndex: $focusedAssetIndex)
                        .environmentObject(photosLibrary)
                        .frame(height: 90)
                        .background(.gray.opacity(0.7))
                    
                    FocusedImage(assetImage: focusedAssetImage)
                        .environmentObject(photosLibrary)
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        if showDebug {
                            Debug(asset: focusedAsset)
                        }
                        
                        if showStatistics {
                            Statistics().environmentObject(photosLibrary)
                        }
                    }.padding()
                }.padding()
            }
            .background(.black)
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    handleKeyEventNew(event)
                    return event
                }
            }
            // These two lines update the big image that fills most of the window.
            // See the comments on FocusedImage for more explanation of why this is
            // managed this way.
            .onAppear { focusedAssetImage.asset = focusedAsset }
            .onChange(of: focusedAsset) { newFocusedAsset in
                focusedAssetImage.asset = newFocusedAsset
            }
        }
    }

    private func handleKeyEventNew(_ event: NSEvent) {
        let logger = Logger()
        
        switch event {
            case let e where e.specialKey == NSEvent.SpecialKey.leftArrow:
                print("to the left!")
                if focusedAssetIndex < photosLibrary.assets2.count - 1 {
                    focusedAssetIndex += 1
                }
            
            case let e where e.specialKey == NSEvent.SpecialKey.rightArrow:
                print("to the right!")
                if focusedAssetIndex > 0 {
                    focusedAssetIndex -= 1
                }
            
            case let e where e.characters == "1" || e.characters == "2" || e.characters == "3":
                print("time to review!")
                let state = photosLibrary.state(of: focusedAsset)
            
                let approved = getAlbum(withName: "Approved")
                let rejected = getAlbum(withName: "Rejected")
                let needsAction = getAlbum(withName: "Needs Action")
            
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
                    if state == .Approved {
                        focusedAsset.remove(fromAlbum: approved)
                    } else if e.characters == "1" {
                        focusedAsset.add(toAlbum: approved)
                    }

                    if state == .Rejected {
                        focusedAsset.remove(fromAlbum: rejected)
                    } else if e.characters == "2" {
                        focusedAsset.add(toAlbum: rejected)
                    }

                    if state == .NeedsAction {
                        focusedAsset.remove(fromAlbum: needsAction)
                    } else if e.characters == "3" {
                        focusedAsset.add(toAlbum: needsAction)
                    }
                }
            
                if focusedAssetIndex < photosLibrary.assets2.count - 1 {
                    focusedAssetIndex += 1
                }
            
            case let e where e.characters == "c":
                let crossStitch = getAlbum(withName: "Cross stitch")
            
                try! PHPhotoLibrary.shared().performChangesAndWait {
                    focusedAsset.toggle(inAlbum: crossStitch)
                }
            
            case let e where e.characters == "f":
                try! PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest(for: focusedAsset).isFavorite = !focusedAsset.isFavorite
                }

            case let e where e.characters == "d":
                showDebug.toggle()
            
            case let e where e.characters == "s":
                showStatistics.toggle()
            
            default:
                logger.info("Received unhandled keyboard event: \(event, privacy: .public)")
                break
        }
    }
//
//    private func handleKeyEvent(_ event: NSEvent) {
//        let asset = photosLibrary.assets2.object(at: photosLibrary.assets2.count - 1 - selectedAssetIndex)
//
//        switch event.keyCode {
//            case 123: // Left arrow key
//                if selectedAssetIndex > 0 {
//                    selectedAssetIndex -= 1
//                }
//
//            case 124: // Right arrow key
//                if selectedAssetIndex < photosLibrary.assets2.count - 1 {
//                    selectedAssetIndex += 1
//                }
//
//            case 18, 19, 20: // "1", "2", "3"
//                let state = photosLibrary.state(for: asset)
//
//                let approved = getAlbum(withName: "Approved")
//                let rejected = getAlbum(withName: "Rejected")
//                let needsAction = getAlbum(withName: "Needs Action")
//
//                try! PHPhotoLibrary.shared().performChangesAndWait {
//                    // Strictly speaking, the first condition is a combination of two:
//                    //
//                    //   1. The action is `toggle-approved` and the photo is approved,
//                    //      in which case toggling means un-approving it.
//                    //   2. The action is anything else and the photo is approved, in
//                    //      which case setting the new status means removing approved.
//                    //
//                    // Similar logic applies for all three conditions.
//                    if state == .Approved {
//                        print("removing asset \(asset.localIdentifier) from approved")
//                        asset.remove(fromAlbum: approved)
//                    } else if event.keyCode == 18 {
//                        print("adding asset \(asset.localIdentifier) to approved")
//                        asset.add(toAlbum: approved)
//                    }
//
//                    if state == .Rejected {
//                        asset.remove(fromAlbum: rejected)
//                    } else if event.keyCode == 19 {
//                        asset.add(toAlbum: rejected)
//                    }
//
//                    if state == .NeedsAction {
//                        asset.remove(fromAlbum: needsAction)
//                    } else if event.keyCode == 20 {
//                        asset.add(toAlbum: needsAction)
//                    }
//                }
//
//                photosLibrary.updateAsset(atIndex: selectedAssetIndex)
//
//                if selectedAssetIndex > 0 {
//                    selectedAssetIndex -= 1
//                }
//
//            case 3: // "f"
//                try! PHPhotoLibrary.shared().performChangesAndWait {
//                    PHAssetChangeRequest(for: asset).isFavorite = !asset.isFavorite
//                }
//
//                photosLibrary.updateAsset(atIndex: selectedAssetIndex)
//
//            case 8: // "c"
//                let crossStitch = getAlbum(withName: "Cross stitch")
//
//                try! PHPhotoLibrary.shared().performChangesAndWait {
//                    asset.toggle(inAlbum: crossStitch)
//                }
//
//                photosLibrary.updateAsset(atIndex: selectedAssetIndex)
//
//            case 32: // "u"
//                print("not implemented yet!")
////                if photosLibrary.state(for: asset) != nil {
////                    let lastUnreviewed = photosLibrary.assets2
////
////                    [0..<selectedAssetIndex].lastIndex(where: { asset in
////                        photosLibrary.state(for: asset) == nil
////                    })
////
////                    if let theIndex = lastUnreviewed {
////                        selectedAssetIndex = theIndex
////                    }
////                }
//
//            case 1: // "s"
//                showStatistics.toggle()
//
//            case 2: // "d"
//                showDebug.toggle()
//
//            default:
//                print(event)
//                break
//        }
//    }
}
