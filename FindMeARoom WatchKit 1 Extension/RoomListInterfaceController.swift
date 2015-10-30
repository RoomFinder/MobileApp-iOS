import WatchKit

private let roomRowType = "roomRow"
private let showRoomDetailsSegue = "showRoomDetails"

class RoomListInterfaceController: WKInterfaceController {
    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!

    private var rooms: [Room]!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let location = context as! CLLocation
        errorLabel.setText("Loading...\nPlease be patient, it will take some time.")
        SmartService.sharedService.getRooms(lat: location.coordinate.latitude, lon: location.coordinate.longitude) {
            switch($0) {
            case .Success(let rooms):
                dispatch_async(dispatch_get_main_queue()) {
                    self.rooms = rooms
                    self.errorLabel.setHidden(true)
                    self.table.setNumberOfRows(rooms.count, withRowType: roomRowType)
                    for (i, room) in rooms.enumerate() {
                        if let r = self.table.rowControllerAtIndex(i) as? RoomRowController {
                            r.roomNameLabel.setText(room.name)
                            r.roomInfoLabel.setText("\(room.building) \(room.floor)")
                        }
                    }
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorLabel.setText(info ?? "Error")
                }
            }
        }
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == showRoomDetailsSegue {
            let room = rooms[rowIndex]
            return ObjectiveCBox(value: room)
        }
        else {
            return super.contextForSegueWithIdentifier(segueIdentifier, inTable: table, rowIndex: rowIndex)
        }
    }
}