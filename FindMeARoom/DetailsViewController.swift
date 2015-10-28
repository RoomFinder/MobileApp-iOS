import UIKit

private let timeSpans = [15, 30, 60]

class DetailsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var pickLengthCell: UITableViewCell!
    @IBOutlet var desiredLengthLabel: UILabel!
    @IBOutlet var reserveButtonCell: UITableViewCell!

    @IBOutlet var reserveButtonLabel: UILabel!
    @IBOutlet var someRegularLabel: UILabel!

    @IBOutlet var pickerView: UIPickerView!

    var showPicker: Bool = false {
        didSet {
            if showPicker && !oldValue {
                desiredLengthLabel.textColor = reserveButtonLabel.textColor
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            else if !showPicker && oldValue {
                desiredLengthLabel.textColor = someRegularLabel.textColor
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }

    var room: Room? {
        didSet {
            // refresh title
            tableView.reloadData()
        }
    }

    private var reservationInProgress: Bool = false {
        didSet {
            if reservationInProgress {
                reserveButtonCell.selectionStyle = .None
                reserveButtonLabel.enabled = false
            }
            else {
                reserveButtonCell.selectionStyle = .Default
                reserveButtonLabel.enabled = true
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let selectedRow = 1
        pickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        pickerView(pickerView, didSelectRow: selectedRow, inComponent: 0)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0, let room = room {
            return room.name
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeSpans.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if 0..<timeSpans.count ~= row {
            return "\(timeSpans[row]) min"
        }
        else {
            return nil
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        desiredLengthLabel.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section) + (showPicker ? 0 : -1)
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == pickLengthCell {
            showPicker = !showPicker
        }
        else if cell == reserveButtonCell && !reservationInProgress, let room = room {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Reserve", style: .Destructive) { _ in
                self.reserveRoom(room)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            self.presentViewController(alert, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func reserveRoom(room: Room) {
        reservationInProgress = true
        tableView.reloadData()
        SmartService.sharedService.reserveRoom(id: room.id, duration: timeSpans[self.pickerView.selectedRowInComponent(0)]) {
            switch($0) {
            case .Success:
                dispatch_async(dispatch_get_main_queue()) {
                    self.showMessage("Reservation confirmed for \(room.name)", withTitle: "Success", popViewControllerWhenDone: true)
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    self.showMessage("Unable to reserve: \(info != nil ? info! : "")", withTitle: "Error", popViewControllerWhenDone: true)
                }
            }
        }
    }

    func showMessage(message: String, withTitle title: String, popViewControllerWhenDone: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
            if popViewControllerWhenDone {
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
        presentViewController(alert, animated: true, completion: nil)
    }
}