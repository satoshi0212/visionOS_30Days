import SwiftUI

struct ContentView: View {

    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false

    var body: some View {
        NavigationStack {
            VStack {
                Toggle(isOn: $isRecording) {
                    Text(isRecording ? "Stop Recognition" : "Start Recognition")
                }
                .toggleStyle(.button)
            }
        }
        .onChange(of: isRecording) { _, newValue in
            Task {
                if newValue {
                    startRecognition()
                } else {
                    endRecognition()
                }
            }
        }
    }

    private func startRecognition() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }

    private func endRecognition() {
        speechRecognizer.stopTranscribing()
        isRecording = false
        print(speechRecognizer.transcript)
    }
}

#Preview {
    ContentView()
}
