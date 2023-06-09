//
//  DeferredRendering.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 09/06/2023.
//

import SwiftUI

/// A ViewModifier that defers its rendering until after the provided threshold surpasses
private struct DeferredViewModifier: ViewModifier {

    let threshold: Double

    func body(content: Content) -> some View {
        _content(content)
            .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + threshold) {
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
    func deferredRendering(for seconds: Double) -> some View {
        modifier(DeferredViewModifier(threshold: seconds))
    }
}
