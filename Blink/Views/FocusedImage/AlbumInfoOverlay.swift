import SwiftUI
import Photos

/// Show the names of the albums that a given asset is in.
///
/// Each album is shown as a separate "pill" in the list, for example:
///
///     [Cats] [Cross-stitch] [Stuff I did in 2023]
///
struct AlbumInfoOverlay: ViewModifier {
    var albums: [PHAssetCollection]
    
    init(asset: PHAsset?) {
        // Note: it's important to look up the list of albums here, and not
        // defer it to the `body()` function.
        //
        // When Swift hears about a change to the Photos Library (e.g. adding
        // a photo to an album), it will recreate this view, but if none of
        // the data has changed it won't bother re-rendering.  If the album
        // lookup is inside `body()`, it never gets run because SwiftUI thinks
        // the data is unchanged.  Putting it here ensures we get fresh data.
        self.albums = asset?.albums() ?? []
    }
    
    func body(content: Content) -> some View {
        content.overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
            HStack {
                ForEach(albums, id: \.localIdentifier) { album in
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
    }
}

extension View {
    func albumInfo(for asset: PHAsset?) -> some View {
        modifier(AlbumInfoOverlay(asset: asset))
    }
}
