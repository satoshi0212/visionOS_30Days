import SwiftUI

struct ContentView: View {

    let appState: AppState
    let immersiveSpaceIdentifier: String

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            if !appState.immersiveSpaceOpened {
                Button("Enter") {
                    Task {
                        switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                        case .opened:
                            break
                        case .error:
                            print("An error occurred when trying to open the immersive space \(immersiveSpaceIdentifier)")
                        case .userCancelled:
                            print("The user declined opening immersive space \(immersiveSpaceIdentifier)")
                        @unknown default:
                            break
                        }
                    }
                }
                .disabled(!appState.canEnterImmersiveSpace)
            } else {
                VStack {
                    Spacer()

                    Button {
                        Task {
                            await appState.viewModel?.setupCubes()
                        }
                    } label: {
                        Label("Set Cubes", systemImage: "plus.circle")
                            .frame(minWidth: 200)
                    }

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
        .fixedSize()
        .onChange(of: scenePhase, initial: true) {
            print("Scene phase: \(scenePhase)")
            if scenePhase == .active {
                Task {
                    await appState.queryWorldSensingAuthorization()
                }
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
            if appState.allRequiredProvidersAreSupported {
                await appState.requestWorldSensingAuthorization()
            }
        }
        .task {
            await appState.monitorSessionEvents()
        }
    }
}
