//
//  ContentView.swift
//  ArcBlog
//
//  Created by Leo Ho on 28/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @Binding var connection: Connection
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(connection.test)
        }
        .padding()
        .navigationTitle("Arc Blogs")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(connection: .constant(Connection()))
    }
}
