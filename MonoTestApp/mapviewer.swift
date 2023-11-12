import SwiftUI
import MapKit
import Foundation

struct MapView: View {
//    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Binding public var currentRegion: MKCoordinateRegion

    var body: some View{
        Map(coordinateRegion: $currentRegion).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct GeoPoint : Codable{
    var id: String
    var lat: Double
    var lon: Double
    var batteryState: String
    var altitude: Int
    var timestamp: Date
}

struct GeoQueryArguments : Codable {
    var QueryStart: Date?
    var QueryEnd: Date?
}

@available(iOS 17.0, *)
struct FullMapView: View {
    @State private var startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
    @State private var endDate = Date()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @State private var poi: [MKMapItem] = []
    @State private var position: MapCameraPosition = .automatic
    
    func getpoints () {
        self.poi = []
        Task {
            await reload()
        }
    }
    
    func lasthour() {
        startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        endDate = Date()
    }
    
    func reload() async {
        let now = Date()
        
        // Get the current timezone and UTC timezone
        let currentTimeZone = TimeZone.current
        
        print(currentTimeZone.description)
        // Adjust the current date by the difference to get the date in UTC
        let startDateInUTC = Calendar.current.date(byAdding: .hour, value: -0, to: startDate)!
        let endDateInUTC = Calendar.current.date(byAdding: .hour, value: -0, to: endDate)!
        
        print("Start in UTC: \(startDateInUTC)")
        print("end in UTC: \(endDateInUTC)")
        
        do {
            //let url = URL(string: "https://now.clarkezone.dev/geoquery")!
            let url = URL(string: "https://geoquery.tail967d8.ts.net/geoquery")!
            
            var args = GeoQueryArguments()

            args.QueryStart = startDateInUTC
            args.QueryEnd = endDateInUTC
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let stuff = try encoder.encode(args)
            print(String(data: stuff, encoding: .utf8)!)
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = stuff
            
            let (respdata, _) = try await URLSession.shared.data(for: request)
            //        print (response)
            //print(String(data: respdata, encoding: .utf8)!)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let answer = try decoder.decode([GeoPoint].self, from: respdata)
            print(answer.count)
            
            var path: [CLLocationCoordinate2D] = []
            for thing in answer {
                path.append(CLLocationCoordinate2D(latitude: thing.lat, longitude: thing.lon))
            }
            
            var poly = MapPolyline(coordinates: path, contourStyle: .geodesic)
            
            await MainActor.run {
                print("async")
                if (answer.count>0) {
                    var mostrecent = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: answer[answer.count-1].lat, longitude: answer[answer.count-1].lon)))
                    mostrecent.name="Most recent"
                    self.poi.append(mostrecent)
                    self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: answer[answer.count-1].lat, longitude: answer[answer.count-1].lon), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
            
                }
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    var body: some View {
                Map(position: $position) {
                    ForEach (poi, id: \.self) { result in
                                                    Marker(item: result)
                    }
                }
                    .mapStyle(.standard(elevation:.realistic))
                    .safeAreaInset(edge: .bottom){
                        HStack {
                            Spacer()
                            VStack {
                                DatePicker("Start", selection: $startDate)
                                DatePicker("End", selection: $endDate)
                            }
                            HStack {
                                Button(action: getpoints) {
                                    Text("Get")
                                }.buttonStyle(.borderedProminent)
                                Button(action: lasthour) {
                                    Text("Last hour")
                                }.buttonStyle(.borderedProminent)
                            }.padding(.top)
                            Spacer()
                        }.background(.thinMaterial)
                    }.onChange(of: poi){position = .automatic}
            }
}
