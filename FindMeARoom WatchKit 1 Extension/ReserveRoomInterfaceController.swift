import WatchKit

private let reservationChoiceRowType = "reservationChoiceRow"
private let cancelRowType = "cancelRow"
private let reservationConfirmedSegue = "reservationConfirmed"
private let timeSpans = [15, 30, 60]

class ReservationChoiceController: NSObject {
    @IBOutlet var label: WKInterfaceLabel!
}

class ReserveRoomInterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!

    private var room: Room!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        room = (context as! ObjectiveCBox<Room>).value
        var rowTypes = timeSpans.map { _ in reservationChoiceRowType }
        rowTypes.append(cancelRowType)
        table.setRowTypes(rowTypes)
        for (i, timeSpan) in timeSpans.enumerate() {
            if let row = table.rowControllerAtIndex(i) as? ReservationChoiceController {
                row.label.setText("\(timeSpan) min")
            }
        }
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if segueIdentifier == reservationConfirmedSegue {
            return ObjectiveCBox(value: (room: room.id, duration: timeSpans[rowIndex]))
        }
        else {
            return super.contextForSegueWithIdentifier(segueIdentifier, inTable: table, rowIndex: rowIndex)
        }
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if 0..<timeSpans.count ~= rowIndex {
            super.table(table, didSelectRowAtIndex: rowIndex)
        }
        else {
            popController()
        }
    }
}