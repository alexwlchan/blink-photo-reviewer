import SwiftUI
import Photos

/// Show the names of the albums that a given asset is in.
///
/// Each album is shown as a separate "pill" in the list, for example:
///
///     [Cats] [Cross-stitch] [Stuff I did in 2023]
///
struct AlbumInfoOverlay: ViewModifier {
    @State var asset: PHAsset?
    
    // TODO: This doesn't update properly :-/
    func body(content: Content) -> some View {
        if let thisAsset = asset {
            content.overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                HStack {
                    ForEach(thisAsset.albums(), id: \.localIdentifier) { album in
                        if let title = album.localizedTitle {
                            // Don't show the names of the meta-albums used to manage
                            // review state.
                            if (title != "Approved" && title != "Rejected" && title != "Needs Action") {
                                
                                // The icon was chosen to match the one used for albums
                                // in the sidebar in Photos.
                                Text("\(Image(systemName: "rectangle.stack")) \(title)")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .padding(5)
                                    .background(.white.opacity(0.9))
                                    .cornerRadius(7.0)
                                    .shadow(radius: 2.0)
                            }
                        }
                    }
                }.padding()
            }
        } else {
            content
        }
    }
}

extension View {
    func albumInfo(for asset: PHAsset?) -> some View {
        modifier(AlbumInfoOverlay(asset: asset))
    }
}
