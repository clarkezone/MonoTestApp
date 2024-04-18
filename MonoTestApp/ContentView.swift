//
//  ContentView.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    
    @State private var activeDetail: String? = nil

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    #if os(iOS)
                    TrackerView()
                    #endif
                } label : {
                    Text("Bg activity, interactive widget, live activity")
                }
                NavigationLink {
                    FullMapView()
                } label : {
                    Text("QueryUI - Mapview")
                }
                NavigationLink {
                    ShareplayView()
                } label : {
                    Text("Shareplay")
                }
                NavigationLink {
                    PhotoView()
                } label : {
                    Text("Photos")
                }
                NavigationLink {
                    SwiftDataView()
                } label : {
                    Text("SwiftData")
                }
                NavigationLink {
                    #if os(iOS)
                    //SliderBindingTestView()
                    #endif
                } label : {
                    Text("SliderBinding")
                }
                NavigationLink {
                    RiveTestView()
                } label : {
                    Text("Rive")
                }
                NavigationLink {
                    SettingsView()
                } label : {
                    Text("Settings")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: gotosettings) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        } detail: {
            detailViewSelector()
        }
    }

    private func gotosettings() {
        print("Settings button pressed")
        activeDetail = "settings"
    }
    
    @ViewBuilder
        private func detailViewSelector() -> some View {
            if let detail = activeDetail, detail == "settings" {
                SettingsView()
            } else {
                Text("Select an item")
            }
        }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
