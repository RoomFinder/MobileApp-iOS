import UIKit

private let roomCell = "roomCell"
private let loadingCell = "loadingCell"

class RoomListViewController: UITableViewController {

    var rooms: [Room]? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }

    func refreshList() {
        rooms = nil
        SmartService.sharedService.getRooms {
            switch($0)
            {
            case .Success(let rooms):
                dispatch_async(dispatch_get_main_queue()) {
                    self.rooms = rooms
                }
            case .SomeError(let info):
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: "Authentication error" + (info != nil ? ": \(info!)" : ""), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .Default) { _ in
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.refreshList()
                        })
                    alert.addAction(UIAlertAction(title: "Offline mode", style: .Cancel) { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms?.count ?? 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let rooms = rooms {
            let cell = tableView.dequeueReusableCellWithIdentifier(roomCell)!
            cell.textLabel!.text = rooms[indexPath.row].name;
            cell.detailTextLabel!.text = rooms[indexPath.row].availableFrom;
            return cell
        }
        else {
            return tableView.dequeueReusableCellWithIdentifier(loadingCell)!
        }
    }
}