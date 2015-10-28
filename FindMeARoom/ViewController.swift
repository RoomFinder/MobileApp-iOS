import UIKit
import MapKit

private let segueRooms = "segueRooms"

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var findRoomsButton: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingLabel: UILabel!

    @IBOutlet var refreshButton: UIBarButtonItem!

    private var manager: CLLocationManager!
    private var locationObtained: Bool = false
    private var offlineMode: Bool = false
    private var loggedIn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
        // TODO: CLLocationManager.authorizationStatus() == .Denied
        manager.delegate = self
        obtainLocation()
    }

    var location: CLLocation?

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy < kCLLocationAccuracyHundredMeters {
            manager.stopUpdatingLocation()
            print("Location obtained: \(location)")
            self.location = location
            locationObtained = true
            refreshStatus()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Cannot obtain location: \(error)")
        location = nil
        locationObtained = false
        offlineMode = true
        refreshStatus()
    }

    @IBAction func refreshClick(sender: AnyObject) {
        guard offlineMode else {
            return
        }
        offlineMode = false
        if !loggedIn {
            logIn()
        }
        if !locationObtained {
            obtainLocation()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        logIn()
    }

    func obtainLocation() {
        manager.startUpdatingLocation()
    }

    func logIn() {
        guard !SmartService.sharedService.isTicketValid else {
            return
        }
        self.loggedIn = false
        self.offlineMode = false
        self.refreshStatus()
        SmartService.sharedService.login {
            switch($0) {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) {
                    self.loggedIn = true
                    self.refreshStatus()
                }
            case .InvalidSettings:
                dispatch_async(dispatch_get_main_queue()) {
                    self.offlineMode = true
                    self.refreshStatus()
                    let alert = UIAlertController(title: "Error", message: "Please check your setings", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Settings", style: .Default) { _ in
                        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                        })
                    alert.addAction(UIAlertAction(title: "Offline mode", style: .Cancel) { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    self.offlineMode = true
                    self.refreshStatus()
                    let alert = UIAlertController(title: "Error", message: "Authentication error" + (info != nil ? ": \(info!)" : ""), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .Default) { _ in
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.logIn()
                        })
                    alert.addAction(UIAlertAction(title: "Offline mode", style: .Cancel) { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func refreshStatus() {
        if offlineMode {
            refreshButton.enabled = true
            loadingView.hidden = true
            return
        }
        else {
            refreshButton.enabled = false
        }
        if loggedIn {
            if locationObtained {
                loadingView.hidden = true
                findRoomsButton.enabled = true
            }
            else { // !locationObtained
                loadingLabel.text = "Obtaining location..."
                loadingView.hidden = false
            }
        }
        else { // !loggedIn
            if locationObtained {
                loadingLabel.text = "Authenticating..."
                loadingView.hidden = false
            }
            else { // !locationObtained
                loadingLabel.text = "Loading..."
                loadingView.hidden = false
            }//
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueRooms, let vc = segue.destinationViewController as? RoomListViewController {
            vc.latitude = location?.coordinate.latitude
            vc.longitude = location?.coordinate.longitude
        }
    }
}

