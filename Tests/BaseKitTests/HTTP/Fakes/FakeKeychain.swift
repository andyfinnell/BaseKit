import Foundation
import TestKit
@testable import BaseKit

final class FakeKeychain: KeychainType {
    let password_fake = SendableMethodCall((service: String, account: String).self, String?.none)
    func password(service: String, account: String) -> String? {
        password_fake.fake((service, account))
    }
    
    let set_fake = SendableMethodCall((password: String, service: String, account: String).self, ())
    func set(password: String, service: String, account: String) {
        set_fake.fake((password, service, account))
    }
    
    let deletePassword_fake = SendableMethodCall((service: String, account: String).self, ())
    func deletePassword(service: String, account: String) {
        deletePassword_fake.fake((service, account))
    }
}

