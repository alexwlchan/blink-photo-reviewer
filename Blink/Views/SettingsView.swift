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
        Picker("Appearance", selection: $colorScheme) {
            Text("Dark").tag("dark")
            Text("Light").tag("light")
            Text("Match system").tag("match_system")
        }
            .padding()
    }
        
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
