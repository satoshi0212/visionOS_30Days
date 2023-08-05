import SwiftUI
import RealityKit
import MapKit

struct ContentView: View {

    var viewModel: ViewModel

    @State private var position: MapCameraPosition = .automatic

    @State private var showImmersiveSpace = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {

        @Bindable var viewModel = viewModel

        NavigationSplitView {
            List(viewModel.placeInfoList, id: \.self, selection: $viewModel.selectedPlaceInfo) { placeInfo in
                Text(placeInfo.name)
                    .selectionDisabled(showImmersiveSpace)
            }
            .onAppear {
                if viewModel.selectedPlaceInfo == nil {
                    viewModel.selectedPlaceInfo = viewModel.placeInfoList.first
                }
            }
            .onChange(of: viewModel.selectedPlaceInfo, { oldValue, newValue in
                if let placeInfo = newValue {
                    let camera = MapCamera(centerCoordinate: placeInfo.locationCoordinate, distance: 400, heading: 0, pitch: 60)
                    let cameraPosition = MapCameraPosition.camera(camera)
                    self.position = cameraPosition
                }
            })
            .navigationTitle("Places")
        } detail: {
            Text(viewModel.selectedPlaceInfo?.name ?? "Please choose a place.")

            Spacer()

            Map(position: $position, interactionModes: MapInteractionModes.rotate)
                .mapStyle(.imagery(elevation: .realistic))

            Spacer()

            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .toggleStyle(.button)

            Spacer()
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ViewModel())
}
