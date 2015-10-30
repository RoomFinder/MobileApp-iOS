import WatchKit

private let showRoomListSegue = "showRoomList"

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var findButton: WKInterfaceButton!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        manager = CLLocationManager()
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.delegate = self
    }

    private var location: CLLocation?
    private var errorMessage: String?
    private var manager: CLLocationManager!
    private var loggedIn: Bool = false

    override func willActivate() {
        super.willActivate()
        manager.startUpdatingLocation()
        refreshStatus()
        logIn()
    }

    private func logIn() {
        guard !SmartService.sharedService.isTicketValid else {
            return
        }
        self.loggedIn = false
        SmartService.sharedService.login {
            switch($0) {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) {
                    self.loggedIn = true
                    self.refreshStatus()
                }
            case .InvalidSettings:
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorMessage = "Invalid settings"
                    self.refreshStatus()
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorMessage = info
                    self.refreshStatus()
                }
            }
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last
            where location.horizontalAccuracy < kCLLocationAccuracyHundredMeters {
                self.location = location
                refreshStatus()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        errorMessage = "Unable to obtain location information"
        location = nil
        refreshStatus()
    }

    override func didDeactivate() {
        super.didDeactivate()
        manager.stopUpdatingLocation()
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == showRoomListSegue {
            return (location: location)
        }
        else {
            return super.contextForSegueWithIdentifier(segueIdentifier)
        }
    }

    func refreshStatus() {
        if loggedIn && location != nil {
            errorLabel.setHidden(true)
            findButton.setHidden(false)
        }
        else {
            if let message = errorMessage {
                errorLabel.setText("\(message). Please launch iPhone app to learn how to fix it.")
            }
            else {
                let currentAction: String
                if !loggedIn && location == nil {
                    currentAction = "Loading"
                }
                else if !loggedIn {
                    currentAction = "Authenticating"
                }
                else {
                    currentAction = "Obtaining location"
                }
                errorLabel.setText("\(currentAction)...\nPlease wait.")
            }
            errorLabel.setHidden(false)
            findButton.setHidden(true)
        }
    }
}
