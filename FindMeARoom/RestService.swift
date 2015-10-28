import Foundation

enum RestResults<T> {
    case Success(data: T)
    case NetworkError
    case ServerError(info: String?)
    case Unauthorized
}

private func getUrl(var relativeUrl: String) -> NSURL {
    if relativeUrl.characters.first != "/" {
        relativeUrl = "/" + relativeUrl
    }
    return NSURL(string: "http://192.168.3.1:18799/api\(relativeUrl)")!
}

class RestService {
    func login(username: String, password: String, email: String, site: String, serviceUrl: String?, callback: RestResults<String> -> Void) {
        // TODO: is there a simpler way?
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
        NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data) {
            if let error = $2 {
                print("Error: \(error)")
                callback(.NetworkError)
                return
            }
            guard let data = $0, let response = $1 as? NSHTTPURLResponse else {
                print("Empty response")
                callback(.NetworkError)
                return
            }
            if response.statusCode == 401 {
                print("Status code: \(response.statusCode)")
                callback(.Unauthorized)
                return
            }
            if response.statusCode != 200 {
                print("Status code: \(response.statusCode)")
                callback(.ServerError(info: NSString(data: data, encoding: NSASCIIStringEncoding) as String?))
                return
            }
            let obj = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? NSString
            guard let ticket = obj else {
                print("Response is not a string")
                callback(.NetworkError)
                return
            }
            print("Login successful!")
            callback(.Success(data: ticket as String))
        }.resume()
    }

    func getRooms(lat lat: Double?, lon: Double?, ticket: String, callback: RestResults<[Room]> -> Void) {
        // TODO: is there a simpler way?
        var url = "rooms?ticket=\(ticket)"
        if let lat = lat, let lon = lon {
            url += "&lat=\(lat)&lon=\(lon)"
        }
        NSURLSession.sharedSession().dataTaskWithURL(getUrl(url)) {
            if let error = $2 {
                print("Error: \(error)")
                callback(.NetworkError)
                return
            }
            guard let data = $0, let response = $1 as? NSHTTPURLResponse else {
                print("Empty response")
                callback(.NetworkError)
                return
            }
            if response.statusCode == 401 {
                print("Status code: \(response.statusCode)")
                callback(.Unauthorized)
                return
            }
            if response.statusCode != 200 {
                print("Status code: \(response.statusCode)")
                callback(.ServerError(info: NSString(data: data, encoding: NSASCIIStringEncoding) as String?))
                return
            }
            let obj = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? NSArray
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
        }.resume()
    }

    func reserveRoom(id id: String, duration: Int, ticket: String, callback: RestResults<Bool> -> Void) {
        // TODO: is there a simpler way?
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
        NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data) {
            if let error = $2 {
                print("Error: \(error)")
                callback(.NetworkError)
                return
            }
            guard let data = $0, let response = $1 as? NSHTTPURLResponse else {
                print("Empty response")
                callback(.NetworkError)
                return
            }
            if response.statusCode == 401 {
                print("Status code: \(response.statusCode)")
                callback(.Unauthorized)
                return
            }
            if response.statusCode == 409 {
                print("Status code: \(response.statusCode)")
                callback(.Success(data: false))
                return
            }
            if response.statusCode != 200 {
                print("Status code: \(response.statusCode)")
                callback(.ServerError(info: NSString(data: data, encoding: NSASCIIStringEncoding) as String?))
                return
            }
            callback(.Success(data: true))
        }.resume()
    }

}