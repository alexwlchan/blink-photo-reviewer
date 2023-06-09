import SwiftUI
import Photos

/// Renders a progress indicator if we're waiting for the image to load.
///
/// This is for when Photos is taking a while to load the high-quality version
/// of a photo; see the comment on `PHAssetImage`.
struct LoadingIndicatorOverlay: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        if (isLoading) {
            content.overlay(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                
                // `ProgressView` does have a `tint` modifier, but that doesn't seem to
                // work on macOS 13 -- this uses some code from a Stack Overflow answer
                // by aheze: https://stackoverflow.com/a/66568704/1558022
                ProgressView()
                    .colorInvert()
                    .brightness(1)
                    .padding()
                    .deferredRendering(
                        // Note: even if the image is already cached locally, the
                        // image caching manager typically sends two images: a low-res
                        // version comes immediately, then a higher-res version within
                        // a second or two.  This causes the progress indicator to
                        // "flash" -- it appears then almost instantly disappears.
                        //
                        // Deferring the rendering by a second avoids this "flash".
                        for: .seconds(1)
                    )
            }
        } else {
            content
        }
    }
}

extension View {
    func loadingIndicator(isLoading: Bool) -> some View {
        modifier(LoadingIndicatorOverlay(isLoading: isLoading))
    }
}
