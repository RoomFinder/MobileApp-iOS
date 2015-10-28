import Foundation

private func getUrl(var relativeUrl: String) -> NSURL {
    if relativeUrl.characters.first != "/" {
        relativeUrl = "/" + relativeUrl
    }
    return NSURL(string: "http://192.168.3.1:18799/api\(relativeUrl)")!
}

class RestService {
    func login(username: String, password: String, email: String, site: String, serviceUrl: String?, callback: RestResults<String> -> Void) {
        let request = NSMutableURLRequest(URL: getUrl("login"))
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"

        var tmp: [NSObject: AnyObject] = [
            "username" : username,
            "password" : password,
            "email" : email,
            "site" : site
        ]
        if let serviceUrl = serviceUrl {
            tmp["serviceUrl"] = serviceUrl
        }
        let obj = NSDictionary(dictionary: tmp)
        guard let data = try? NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions(rawValue: 0)) else {
            callback(.NetworkError)
            return
        }
        request.HTTPBody = data
        REST.doRequest(request, callback: callback, errorHandlers: nil) {
            let obj = (try? NSJSONSerialization.JSONObjectWithData($0, options: .AllowFragments)) as? NSString
            guard let ticket = obj else {
                print("Response is not a string")
                callback(.NetworkError)
                return
            }
            print("Login successful!")
            callback(.Success(data: ticket as String))
        }
    }

    func getRooms(lat lat: Double?, lon: Double?, ticket: String, callback: RestResults<[Room]> -> Void) {
        var url = "rooms?ticket=\(ticket)"
        if let lat = lat, let lon = lon {
            url += "&lat=\(lat)&lon=\(lon)"
        }
        let request = NSURLRequest(URL: getUrl(url))
        REST.doRequest(request, callback: callback, errorHandlers: nil) {
            let obj = (try? NSJSONSerialization.JSONObjectWithData($0, options: .AllowFragments)) as? NSArray
            guard let array = obj else {
                print("Response is not an array")
                callback(.NetworkError)
                return
            }
            let r = try? array.map(Converter.readRoom)
            guard let result = r else {
                print("Unable to parse contents of the array")
                callback(.NetworkError)
                return
            }
            callback(.Success(data: result))
        }
    }

    func reserveRoom(id id: String, duration: Int, ticket: String, callback: RestResults<Bool> -> Void) {
        let request = NSMutableURLRequest(URL: getUrl("rooms/\(id)?ticket=\(ticket)"))
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"

        let tmp: [NSObject: AnyObject] = [
            "duration" : duration
        ]
        let obj = NSDictionary(dictionary: tmp)
        guard let data = try? NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions(rawValue: 0)) else {
            callback(.NetworkError)
            return
        }
        request.HTTPBody = data
        let errorMap: [Int : NSData -> Void] = [
            409: { _ in callback(.Success(data: false)) }
        ]
        REST.doRequest(request, callback: callback, errorHandlers: errorMap) { _ in
            callback(.Success(data: true))
        }
    }

}