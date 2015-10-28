import Foundation

enum RestLoginResults {
    case Success(ticket: String)
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
    func login(username: String, password: String, email: String, site: String, serviceUrl: String?, callback: RestLoginResults -> Void) {
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
            callback(.Success(ticket: ticket as String))
        }.resume()
    }
}