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
        ZStack {
            VStack {
                Image(systemName: "character.book.closed.fill")
                    .resizable()
                    .frame(width: 48, height: 54)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 4)
                Text("Arc Blogs")
                    .font(.system(size: 28))
                    .padding(.bottom, 4)
                Text("Space → Blog")
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                Spacer()
            }
            .padding(.top, 4)
            
            VStack {
                Spacer()
                Form {
                    TextField(
                        text: .constant(""),
                        prompt: Text("Required")
                    ) {
                        Text("Server URL")
                    }
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 4)
                    SecureField(
                        text: .constant(""),
                        prompt: Text("Required")
                    ) {
                        Text("Secret Key")
                    }
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 4)
                    Picker("Space", selection: .constant("Personal")) {
                        Text("Personal")
                        Text("Work")
                        Text("Blog")
                    }
                    .pickerStyle(.menu)
                    .padding(.top, 1)
                }
                Button("Connect") {
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                Divider()
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                HStack {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                    Text("Not connected")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .navigationTitle("Arc Blogs")
        .frame(width: 300, height: 370)
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(connection: .constant(Connection()))
    }
}
