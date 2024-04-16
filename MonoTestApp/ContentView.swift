//
//  ContentView.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import SwiftUI
import Sliders
import SwiftData

struct TestView: View {
    @State var value = 0.5
    @State var range = 0.2...0.8
    @State var x = 0.5
    @State var y = 0.5
    
    var body: some View {
        Group {
            ValueSlider(value: $value)
            RangeSlider(range: $range)
            PointSlider(x: $x, y: $y)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    TrackerView()
                } label : {
                    Text("LoggerUI")
                }
                NavigationLink {
                    FullMapView()
                } label : {
                    Text("QueryUI")
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
