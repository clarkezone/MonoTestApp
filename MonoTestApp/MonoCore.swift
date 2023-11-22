//
//  MonoCore.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/19/23.
//

import Foundation

struct NowSitrep: Codable {
    let city, neighborhood, metroArea, phoneStatus: String
    let postal, country, wifi: String
    let batterylevel: Double
    let timeStamp: Date
}

struct MonoCoreShared {
    public func Foo() -> String {
        
        return "Thing"
    }
    
    func getCurrentDetails() async {
        let url = URL(string: "https://now.clarkezone.dev")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            print("request")
            let (respdata, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let nowcoords = try decoder.decode(NowSitrep.self, from: respdata)

            await MainActor.run {
            print(String(data: respdata, encoding: .utf8)!)
            
//                batteryLevel = CGFloat(floatLiteral: nowcoords.batterylevel)
//                city = nowcoords.city
//                neighborhood = nowcoords.neighborhood
//                postal = nowcoords.postal
//                phoneStatus = nowcoords.country
//                wifi = nowcoords.wifi
//                latestTimestamp = nowcoords.timeStamp
//                
//                showingPopover = true
            }
        } catch {
            print("Error")
            //popoverText = "\(error)"
            //showingPopover = true
        }
    }
    
}
