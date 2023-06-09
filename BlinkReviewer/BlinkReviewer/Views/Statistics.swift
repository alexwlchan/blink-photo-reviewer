//
//  Statistics.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 09/06/2023.
//

import SwiftUI

struct Statistics: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    
    var body: some View {
        Text("\(photosLibrary.assets2.count) photos, \(photosLibrary.approvedAssets.count) approved, \(photosLibrary.rejectedAssets.count) rejected, \(photosLibrary.needsActionAssets.count) need action")
            .font(.title)
            .padding(10)
            .foregroundColor(.white)
            .background(.black.opacity(0.7))
            .cornerRadius(7.0)
            .shadow(radius: 2.0)
    }
}
