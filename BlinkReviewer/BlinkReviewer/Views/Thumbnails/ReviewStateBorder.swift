import SwiftUI

import SwiftUI

/// Renders a small icon to show the review state, e.g. a green circled tick
/// for "Approved" images.
struct ReviewStateBorder: ViewModifier {
    let state: ReviewState?
    let cornerRadius: CGFloat
    
    init(_ state: ReviewState?, _ cornerRadius: CGFloat) {
        self.state = state
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content.overlay() {
            // This technique for drawing a coloured border with rounded corners
            // comes from an article by Simon Ng:
            // https://www.appcoda.com/swiftui-border/
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    state?.color() ?? .gray.opacity(0.7),
                    lineWidth: state != nil ? 3.0 : 3.0 * 5.0 / 7.0
                )
        }
    }
}

extension View {
    func reviewStateBorder(for state: ReviewState?, with cornerRadius: CGFloat) -> some View {
        modifier(ReviewStateBorder(state, cornerRadius))
    }
}
