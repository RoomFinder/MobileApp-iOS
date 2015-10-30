import WatchKit

class ConfirmReservationInterfaceController: WKInterfaceController {
    @IBOutlet var label: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let (roomId, duration) = (context as! ObjectiveCBox<(roomId: String, duration: Int)>).value
        SmartService.sharedService.reserveRoom(id: roomId, duration: duration) {
            switch($0) {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) {
                    self.label.setText("Reservation confirmed.")
                    self.setTitle("OK")
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    self.label.setText("Unable to reserve. \(info ?? "")")
                    self.setTitle("OK")
                }
            }
        }
    }
}