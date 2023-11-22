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
    
    func getCurrentDetails() async throws -> NowSitrep {
        let url = URL(string: "https://now.clarkezone.dev")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (respdata, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let nowcoords = try decoder.decode(NowSitrep.self, from: respdata)
        return nowcoords
    }
    
}
