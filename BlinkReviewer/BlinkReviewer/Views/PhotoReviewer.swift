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
    @State private var selectedAssetIndex: Int = 0
    
    var body: some View {
        VStack {
            Divider()
            
            ThumbnailList(assets: assets, selectedAssetIndex: $selectedAssetIndex)
            
            Divider()
            
            PreviewImage(asset: assets[selectedAssetIndex])
            
            Spacer()
        }.onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                handleKeyEvent(event)
                return event
            }
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        switch event.keyCode {
            case 123: // Left arrow key
                if selectedAssetIndex > 0 {
                    selectedAssetIndex -= 1
                }
            
            case 124: // Right arrow key
                if selectedAssetIndex < assets.count - 1 {
                    selectedAssetIndex += 1
                }
            
            default:
                print(event)
                break
        }
    }
}
