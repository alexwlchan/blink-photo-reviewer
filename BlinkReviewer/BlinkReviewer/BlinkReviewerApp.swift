//
//  BlinkReviewerApp.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI

@main
struct BlinkReviewerApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoReviewer(selectedAssetIndex: PhotosLibrary().assets.count - 1)
                .environmentObject(PhotosLibrary())
        }
    }
}
