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

struct myover : View {
    @Binding var foo: String
    var body: some View {
     Text("\(foo)")   
    }
}

struct NowSitrep: Codable {
    let city, neighborhood, metroArea, phoneStatus: String
    let postal, country, wifi: String
    let batterylevel: Double
    let timeStamp: Date
}

struct nowdetails : View {
    @Binding var level: CGFloat
    @Binding var city: String
    @Binding var postal: String
    @Binding var neighborhood: String
    @Binding var metroarea: String
    @Binding var phoneStatus: String
    @Binding var wifi: String
    @Binding var latestTimestamp: Date
    var body: some View {
        Text("\(city)")
        Text("\(postal)")
        Text("\(neighborhood)")
        Text("\(metroarea)")
        
        Text("\(latestTimestamp)").multilineTextAlignment(.center)
        BatteryView(batteryLevel: $level).frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 40)
        Text("\(phoneStatus)")
        Text("\(wifi)")
    }
}

@available(iOS 17.0, *)
struct FullMapView: View {
    @State private var startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
    @State private var endDate = Date()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @State private var poi: [MKMapItem] = []
    @State private var position: MapCameraPosition = .automatic
    @State private var currentPath: [CLLocationCoordinate2D] = []
    @State private var showingPopover = false 
    @State private var popoverText: String = ""
    @State private var batteryLevel: CGFloat = 1.0
    @State private var city: String = ""
    @State private var neighborhood: String = ""
    @State private var metroArea: String = ""
    @State private var phoneStatus: String = ""
    @State private var postal: String = ""
    @State private var wifi: String = ""
    @State private var latestTimestamp: Date = Date.distantPast

    func lasthour() {
        startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        endDate = Date()
    }
    
    func getNowDetails () {
        self.poi = []
        self.currentPath = []
        Task {
            await getCurrentDetails()
        }
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
            
                batteryLevel = CGFloat(floatLiteral: nowcoords.batterylevel)
                city = nowcoords.city
                neighborhood = nowcoords.neighborhood
                postal = nowcoords.postal
                phoneStatus = nowcoords.country
                wifi = nowcoords.wifi
                latestTimestamp = nowcoords.timeStamp
                
                showingPopover = true
            }
        } catch {
            print("Error")
            popoverText = "\(error)"
            showingPopover = true
        }
    }
    
    func getpoints () {
        self.poi = []
        Task {
            await reload()
        }
    }
    
    func reload() async {
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
            let pa = path // read only to pass back
            
            await MainActor.run {
                print("async")
                if (answer.count>0) {
                    var mostrecent = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: answer[answer.count-1].lat, longitude: answer[answer.count-1].lon)))
                    mostrecent.name="Most recent"
                    self.poi.append(mostrecent)
                    self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: answer[answer.count-1].lat, longitude: answer[answer.count-1].lon), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                    self.currentPath = pa
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
                   
                    if self.currentPath.count>0 {
                        MapPolyline(coordinates: self.currentPath, contourStyle: .geodesic).stroke(.blue, lineWidth: 2)
                    }
                    
                }
                    .mapStyle(.standard(elevation:.realistic))
                    .safeAreaInset(edge: .bottom){
                        HStack {
                            Spacer()
                            VStack {
                                DatePicker("", selection: $startDate)
                                DatePicker("", selection: $endDate)
                                Button(action: getNowDetails) {
                                    Text("Now")
                                }.buttonStyle(.borderedProminent)
                                  .popover(isPresented: $showingPopover) {
                                      VStack {
                                          myover(foo: $popoverText)
                                          nowdetails(
                                            level: $batteryLevel,
                                            city: $city,
                                            postal: $postal,
                                            neighborhood: $neighborhood,
                                            metroarea: $metroArea,
                                            phoneStatus: $phoneStatus,
                                            wifi: $wifi,
                                            latestTimestamp: $latestTimestamp
                                          )
                                      }.frame(minWidth: 300, maxHeight: 400)
                                          .presentationCompactAdaptation(.popover)
                                  }
                                    
                            }
                            HStack {
                                Button(action: getpoints) {
                                    Text("Get")
                                }.buttonStyle(.borderedProminent)
                                Button(action: lasthour) {
                                    Text("Last hour")
                                }.buttonStyle(.borderedProminent)
                            }.padding(10)
                            Spacer()
                        }.background(.thinMaterial)
                    }.onChange(of: poi){position = .automatic}
            }
}
