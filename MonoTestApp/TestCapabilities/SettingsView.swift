//
//  SettingsView.swift
//  MonoTestApp
//
//  Created by James Clarke on 4/18/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var settings: AppSettings?
    @State private var urlText: String = ""
    
    var body: some View {
       
            VStack {
                if let settings {
                    TextField("Enter URL", text: $urlText, onCommit: saveSettings)
                                       .textFieldStyle(RoundedBorderTextFieldStyle())
                                       .padding()
                } else {
                    Text("Loading..")
                }
            }
            .navigationTitle("Settings")
            .onAppear(perform: load)
        
      
    }
    
    private func load() {
        print("loading")
        let request = FetchDescriptor<AppSettings>()
        var data = try? modelContext.fetch(request)
        
        var da = data!
        
        if da.count > 0 {
            settings = data?.first
            print("we have \(da.count) data with value [\(settings?.queryendpointurl)]")
        } else {
            print("creating record")
            modelContext.insert(AppSettings(url: "https://geoquery.tail967d8.ts.net/geoquery"))
            data = try? modelContext.fetch(request)
            settings = data?.first
        }
        urlText = settings?.queryendpointurl ?? "NotSet"
    }
    
    private func saveSettings() {
            print("Saving settings")
            if let settings = settings {
                settings.queryendpointurl = urlText
                try? modelContext.save()  // Assuming modelContext has a save method
            }
        }
}

#Preview {
    SettingsView().modelContainer(for: AppSettings.self, inMemory: true)
}
