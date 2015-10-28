import UIKit

private let UsernamePreference = "username_preference"
private let PasswordPreference = "password_preference"
private let EmailPreference = "email_preference"
private let SitePreference = "site_preference"
private let UrlPreference = "url_preference"


enum LoginResults {
    case Success
    case SomeError(info: String?)
    case InvalidSettings
}

/// Wrapper around MainService, aware of UIKit and ticket expiration
class SmartService {
    static let sharedService = SmartService()
    private var ticket: String?

    private init() {
    }

    var isTicketValid: Bool {
        // TODO: handle expired tickets
        return ticket != nil
    }

    func login(callback: LoginResults -> Void) {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard
            let username = defaults.stringForKey(UsernamePreference),
            let password = defaults.stringForKey(PasswordPreference),
            let site = defaults.stringForKey(SitePreference),
            let email = defaults.stringForKey(EmailPreference) else {
                callback(.InvalidSettings)
                return
        }
        let service = RestService()
        service.login(username, password: password, email: email, site: site, serviceUrl: defaults.stringForKey(UrlPreference)) {
            switch($0) {
            case .Success(let ticket):
                self.ticket = ticket
                callback(.Success)
            case .NetworkError:
                callback(.SomeError(info: nil))
            case .ServerError(let info):
                callback(.SomeError(info: info))
            case .Unauthorized:
                callback(.InvalidSettings)
            }
        }
    }
}