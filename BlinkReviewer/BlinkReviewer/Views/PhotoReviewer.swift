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
    let logger = Logger()
    
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @ObservedObject var fullSizeImage: PHAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize, deliveryMode: .highQualityFormat)
    
    // Which asset is currently in focus?
    //
    // i.e. scrolled to in the thumbnail pane, showing a big preview.
    //
    // This is 0-indexed and counts from the right -- that is, the rightmost item
    // is the 0th.
    @State var focusedAssetIndex: Int = 0
    
    @State var _focusedAsset: PHAsset? = nil
    
    var focusedAsset: PHAsset {
        return photosLibrary.assets2.object(at: focusedAssetIndex)
    }
    
    @State var showStatistics: Bool = false
    @State var showDebug: Bool = false
    @State var showInfo: Bool = false
    
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
                        .background(.gray.opacity(0.3))
                    
                    FocusedImage(assetImage: focusedAssetImage)
                        .environmentObject(photosLibrary)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    if showDebug {
                        HStack {
                            Spacer()
                            Debug(asset: focusedAsset, focusedAssetIndex: focusedAssetIndex)
                        }.padding()
                    }
                    
                    if showInfo {
                        HStack {
                            Spacer()
                            Info(asset: focusedAsset)
                        }.padding()
                    }
                    
                    if showStatistics {
                        HStack {
                            Spacer()
                            Statistics().environmentObject(photosLibrary)
                        }.padding()
                    }
                }.padding()
            }
            .background(.black)
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    handleKeyDown(event)
                    return event
                }
            }
            // These two lines update the big image that fills most of the window.
            // See the comments on FocusedImage for more explanation of why this is
            // managed this way.
            .onAppear { focusedAssetImage.asset = focusedAsset }
            .onChange(of: focusedAssetIndex) { _ in
                focusedAssetImage.asset = focusedAsset
            }
            // These two methods are used to preserve position when there are changes
            // in the Photos Library, e.g. deleted assets.
            //
            // We cache the currently focused asset, so we know what we were looking at
            // before the library changed, and we call the `updateFocusAfterLibraryChange`
            // handler whenever we see a change.
            .onChange(of: focusedAssetIndex, perform: { _ in
                self._focusedAsset = self.focusedAsset
            })
            .onChange(of: photosLibrary.latestChangeDetails, perform: updateFocusAfterLibraryChange)
        }
    }
    
    /// Try to maintain the focused asset when the Photos Library changes.
    ///
    /// The goal is to keep the user looking at the same asset before/after the
    /// library data changes.  This isn't always possible, e.g. if the asset has
    /// just been deleted, but we do a best effort attempt.
    private func updateFocusAfterLibraryChange(lastChangeDetails: PHFetchResultChangeDetails<PHAsset>?) -> Void {
        
        // Create a change ID.  This doesn't mean anything outside the context
        // of this function, but is useful for correlating log messages.
        let changeId = UUID()
        
        logger.debug("Updating focus after Photos Library change [\(changeId, privacy: .public)]")
        
        // Maybe this change doesn't affect the currently focused asset; if so,
        // we can stop immediately.
        //
        // e.g. the change is about album data, or all the changes are further
        // along than the focused asset.
        if photosLibrary.assets2.object(at: focusedAssetIndex) == self._focusedAsset {
            logger.debug("Focused asset is in the same place as before, nothing to do [\(changeId, privacy: .public)]")
            return
        }
        
        let start = DispatchTime.now()
        var elapsed = start

        func printElapsed(_ label: String) -> Void {
          let now = DispatchTime.now()

          let totalInterval = Double(now.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
          let elapsedInterval = Double(now.uptimeNanoseconds - elapsed.uptimeNanoseconds) / 1_000_000_000

          elapsed = DispatchTime.now()

          print("Time to \(label):\n  \(elapsedInterval) seconds (\(totalInterval) total)")
        }
        
        // The ChangeDetails can tell us how many assets were inserted/removed by
        // the change, but only if it was a small change -- if it was a bigger change,
        // we're meant to reload from scratch.
        //
        // Try looking at these properties first -- these deltas will typically be small,
        // so we can evaluate them quickly.  We look for all the indexes which have changed
        // before the currently focused index.
        let hasLastChangeDetails = lastChangeDetails != nil
        let hasIncrementalChanges = lastChangeDetails?.hasIncrementalChanges == true
        
        var delta: Int? = nil
        
        if hasLastChangeDetails && hasIncrementalChanges {
            logger.debug("Photos Library update has incremental changes [\(changeId, privacy: .public)]")
            let removedIndexes = lastChangeDetails!.removedIndexes?
                .filter { $0 <= focusedAssetIndex }
                .count ?? 0
            
            let insertedIndexes = lastChangeDetails!.insertedIndexes?
                .filter { $0 <= focusedAssetIndex }
                .count ?? 0
            
            logger.debug("Removed indexes = \(removedIndexes, privacy: .public), inserted indexes = \(insertedIndexes, privacy: .public) [\(changeId, privacy: .public)]")
            
            delta = insertedIndexes - removedIndexes
        }
                                       
        // If we've got a delta, check to see if it points us to the right asset.
        //
        // If it does, we're done!
        if photosLibrary.assets2.object(at: focusedAssetIndex + (delta ?? 0)) == self._focusedAsset {
            logger.debug("Incremental changes found the new position of the asset [\(changeId, privacy: .public)]")
            focusedAssetIndex += delta ?? 0
            return
        }
        
        // If we didn't get incremental changes or the incremental changes pointed us
        // to the wrong place, then something bigger has changed in the Photos library.
        //
        // Maybe some assets have "moved" (I don't fully understand what that means without
        // an example, and I suspect it may not apply to this use case, where we're sorting
        // all the assets by creationDate), or maybe there were too many updates for
        // an incremental change.
        //
        // In this case, let's see if we can find the asset in the update FetchResult.
        //
        // This is potentially quite slow, especially if we've already gone a long way
        // into the Photos Library, which is why we leave it for last.
        let matchingAssetInUpdatedLibrary =
            (0..<photosLibrary.assets2.count)
                .first(where: {
                    photosLibrary.assets2.object(at: $0).localIdentifier ==
                        self._focusedAsset?.localIdentifier
                })
        
        if let newIndex = matchingAssetInUpdatedLibrary {
            logger.debug("Found an asset with matching identifier by doing a linear search [\(changeId, privacy: .public)]")
            self.focusedAssetIndex = newIndex
            return
        }
        
        // If we still haven't found the asset, then it must have been deleted as
        // part of this change.  We can't keep the user in the same place, but
        // maybe we can keep them nearby.
        //
        // Apply the delta from incremental changes (if we have it); there's not much
        // more we can do without storing ever-larger amounts of state to pick a
        // suitable restore point.
        logger.debug("Focused asset was deleted as part of the changes; making best-effort guess at new focus position [\(changeId, privacy: .public)]")
        self.focusedAssetIndex += (delta ?? 0)
    }

    private func handleKeyDown(_ event: NSEvent) {
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
            
            case let e where e.characters == "i":
                showInfo.toggle()
            
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
