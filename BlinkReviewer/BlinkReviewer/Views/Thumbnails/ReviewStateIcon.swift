import SwiftUI

/// Renders a small icon to show the review state, e.g. a green circled tick
/// for "Approved" images.
struct ReviewStateIcon: ViewModifier {
    let state: ReviewState?
    
    init(_ state: ReviewState?) {
        self.state = state
    }
    
    func body(content: Content) -> some View {
        if let thisState = state {
            content.overlay(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                thisState.icon()
                    .foregroundStyle(.white, thisState.color())
                    .symbolRenderingMode(.palette)
                    .padding(2)
                    .font(.title2)
                    .shadow(radius: 2.0)
            }
        } else {
            content
        }
    }
}

extension View {
    func reviewStateIcon(for state: ReviewState?) -> some View {
        modifier(ReviewStateIcon(state))
    }
}
