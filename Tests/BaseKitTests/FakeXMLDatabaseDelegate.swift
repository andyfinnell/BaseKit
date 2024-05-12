import TestKit
import BaseKit

final class FakeXMLDatabaseDelegate: XMLDatabaseDelegate {
    private(set) lazy var onChangesFake = FakeMethodCall(Set<XMLDatabaseChange>.self, ())
    func onChanges(_ changes: Set<XMLDatabaseChange>) {
        onChangesFake.fake(changes)
    }
}
