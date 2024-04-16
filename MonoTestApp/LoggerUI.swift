//
//  LoggerUI.swift
//  MonoTestApp
//
//  Created by James Clarke on 4/16/24.
//

import SwiftUI

struct TrackerView: View {
    @State private var sendInterval: Double = 1
    @State private var walkDuration: Double = 0
    @State private var walkDistance: Double = 0
    @State private var isTracking: Bool = false

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("AGE")
                        .font(.caption)
                    Text("0:03")
                        .font(.title)
                    Text("minutes ago")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("LOCATION")
                        .font(.caption)
                    Text("47.6746\n-122.1015")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text("+/-5m 13m")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("MPH")
                        .font(.caption)
                    Text("0")
                        .font(.title)
                }
            }
            .padding()

            Button(action: {}) {
                Text("Send Now")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()

            HStack {
                Text("1m")
                Slider(value: $sendInterval, in: 1...60)
                Text("60m")
            }
            .padding()

            HStack {
                Image(systemName: "figure.walk")
                VStack(alignment: .leading) {
                    Text("DURATION")
                        .font(.caption)
                    Slider(value: $walkDuration, in: 0...120)
                }
                VStack(alignment: .leading) {
                    Text("DISTANCE")
                        .font(.caption)
                    Slider(value: $walkDistance, in: 0...10)
                }
                Button(action: {
                                   // Toggle the tracking state
                                   self.isTracking.toggle()
                               }) {
                                   Text(isTracking ? "Stop" : "Start") // Toggle text based on tracking state
                                       .foregroundColor(.white)
                                       .frame(maxWidth: .infinity)
                                       .padding()
                                       .background(isTracking ? Color.red : Color.green) // Toggle color based on tracking state
                                       .cornerRadius(10)
                               }
            }
            .padding()

            Spacer()

            HStack {
                Spacer()
                Image(systemName: "location")
                Spacer()
                Image(systemName: "gear")
                Spacer()
            }
            .padding()
        }
    }
}

struct TrackerView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerView()
    }
}
