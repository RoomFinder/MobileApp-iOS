import Foundation

enum RestResults<T> {
    case Success(data: T)
    case NetworkError
    case ServerError(info: String?)
    case Unauthorized
}

// TODO: consider using some REST library instead
final class REST {
    static func doRequest<T>(request: NSURLRequest, callback: RestResults<T> -> Void, errorHandlers: [Int : NSData -> Void]?, successHandler: NSData -> Void) {
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
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
            if response.statusCode != 200 {
                print("Status code: \(response.statusCode)")
                if let eh = errorHandlers?[response.statusCode] {
                    eh(data)
                }
                else if response.statusCode == 401 {
                    callback(.Unauthorized)
                }
                else {
                    callback(.ServerError(info: NSString(data: data, encoding: NSASCIIStringEncoding) as String?))
                }
                return
            }
            successHandler(data)
            }.resume()
    }
}