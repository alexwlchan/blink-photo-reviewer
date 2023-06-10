import SwiftUI

/// Renders a small icon to show the review state, e.g. a green circled tick
/// for "Approved" images.
struct ReviewStateIcon: ViewModifier {
    let state: ReviewState?
    let isFocused: Bool
    
    init(_ state: ReviewState?, _ isFocused: Bool) {
        self.state = state
        self.isFocused = isFocused
    }
    
    func body(content: Content) -> some View {
        if let thisState = state {
            content.overlay(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                thisState.icon()
                    .foregroundStyle(.white, thisState.color())
                    .symbolRenderingMode(.palette)
                    .padding(2)
                    .font(isFocused ? .title2 : .title3)
                    .shadow(radius: 2.0)
            }
        } else {
            content
        }
    }
}

extension View {
    func reviewStateIcon(for state: ReviewState?, _ isFocused: Bool) -> some View {
        modifier(ReviewStateIcon(state, isFocused))
    }
}
