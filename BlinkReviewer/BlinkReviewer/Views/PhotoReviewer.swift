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
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        // TODO: placeholder images for start/end
                        ForEach(assets, id: \.localIdentifier) { asset in
                            ThumbnailItem(thumbnail: asset.getThumbnail(), isSelected: assets[selectedAssetIndex].localIdentifier == asset.localIdentifier)
                        }
                    }.padding()
                }.frame(height: 100)
                    .onChange(of: selectedAssetIndex, perform: { newIndex in
                        proxy.scrollTo(assets[newIndex].localIdentifier, anchor: .center)
                    })
            }
            Divider()
            
            PreviewImage(asset: assets[selectedAssetIndex])
            
            Spacer()
        }.onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                
                print("about to handle event \(event)")
                handleKeyEvent(event)
                print("finished handling event \(event)")
                
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
