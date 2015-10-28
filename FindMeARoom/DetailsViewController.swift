import UIKit

private let timeSpans = [15, 30, 60]

class DetailsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var pickLengthCell: UITableViewCell!
    @IBOutlet var desiredLengthLabel: UILabel!
    @IBOutlet var reserveButtonCell: UITableViewCell!

    @IBOutlet var someHighlightedLabel: UILabel!
    @IBOutlet var someRegularLabel: UILabel!

    @IBOutlet var pickerView: UIPickerView!

    var showPicker: Bool = false {
        didSet {
            if showPicker && !oldValue {
                desiredLengthLabel.textColor = someHighlightedLabel.textColor
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
            self.navigationItem.title = room?.name
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let selectedRow = 1
        pickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        pickerView(pickerView, didSelectRow: selectedRow, inComponent: 0)
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
        if tableView.cellForRowAtIndexPath(indexPath) == pickLengthCell {
            showPicker = !showPicker
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}