import WatchKit

class RoomDetailsInterfaceController: WKInterfaceController {
    @IBOutlet var roomNameLabel: WKInterfaceLabel!
    @IBOutlet var availableForLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        let room = (context as! ObjectiveCBox<Room>).value
        roomNameLabel.setText(room.name)
        locationLabel.setText("\(room.building) \(room.floor)")
        let availableFor: String
        if room.availableFor > 8*60 {
            availableFor = "the whole day"
        }
        else if room.availableFor > 120 {
            availableFor = "\(room.availableFor/60) hours"
        }
        else {
            availableFor = "\(room.availableFor) min"
        }
        availableForLabel.setText(availableFor)
    }

    @IBAction func reserveTap() {
    }
}