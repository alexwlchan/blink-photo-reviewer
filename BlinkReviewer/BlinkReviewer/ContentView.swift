//
//  ContentView.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Divider()
            ScrollViewReader { value in
                ScrollView(.horizontal) {
                    Button("Jump to #8") {
                        value.scrollTo(8, anchor: .center)
                    }
                    .padding()
                    
                    LazyHStack(spacing: 10) {
                        ForEach(0..<100, id: \.self) { index in
                            ThumbnailItem(label: "\(index)")
                        }
                    }.padding()
                }.frame(height: 100)
            }
            
        }
        Divider()
        Spacer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
