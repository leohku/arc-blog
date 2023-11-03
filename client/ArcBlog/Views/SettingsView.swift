//
//  ContentView.swift
//  ArcBlog
//
//  Created by Leo Ho on 28/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var sidebarStore: SidebarStore
    @State var serverURL: String = ""
    @State var secretKey: String = ""
    @State var space: String = ""
    
    var body: some View {
        let connectionState = connectionStore.connection.state
        let isConnectingOrConnected = [ConnectionState.connecting, ConnectionState.connected].contains(connectionState)
        let isDisconnectedOrFailed = [ConnectionState.disconnected, ConnectionState.failed].contains(connectionState)
        let auxiliaryText: String = ({
            switch connectionState {
                case ConnectionState.connected:
                    let streaming = connectionStore.connection.persistedData.streaming
                    return "Streaming \(streaming ? "on" : "off")"
                case ConnectionState.failed:
                    if connectionStore.connection.error != nil {
                        return connectionStore.connection.error!.localizedDescription
                    } else {
                        return ""
                    }
                default:
                    return ""
            }
        }())
        ZStack {
            VStack {
                Image(systemName: "character.book.closed.fill")
                    .resizable()
                    .frame(width: 48, height: 54)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 4)
                Text("Arc Blog")
                    .font(.system(size: 28))
                    .padding(.bottom, 4)
                Text("v0.1 Beta")
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                Spacer()
            }
            .padding(.top, 4)
            
            VStack {
                Spacer()
                Form {
                    TextField(
                        text: $serverURL,
                        prompt: Text("Required")
                    ) {
                        Text("Server URL")
                    }
                    .disabled(isConnectingOrConnected)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 4)
                    SecureField(
                        text: $secretKey,
                        prompt: Text("Required")
                    ) {
                        Text("Secret Key")
                    }
                    .disabled(isConnectingOrConnected)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 4)
                    Picker("Space", selection: $space) {
                        ForEach(sidebarStore.sidebar.spaces, id: \.self) {
                            Text($0.title).tag($0.title)
                        }
                    }
                    .disabled(isConnectingOrConnected)
                    .pickerStyle(.menu)
                    .padding(.top, 1)
                }
                Button(
                    connectionState == ConnectionState.connected ?
                        "Disconnect" :
                        "Connect"
                ) {
                    if (isDisconnectedOrFailed) {
                        Task {
                            do {
                                try await connectionStore.connect(settings: Settings(
                                    serverURL: $serverURL.wrappedValue,
                                    secretKey: $secretKey.wrappedValue,
                                    space: $space.wrappedValue))
                            } catch {
                                showError(title: ErrorTitle.unableToConnect.rawValue,
                                          text: error.localizedDescription)
                            }
                        }
                    } else {
                        Task {
                            do {
                                try await connectionStore.disconnect()
                            } catch {
                                showError(title: ErrorTitle.unableToDisconnect.rawValue,
                                          text: error.localizedDescription)
                            }
                        }
                    }
                }
                .disabled(connectionState == ConnectionState.connecting)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                Divider()
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                HStack {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundColor(connectionState.statusColor())
                    Text(connectionState.statusText())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(auxiliaryText)
                }
            }
        }
        .padding()
        .navigationTitle("Arc Blog")
        .frame(width: 300, height: 370)
        .onAppear(perform: {
            let persistedData = connectionStore.connection.persistedData
            if persistedData.settings != nil {
                self.serverURL = persistedData.settings!.serverURL
                self.secretKey = persistedData.settings!.secretKey
                if (sidebarStore.sidebar.spaces
                    .map { $0.title }
                    .contains(persistedData.settings!.space)) {
                        self.space = persistedData.settings!.space
                    } else {
                        self.space = sidebarStore.sidebar.spaces.count > 0 ? sidebarStore.sidebar.spaces[0].title : ""
                    }
            } else {
                self.space = sidebarStore.sidebar.spaces.count > 0 ? sidebarStore.sidebar.spaces[0].title : ""
            }
        })
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ConnectionStore())
            .environmentObject(SidebarStore())
    }
}
