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
                .toggleStyle(RecordToggleStyle())
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

struct RecordToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "waveform.circle.fill" : "waveform.circle")
                configuration.label
            }
        }
    }
}
