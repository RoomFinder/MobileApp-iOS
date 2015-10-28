import Foundation

final class Converter {
    private static let rfc3339formatter = Converter.prepareFormatter()
    private static func prepareFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }

    static func readRoom(obj: AnyObject?) throws -> Room {
        guard
            let dict = obj as? NSDictionary,
            let id = dict.valueForKey("id") as? String,
            let name = dict.valueForKey("name") as? String,
            let availableFrom = dict.valueForKey("availableFrom") as? String,
            let availableFromDate = Converter.rfc3339formatter.dateFromString(availableFrom),
            let availableFor = dict.valueForKey("availableForMinutes") as? Int,
            let building = dict.valueForKey("building") as? String,
            let floor = dict.valueForKey("floor") as? String else {
                // TODO: better error
                throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return Room(id: id, name: name, availableFrom: availableFromDate, availableFor: availableFor, building: building, floor: floor)
    }
}