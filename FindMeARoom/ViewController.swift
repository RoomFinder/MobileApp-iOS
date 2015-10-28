import UIKit

class ViewController: UIViewController {

    @IBOutlet var findRoomsButton: UIButton!
    @IBOutlet var loadingView: UIView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        logIn()
    }

    func logIn() {
        guard !SmartService.sharedService.isTicketValid else {
            return
        }
        self.loadingView.hidden = false
        self.findRoomsButton.enabled = false
        SmartService.sharedService.login {
            switch($0) {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) {
                    self.hideMessage()
                    self.findRoomsButton.enabled = true
                }
            case .InvalidSettings:
                dispatch_async(dispatch_get_main_queue()) {
                    self.hideMessage()
                    let alert = UIAlertController(title: "Error", message: "Please check your setings", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Settings", style: .Default) { _ in
                        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                        self.dismissViewControllerAnimated(false, completion: nil)
                        })
                    alert.addAction(UIAlertAction(title: "Offline mode", style: .Cancel) { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    self.hideMessage()
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

    func hideMessage() {
        self.loadingView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

