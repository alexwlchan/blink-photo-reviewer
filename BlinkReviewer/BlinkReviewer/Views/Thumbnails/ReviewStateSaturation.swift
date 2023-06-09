import SwiftUI

/// Desaturates rejected images.
struct ReviewStateSaturation: ViewModifier {
    let isRejected: Bool
    
    init(_ isRejected: Bool) {
        self.isRejected = isRejected
    }
    
    func body(content: Content) -> some View {
        if isRejected {
            content.saturation(0.0)
        } else {
            content
        }
    }
}

extension View {
    func reviewStateColor(isRejected: Bool) -> some View {
        modifier(ReviewStateSaturation(isRejected))
    }
}
