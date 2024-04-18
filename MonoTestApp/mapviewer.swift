import SwiftUI
import MapKit
import Foundation
import SwiftData

struct MapView: View {
    //    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Binding public var currentRegion: MKCoordinateRegion
    
    var body: some View{
        Map(coordinateRegion: $currentRegion).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct PointEditorView: View {
    @State var sliderPosition: ClosedRange<Float>
    var bufferCount: Int
    
    init(pr: Int) {
        if pr > 0 {
            bufferCount = pr
        } else {
            bufferCount = 2
        }
        sliderPosition = 1...Float(bufferCount)
    }
    
    var body: some View {
        Text("PointEditorView \(bufferCount)")
        #if os(iOS)
        //RangedSliderView(value: $sliderPosition, bounds: 1...bufferCount).padding(42)
        #endif
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

@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    public let manager: CLLocationManager

    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}

@available(iOS 17.0, *)
struct FullMapView: View {
    @ObservedObject var locationsHandler = LocationsHandler.shared
    @State private var startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
    @State private var endDate = Date()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @State private var poi: [MKMapItem] = []
    
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
    
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?

    @Environment(\.modelContext) private var modelContext
    
    //extract
    @State private var showingEditPopover = false 
    @State var sliderPosition: ClosedRange<Float> = 3...8
    
    func lasthour() {
        startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        endDate = Date()
    }
    
    func getNowDetails () {
        self.poi = []
        self.currentPath = []
        
        let shared: MonoCoreShared = MonoCoreShared()
        
        Task {
            do {
                let nowcoords = try await shared.getCurrentDetails()
                await MainActor.run {
                    
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
    }
    
    
    func getpoints () {
        self.poi = []
        Task {
            await reload()
        }
    }
    
    func editPoints(){
        showingEditPopover = true   
    }
    
    func reload() async {
        let request = FetchDescriptor<AppSettings>()
        var data = try? modelContext.fetch(request)
        var da = data!
        var settings: AppSettings?
        if da.count > 0 {
            settings = data?.first
            print("we have \(da.count) data with value [\(settings?.queryendpointurl)]")
        } else {
            //TODO no message
            return
        }
        
        // Get the current timezone and UTC timezone
        let currentTimeZone = TimeZone.current
        
        print(currentTimeZone.description)
        // Adjust the current date by the difference to get the date in UTC
        let startDateInUTC = Calendar.current.date(byAdding: .hour, value: -0, to: startDate)!
        let endDateInUTC = Calendar.current.date(byAdding: .hour, value: -0, to: endDate)!
        
        print("Start in UTC: \(startDateInUTC)")
        print("end in UTC: \(endDateInUTC)")
        
        do {
            var urlstringsettings = settings?.queryendpointurl
            //let url = URL(string: "https://now.clarkezone.dev/geoquery")!
            //let url = URL(string: "https://geoquery.tail967d8.ts.net/geoquery")!
            //let url = URL(string: "http://clarkezonedevbox5-tr:5166/geoquery")!
            let url = URL(string: urlstringsettings!)
            
            var args = GeoQueryArguments()
            
            args.QueryStart = startDateInUTC
            args.QueryEnd = endDateInUTC
            
            var request = URLRequest(url: url!)
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
            
          // because apple
        //https://forums.developer.apple.com/forums/thread/114119
            
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
            
            ForEach(searchResults, id: \.self) {result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
            
            if self.currentPath.count>0 {
                MapPolyline(coordinates: self.currentPath, contourStyle: .geodesic).stroke(.blue, lineWidth: 2)
            }
            UserAnnotation ()
            
        }
        .mapControls{
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onChange(of: searchResults) {
            withAnimation{
                position = .automatic
           }
        }.onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapStyle(.standard(elevation:.realistic))
        .safeAreaInset(edge: .bottom){
            HStack {
                Spacer()
                VStack {
                    MapButtons(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
                        .padding(.top)
                    #if os(iOS)
                    DatePicker("", selection: $startDate)
                    DatePicker("", selection: $endDate)
                    #endif
                    Button(action: getNowDetails) {
                        Text("Now")
                    }
#if os(iOS)
                    .buttonStyle(.borderedProminent)

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
                    #endif
                    Button(action: editPoints) {
                        Text("Edit")
                    }
                    #if os(iOS)
                    .buttonStyle(.borderedProminent)
                        .popover(isPresented: $showingEditPopover) {
                            PointEditorView(pr: currentPath.count).frame(minWidth: 300, maxHeight: 400)
                                .presentationCompactAdaptation(.popover)
                        }
                    #endif
                    
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
