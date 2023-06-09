import SwiftUI

/// Defers the rendering of a view for the given period.
///
/// For example:
///
/// ```swift
/// Text("Hello, world!")
///     .deferredRendering(for: .seconds(5))
/// ```
///
/// will not display the text "Hello, world!" until five seconds after the
/// view is initially rendered.  If the view is destroyed within the delay,
/// it never renders.
///
/// This is based on code xwritten by Yonat and Charlton Provatas on
/// Stack Overflow, see https://stackoverflow.com/a/74765430/1558022
///
private struct DeferredViewModifier: ViewModifier {

    let delay: DispatchTimeInterval

    func body(content: Content) -> some View {
        _content(content)
            .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                   self.shouldRender = true
               }
            }
    }

    @ViewBuilder
    private func _content(_ content: Content) -> some View {
        if shouldRender {
            content
        } else {
            content.hidden()
        }
    }

    @State private var shouldRender = false
}

extension View {
    func deferredRendering(for delay: DispatchTimeInterval) -> some View {
        modifier(DeferredViewModifier(delay: delay))
    }
}
