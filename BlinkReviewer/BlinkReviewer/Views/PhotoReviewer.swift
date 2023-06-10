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
                            Debug(asset: focusedAsset, focusedAssetIndex: focusedAssetIndex)
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
            
            case let e where e.characters == "u":
                if photosLibrary.state(of: focusedAsset) != nil {
                    if let lastUnreviewed = (focusedAssetIndex..<photosLibrary.assets2.count).first(where: { index in
                        photosLibrary.state(of: photosLibrary.assets2.object(at: index)) == nil
                    }) {
                        focusedAssetIndex = lastUnreviewed
                    }
                }
            
            case let e where e.characters == "?":
                while true {
                    let randomIndex = (0..<photosLibrary.assets2.count).randomElement()!
                    
                    if photosLibrary.state(of: photosLibrary.assets2.object(at: randomIndex)) == nil {
                        focusedAssetIndex = randomIndex
                        break
                    }
                }
            

            default:
                logger.info("Received unhandled keyboard event: \(event, privacy: .public)")
                break
        }
    }
}
