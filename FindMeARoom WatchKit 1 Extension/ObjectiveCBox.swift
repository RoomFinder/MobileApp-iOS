import Foundation

/// Should be used to "box" a swift object to an Objective-C compatible container
class ObjectiveCBox<T>: NSObject {
    let value: T
    init(value: T) {
        self.value = value
    }
}