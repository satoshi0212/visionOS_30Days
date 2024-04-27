import SwiftUI

struct ContentView: View {

    @State private var effectEnabled = false
    @State private var strength: Float = 0

    var body: some View {
        DigitalRain()
            .gesture(
                SpatialTapGesture()
                    .onEnded { event in
                        effectEnabled.toggle()
                        strength = effectEnabled ? 10 : 0
                    }
            )
            .layerEffect(ShaderLibrary.pixellate(.float(strength)), maxSampleOffset: .zero)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
