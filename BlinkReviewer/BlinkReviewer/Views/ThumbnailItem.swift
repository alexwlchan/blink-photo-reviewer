//
//  ThumbnailItem.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI

struct ThumbnailItem: View {
    @State var label: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.yellow)
                .frame(width: 70, height: 70)
            Text(label)
                .font(.title)
        }
    }
}

struct ThumbnailItem_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailItem(label: "1")
    }
}
