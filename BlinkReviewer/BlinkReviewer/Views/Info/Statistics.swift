import SwiftUI

/// Show a couple of stats about how much reviewing has been done, e.g.
///
///     15,279 photos, 9,158 approved, 17 rejected, 181 need action
///     
struct Statistics: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    
    var body: some View {
        Text("\(photosLibrary.assets.count) photos, \(photosLibrary.approvedAssets.count) approved, \(photosLibrary.rejectedAssets.count) rejected, \(photosLibrary.needsActionAssets.count) need action")
            .font(.title)
            .padding(10)
            .foregroundColor(.white)
            .background(.black.opacity(0.7))
            .cornerRadius(7.0)
            .shadow(radius: 2.0)
            .textSelection(.enabled)
    }
}
