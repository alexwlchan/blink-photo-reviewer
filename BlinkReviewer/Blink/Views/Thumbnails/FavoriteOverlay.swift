import SwiftUI
import Photos

/// Renders a small heart to indicate a photo is a "Favorite".
///
/// This is meant to match the way favorite items are marked in Photos.
struct FavoriteHeartIcon: ViewModifier {
    let isFavorite: Bool
    let isFocused: Bool
    
    init(_ isFavorite: Bool, _ isFocused: Bool) {
        self.isFavorite = isFavorite
        self.isFocused = isFocused
    }
    
    func body(content: Content) -> some View {
        if isFavorite {
            content.overlay(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.white)
                    .padding(3)
                    .font(isFocused ? .title3 : .body)
                    .shadow(radius: 2.0)
            }
        } else {
            content
        }
    }
}

extension View {
    func favoriteHeartIcon(_ isFavorite: Bool, _ isFocused: Bool) -> some View {
        modifier(FavoriteHeartIcon(isFavorite, isFocused))
    }
}
