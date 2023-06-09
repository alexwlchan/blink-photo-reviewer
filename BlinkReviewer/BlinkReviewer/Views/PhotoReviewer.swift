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
    
    @State var selectedAssetIndex: Int = -1
    
    @State var showStatistics: Bool = false
    @State var showDebug: Bool = true
    
    var body: some View {
        if photosLibrary.isPhotoLibraryAuthorized {
            ZStack {
                VStack {
                    PHAssetHStack(photosLibrary.assets2) { asset, index in
                        VStack {
                            
                            NewThumbnailImage(asset)
//                                .resizable()
                                .saturation(photosLibrary.state(for: asset) == .Rejected ? 0.0 : 1.0)
                                // Note: it's taken several attempts to get this working correctly;
                                // it behaves differently in the running app to the SwiftUI preview.
                                //
                                // Expected properties:
                                //
                                //    - Thumbnails are square
                                //    - Thumbnails are expanded to fill the square, but they prefer
                                //      to crop rather than stretch the image
                                //
                                .scaledToFill()
                                .frame(width: 70.0, height: 70.0, alignment: .center)
                                .border(.green)
//                            Text("\(index) / \(asset.localIdentifier)")
                        }
                    }
                }
//                
//                VStack {
//                    let binding = Binding {
//                        selectedAssetIndex == -1 ? photosLibrary.assets2.count - 1 : selectedAssetIndex
//                    } set: {
//                        self.selectedAssetIndex = $0
//                    }
//                    
//                    ThumbnailList(selectedAssetIndex: binding)
//                        .environmentObject(photosLibrary)
//                        .background(.gray.opacity(0.3))
//                    
//                    FullSizeImage(image: fullSizeImage)
//                        .background(.black)
//                }
//                .background(.black)
//                .onAppear {
//                    selectedAssetIndex = photosLibrary.assets2.count - 1
//                    
//                    fullSizeImage.asset = photosLibrary.assets2.object(at: photosLibrary.assets2.count - 1 - selectedAssetIndex)
//                    
//                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
//                        handleKeyEvent(event)
//                        return event
//                    }
//                }.onChange(of: selectedAssetIndex, perform: { newIndex in
//                    fullSizeImage.asset = photosLibrary.assets2.object(at: photosLibrary.assets2.count - 1 - newIndex)
//                })
//                
//                HStack {
//                    Spacer()
//                    
//                    VStack {
//                        Spacer()
//                        
//                        if showStatistics {
//                            Statistics().environmentObject(photosLibrary)
//                        }
//                        
//                        if showDebug {
//                            Text("\(fullSizeImage.asset?.localIdentifier ?? "(none)")")
//                                .font(.title)
//                                .padding(10)
//                                .foregroundColor(.white)
//                                .background(.black.opacity(0.7))
//                                .cornerRadius(7.0)
//                                .shadow(radius: 2.0)
//                        }
//                    }
//                    .padding()
//                }.padding()
            }
        } else {
            Text("Waiting for Photos Library authorization…")
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let asset = photosLibrary.assets2.object(at: photosLibrary.assets2.count - 1 - selectedAssetIndex)
        
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
                let state = photosLibrary.state(for: asset)
            
                let approved = getAlbum(withName: "Approved")
                let rejected = getAlbum(withName: "Rejected")
                let needsAction = getAlbum(withName: "Needs Action")

                try! PHPhotoLibrary.shared().performChangesAndWait {
                    // Strictly speaking, the first condition is a combination of two:
                    //
                    //   1. The action is `toggle-approved` and the photo is approved,
                    //      in which case toggling means un-approving it.
                    //   2. The action is anything else and the photo is approved, in
                    //      which case setting the new status means removing approved.
                    //
                    // Similar logic applies for all three conditions.
                    if state == .Approved {
                        print("removing asset \(asset.localIdentifier) from approved")
                        asset.remove(fromAlbum: approved)
                    } else if event.keyCode == 18 {
                        print("adding asset \(asset.localIdentifier) to approved")
                        asset.add(toAlbum: approved)
                    }

                    if state == .Rejected {
                        asset.remove(fromAlbum: rejected)
                    } else if event.keyCode == 19 {
                        asset.add(toAlbum: rejected)
                    }

                    if state == .NeedsAction {
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
            
            case 2: // "d"
                showDebug.toggle()
            
            default:
                print(event)
                break
        }
    }
}
