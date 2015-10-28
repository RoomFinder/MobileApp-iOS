import UIKit

private let roomCell = "roomCell"
private let loadingCell = "loadingCell"
private let segueBook = "segueBook"

class RoomListViewController: UITableViewController {

    var rooms: [Room]? {
        didSet {
            tableView.reloadData()
        }
    }

    var latitude: Double?
    var longitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }

    var selectedRoom: Room?

    // TODO: simplify this method
    func refreshList() {
        guard rooms == nil else {
            return
        }
        SmartService.sharedService.getRooms(lat: latitude, lon: longitude) {
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

    private lazy var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let rooms = rooms {
            let room = rooms[indexPath.row]
            var facts = ["\(room.building) \(room.floor)"]
            let now = NSDate()
            let components = calendar?.components(NSCalendarUnit.Month, fromDate: now, toDate: room.availableFrom, options: NSCalendarOptions(rawValue: 0))
            if let c = components {
                if c.minute > 100500 || c.minute == 0 {
                    //facts.append("available now")
                }
                else if c.minute > 120 {
                    facts.append("available in \(c.minute/60) hours")
                }
                else {
                    facts.append("available in \(c.minute) minutes")
                }
            }
            if room.availableFor > 8*60 {
                //facts.append("free for the day")
            }
            else if room.availableFor > 2*60 {
                facts.append("free for \(room.availableFor/60) hours")
            }
            else {
                facts.append("free for \(room.availableFor) minutes")
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(roomCell)!
            cell.textLabel!.text = room.name
            cell.detailTextLabel!.text = facts.joinWithSeparator(", ")
            return cell
        }
        else {
            return tableView.dequeueReusableCellWithIdentifier(loadingCell)!
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let rooms = rooms {
            selectedRoom = rooms[indexPath.row]
            performSegueWithIdentifier(segueBook, sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueBook, let vc = segue.destinationViewController as? DetailsViewController {
            vc.room = selectedRoom
        }
    }

}