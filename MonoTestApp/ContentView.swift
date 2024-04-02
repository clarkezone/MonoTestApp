//
//  ContentView.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import SwiftUI
import SwiftData

struct TestView: View {
    
    var body: some View {
        Text("Clarkezone")
    }
}

struct TestView2: View {
    
    var body: some View {
        Text("Clarkezone 2")
    }
}


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    TestView()
                } label : {
                    Text("Link 1")
                }
                NavigationLink {
                    FullMapView()
                } label : {
                    Text("MapView")
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
                    EditButton()
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
