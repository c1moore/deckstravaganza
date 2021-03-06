import GameKit

/// Custom delegate used to provide information to the application implementing GCHelper.
public protocol GCHelperDelegate {
    
    /// Method called when a match has been initiated.
    func matchStarted()
    
    /// Method called when the device received data about the match from another device in the match.
    func match(match: GKMatch, didReceiveData: NSData, fromPlayer: String)
    
    /// Method called when the match has ended.
    func matchEnded()
}

/// A GCHelper instance represents a wrapper around a GameKit match.
public class GCHelper: NSObject, GKMatchmakerViewControllerDelegate, GKGameCenterControllerDelegate, GKMatchDelegate, GKLocalPlayerListener {
    
    /// The match object provided by GameKit.
    public var match: GKMatch!
    
    private var delegate: GCHelperDelegate?
    private var invite: GKInvite!
    private var invitedPlayer: GKPlayer!
    private var playersDict = [String:AnyObject]()
    private var presentingViewController: UIViewController!
    
    private var authenticated = false
    private var matchStarted = false
    
    /// The shared instance of GCHelper, allowing you to access the same instance across all uses of the library.
    public class var sharedInstance: GCHelper {
        struct Static {
            static let instance = GCHelper()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticationChanged", name: GKPlayerAuthenticationDidChangeNotificationName, object: nil)
    }
    
    // MARK: Internal functions
    
    internal func authenticationChanged() {
        if GKLocalPlayer.localPlayer().authenticated && !authenticated {
            print("Authentication changed: player authenticated")
            authenticated = true
        } else {
            print("Authentication changed: player not authenticated")
            authenticated = false
        }
    }
    
    private func lookupPlayers() {
        let playerIDs = match.players.map { $0.playerID! }
        
        GKPlayer.loadPlayersForIdentifiers(playerIDs) { (players, error) -> Void in
            if error != nil {
                print("Error retrieving player info: \(error!.localizedDescription)")
                self.matchStarted = false
                self.delegate?.matchEnded()
            } else {
                guard let players = players else {
                    print("Error retrieving players; returned nil")
                    return
                }
                
                for player in players {
                    print("Found player: \(player.alias)")
                    self.playersDict[player.playerID!] = player
                }
                
                self.matchStarted = true
                GKMatchmaker.sharedMatchmaker().finishMatchmakingForMatch(self.match)
                self.delegate?.matchStarted()
            }
        }
    }
    
    // MARK: User functions
    
    /// Authenticates the user with their Game Center account if possible
    public func authenticateLocalUser() {
        print("Authenticating local user...")
        if GKLocalPlayer.localPlayer().authenticated == false {
            GKLocalPlayer.localPlayer().authenticateHandler = { (view, error) in
                if error == nil {
                    self.authenticated = true
                } else {
                    print("\(error?.localizedDescription)")
                }
            }
        } else {
            print("Already authenticated")
        }
    }
    
    /**
    Attempts to pair up the user with other users who are also looking for a match.
    
    :param: minPlayers The minimum number of players required to create a match.
    :param: maxPlayers The maximum number of players allowed to create a match.
    :param: viewController The view controller to present required GameKit view controllers from.
    :param: delegate The delegate receiving data from GCHelper.
    */
    public func findMatchWithMinPlayers(minPlayers: Int, maxPlayers: Int, viewController: UIViewController, delegate theDelegate: GCHelperDelegate) {
        matchStarted = false
        match = nil
        presentingViewController = viewController
        delegate = theDelegate
        presentingViewController.dismissViewControllerAnimated(false, completion: nil)
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let mmvc = GKMatchmakerViewController(matchRequest: request)!
        mmvc.matchmakerDelegate = self
        
        presentingViewController.presentViewController(mmvc, animated: true, completion: nil)
    }
    
       /**
    Presents the game center view controller provided by GameKit.
    
    :param: viewController The view controller to present GameKit's view controller from.
    :param: viewState The state in which to present the new view controller.
    */
    public func showGameCenter(viewController: UIViewController, viewState: GKGameCenterViewControllerState) {
        presentingViewController = viewController
        
        let gcvc = GKGameCenterViewController()
        gcvc.viewState = viewState
        gcvc.gameCenterDelegate = self
        presentingViewController.presentViewController(gcvc, animated: true, completion: nil)
    }
    
    // MARK: GKGameCenterControllerDelegate
    
    public func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: GKMatchmakerViewControllerDelegate
    
    public func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func matchmakerViewController(viewController: GKMatchmakerViewController, didFailWithError error: NSError) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        print("Error finding match: \(error.localizedDescription)")
    }
    
    public func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch theMatch: GKMatch) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        match = theMatch
        match.delegate = self
        if !matchStarted && match.expectedPlayerCount == 0 {
            print("Ready to start match!")
            self.lookupPlayers()
        }
    }
    
    // MARK: GKMatchDelegate
    
    public func match(theMatch: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String) {
        if match != theMatch {
            return
        }
        
        delegate?.match(theMatch, didReceiveData: data, fromPlayer: playerID)
    }
    
    public func match(theMatch: GKMatch, player playerID: String, didChangeState state: GKPlayerConnectionState) {
        if match != theMatch {
            return
        }
        
        switch state {
        case .StateConnected where !matchStarted && theMatch.expectedPlayerCount == 0:
            lookupPlayers()
        case .StateDisconnected:
            matchStarted = false
            delegate?.matchEnded()
            match = nil
        default:
            break
        }
    }
    
    public func match(theMatch: GKMatch, didFailWithError error: NSError?) {
        if match != theMatch {
            return
        }
        
        print("Match failed with error: \(error?.localizedDescription)")
        matchStarted = false
        delegate?.matchEnded()
    }
    
    // MARK: GKLocalPlayerListener
    
    public func player(player: GKPlayer, didAcceptInvite inviteToAccept: GKInvite) {
        let mmvc = GKMatchmakerViewController(invite: inviteToAccept)!
        mmvc.matchmakerDelegate = self
        presentingViewController.presentViewController(mmvc, animated: true, completion: nil)
    }
}