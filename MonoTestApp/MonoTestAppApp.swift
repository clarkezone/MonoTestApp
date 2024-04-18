//
//  MonoTestAppApp.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct MonoTestAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self, CounterData.self, AppSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        
//        let result = BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.devname.appname.refresh", using: DispatchQueue.main) { task in
//            print("Hello")
//            self.handleAppRefresh(task: task)
//        }
//        print(result)
        
        //BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.devname.appname.refresh", using: DispatchQueue.main) { task in
        //            self.handleAppRefresh(task: task as! BGProcessingTask)
        
        
    }
    
    func handleAppRefresh(task: BGTask) {
        //Scehdules a second refresh
        scheduleAppRefresh()
        //BGNotification()
        print("BG Background Task fired")
    }
    
    func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "com.devname.appname.refresh")
        request.requiresNetworkConnectivity = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // Fetch no earlier than 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BGTask Scheduled")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            if #available(iOS 17.0, *) {
                //FullMapView()
            }
        } .onChange(of: scenePhase) { phase, newphase in

            switch newphase {
                        case .background: scheduleAppRefresh()
                        default: break
                        }
        } .backgroundTask(.appRefresh("com.devname.appname.refresh")) {
            print("Getting refreshed")
        }
        .modelContainer(sharedModelContainer)
        
    }
}
