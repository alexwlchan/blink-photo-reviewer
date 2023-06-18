//
//  SettingsView.swift
//  Blink
//
//  Created by Alex Chan on 18/06/2023.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme: String = "dark"
    
    var body: some View {
        VStack {
            Picker("Appearance", selection: $colorScheme) {
                Text("Dark").tag("dark")
                Text("Light").tag("light")
                Text("Match system").tag("match_system")
            }
        }
            .padding()
    }
        
}
