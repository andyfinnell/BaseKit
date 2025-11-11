import Foundation
import TestKit
@testable import BaseKit

final class FakeAuthenticationStorage: AuthenticationStorageType {
    let authenticationHeader_fake = SendableMethodCall(String.self, String?.none)
    func authenticationHeader(for service: String) -> String? {
        authenticationHeader_fake.fake(service)
    }
}
