import SwiftUI
import MultipeerConnectivity

struct ContentView: View {

    @Environment(PeerToPeerModel.self) var peerToPeerModel
    @State private var selectedPeer: MCPeerID?

    var body: some View {

        @Bindable var peerToPeerModel = peerToPeerModel

        NavigationSplitView {
            List(peerToPeerModel.foundPeers, id: \.self, selection: $selectedPeer) { peer in
                Text(peer.displayName)
            }
            .alert("Received an invite from \(peerToPeerModel.receivedInviteFrom?.displayName ?? "-")", isPresented: $peerToPeerModel.receivedInvite) {
                Button("Accept invite") {
                    peerToPeerModel.handleInvitation(true)
                }
                Button("Reject invite") {
                    peerToPeerModel.handleInvitation(false)
                }
            }
            .navigationTitle("Peers")
            .toolbar {
                if peerToPeerModel.isStarted {
                    Button("Stop") {
                        peerToPeerModel.stop()
                        selectedPeer = nil
                    }
                } else {
                    Button("Start") {
                        peerToPeerModel.start()
                    }
                }
            }
        } detail: {
            VStack {
                if let selectedPeer {
                    VStack {
                        Spacer()

                        Text(peerToPeerModel.paired ? "Connected" : "Not Connected")
                            .font(.title)

                        Spacer()

                        Text(selectedPeer.displayName)

                        Spacer()

                        if peerToPeerModel.paired {
                            Button("Disconnect") {
                                peerToPeerModel.disconnect(peerID: selectedPeer)
                            }
                            .buttonStyle(BorderedRoundedButtonStyle(cornerRadius: 8.0))
                        } else {
                            Button("Invite") {
                                peerToPeerModel.invite(peerID: selectedPeer)
                            }
                            .buttonStyle(BorderedRoundedButtonStyle(cornerRadius: 8.0))
                        }

                        Spacer()
                    }
                }
            }
            .navigationTitle("Peer")
        }
    }
}

struct BorderedRoundedButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) var isEnabled: Bool

    var cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(isEnabled ? Color.primary : Color.gray)
            .font(.body.bold())
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(isEnabled ? Color.primary : Color.gray, lineWidth: 2))
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut, value: 0.2)
    }
}
