import MultipeerConnectivity
import Observation

@Observable
class PeerToPeerModel: NSObject {

    // note: If you change this value, also change the value of "Bonjour services" in info.plist.
    private let serviceType = "my-p2p-service"

    // note: To avoid generating ghost PeerID, once created PeerID is retained and reused.
    // ref: https://stackoverflow.com/questions/26594740/multipeerconnectivity-mcnearbyservicebrowser-constantly-finding-disconnected-p
    private var peerID: MCPeerID = {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "peer") != nil {
            let data = defaults.data(forKey: "peer")!
            return try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)!
        } else {
            let _peerID = MCPeerID(displayName: UIDevice.current.name)
            let data = try! NSKeyedArchiver.archivedData(withRootObject: _peerID, requiringSecureCoding: false)
            defaults.set(data, forKey: "peer")
            return _peerID
        }
    }()

    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    private var session: MCSession?
    private var invitationHandler: ((Bool, MCSession?) -> Void)?

    var foundPeers: [MCPeerID] = []
    var receivedInvite: Bool = false
    var receivedInviteFrom: MCPeerID? = nil
    var paired: Bool = false

    var isStarted: Bool {
        get {
            return self.session != nil
        }
    }

    func start() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)

        session?.delegate = self
        serviceAdvertiser?.delegate = self
        serviceBrowser?.delegate = self

        serviceAdvertiser?.startAdvertisingPeer()
        serviceBrowser?.startBrowsingForPeers()
    }

    func stop() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        session?.disconnect()

        serviceAdvertiser = nil
        serviceBrowser = nil
        session = nil

        foundPeers.removeAll()
        paired = false
    }

    func invite(peerID: MCPeerID) {
        guard let serviceBrowser, let session else { return }
        serviceBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func disconnect(peerID: MCPeerID) {
        session?.cancelConnectPeer(peerID)
    }

    func handleInvitation(_ result: Bool) {
        guard let invitationHandler else { return }
        let _session = result ? session : nil
        invitationHandler(result, _session)
    }
}

extension PeerToPeerModel: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")

        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension PeerToPeerModel: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("ServiceBrowser found peer: \(peerID)")
        
        DispatchQueue.main.async {
            if !self.foundPeers.contains(peerID) {
                self.foundPeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("ServiceBrowser lost peer: \(peerID)")

        DispatchQueue.main.async {
            self.foundPeers.removeAll(where: {
                $0 == peerID
            })
        }
    }
}

extension PeerToPeerModel: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChange: \(state.rawValue)")

        switch state {
        case MCSessionState.notConnected:
            DispatchQueue.main.async {
                self.paired = false
            }
            //serviceAdvertiser?.startAdvertisingPeer()
            break
        case MCSessionState.connected:
            DispatchQueue.main.async {
                self.paired = true
            }
            //serviceAdvertiser?.stopAdvertisingPeer()
            break
        default:
            DispatchQueue.main.async {
                self.paired = false
            }
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(#function)
        print(data)
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print(#function)
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(#function)
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(#function)
    }
}
