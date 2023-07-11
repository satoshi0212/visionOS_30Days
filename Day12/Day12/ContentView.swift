import SwiftUI
import MapKit

struct ContentView: View {

    @ObservedObject var locationsHandler = LocationsHandler.shared
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        VStack {
            Spacer()
            Text("Location: \(self.locationsHandler.lastLocation)")
                .padding(10)
            Text("Count: \(self.locationsHandler.count)")
            Spacer()

            Map(position: $position)
                .mapStyle(.hybrid(elevation: .realistic))
                .onChange(of: self.locationsHandler.cameraPosition) {
                    position = self.locationsHandler.cameraPosition
                }
                .padding(40)

            Spacer()
            Button(self.locationsHandler.updatesStarted ? "Stop Location Updates" : "Start Location Updates") {
                self.locationsHandler.updatesStarted ? self.locationsHandler.stopLocationUpdates() : self.locationsHandler.startLocationUpdates()
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
