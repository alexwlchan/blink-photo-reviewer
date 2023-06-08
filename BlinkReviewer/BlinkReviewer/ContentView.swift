//
//  ContentView.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PhotoReviewer(assets: getAllPhotos())
    }
}
