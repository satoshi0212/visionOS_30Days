import SwiftUI
import RealityKit

struct ContentView: View {

    let appState: AppState

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {

            if !appState.immersiveSpaceOpened {

                let openSpace = {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        break
                    case .error:
                        print("An error occurred when trying to open the immersive space \("ImmersiveSpace")")
                    case .userCancelled:
                        print("The user declined opening immersive space \("ImmersiveSpace")")
                    @unknown default:
                        break
                    }
                }

                Button("Enter: mixed") {
                    Task {
                        appState.currentStyle = .mixed
                        await openSpace()
                    }
                }

                Button("Enter: progressive") {
                    Task {
                        appState.currentStyle = .progressive
                        await openSpace()
                    }
                }

                Button("Enter: full") {
                    Task {
                        appState.currentStyle = .full
                        await openSpace()
                    }
                }

            } else {
                VStack {
                    Spacer()

                    Button {
                        Task {
                            await dismissImmersiveSpace()
                            appState.didLeaveImmersiveSpace()
                        }
                    } label: {
                        Label("Leave", systemImage: "xmark.circle")
                            .frame(minWidth: 200)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .onChange(of: scenePhase, initial: true) {
            print("Scene phase: \(scenePhase)")
            if scenePhase == .active {
                // do nothing
            } else {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
        .onChange(of: appState.providersStoppedWithError, { _, providersStoppedWithError in
            if providersStoppedWithError {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
                appState.providersStoppedWithError = false
            }
        })
        .task {
            await appState.monitorSessionEvents()
        }
    }
}
