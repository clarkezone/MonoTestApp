//
//  ContentView.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

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
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Hello \(item.name)")
//                        //Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text("Hello \(item.name)")
//                        //Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    #if os(iOS)
                    EditButton()
                    #endif
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date(), name: "Item")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
