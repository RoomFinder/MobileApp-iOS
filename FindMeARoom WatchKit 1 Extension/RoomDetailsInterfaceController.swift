import WatchKit

private let reserveRoomSegue = "reserveRoom"

class RoomDetailsInterfaceController: WKInterfaceController {
    @IBOutlet var roomNameLabel: WKInterfaceLabel!
    @IBOutlet var availableForLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!

    private var room: Room!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        room = (context as! ObjectiveCBox<Room>).value
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


    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == reserveRoomSegue {
            return ObjectiveCBox(value: room!)
        }
        else {
            return super.contextForSegueWithIdentifier(segueIdentifier)
        }
    }

}