import Foundation

public final class XMLDatabase {
    private var roots = [XMLID]()
    private var values = [XMLID: XMLValue]()
    private var referenceIDs: Set<String>
    private var commandStream: OpenCommand?
    
    init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
        
        let refIDs = values.values.compactMap { value in
            if case let .element(element) = value {
                return element.attributes[.id]
            } else {
                return nil
            }
        }
        self.referenceIDs = Set(refIDs)
    }
    
    public var snapshot: XMLSnapshot {
        XMLSnapshot(roots: roots, values: values)
    }
    
    public var rootValues: [XMLValue] {
        roots.compactMap { values[$0] }
    }
    
    public subscript(_ id: XMLID) -> XMLValue? {
        values[id]
    }
    
    public subscript(_ path: XMLPath) -> XMLValue? {
        resolve(path.segments, from: roots, on: nil)
    }
    
    public func element(byID id: XMLID) -> XMLElement? {
        if case let .element(element) = self[id] {
            return element
        } else {
            return nil
        }
    }
    
    public func childValues(for element: XMLElement) -> [XMLValue] {
        element.children.compactMap { values[$0] }
    }
    
    public func childElements(for element: XMLElement) -> [XMLElement] {
        childValues(for: element).compactMap { value in
            if case let .element(element) = value {
                return element
            } else {
                return nil
            }
        }
    }
    
    public func perform(
        _ command: XMLCommand
    ) throws -> (undo: XMLCommand, changes: Set<XMLDatabaseChange>) {
        guard commandStream == nil else {
            throw XMLError.commandStreamAlreadyOpen
        }

        var undoLog = [XMLChange]()
        let changedObjectIDs = try perform(command, undoLog: &undoLog)
        let undoCommand = XMLCommand(name: command.name, changes: undoLog)
        return (undo: undoCommand, changes: changedObjectIDs)
    }
    
    public func beginCommandStream(withName name: String) throws {
        guard commandStream == nil else {
            throw XMLError.commandStreamAlreadyOpen
        }
        commandStream = OpenCommand(name: name)
    }
    
    public func updateCommandStream(with command: XMLCommand) throws -> Set<XMLDatabaseChange> {
        guard let commandStream else {
            throw XMLError.noOpenCommandStream
        }
        
        var undoLog = [XMLChange]()
        let changedObjectIDs = try perform(command, undoLog: &undoLog)
        commandStream.append(undoLog)
        
        return changedObjectIDs
    }
    
    public func completeCommandStream() throws -> XMLCommand {
        guard let commandStream else {
            throw XMLError.noOpenCommandStream
        }

        let undoCommand = XMLCommand(
            name: commandStream.name,
            changes: commandStream.undoLog
        )
        
        self.commandStream = nil
        
        return undoCommand
    }
    
    public func cancelCommandStream() throws -> Set<XMLDatabaseChange> {
        guard let commandStream else {
            throw XMLError.noOpenCommandStream
        }

        // Rollback the changes
        let changes = rollback(commandStream.undoLog)
        
        self.commandStream = nil
        
        return changes
    }
}

private extension XMLDatabase {
    final class OpenCommand {
        let name: String
        private(set) var undoLog = [XMLChange]()
        
        init(name: String) {
            self.name = name
        }
        
        func append(_ changes: [XMLChange]) {
            // This will be played back from first to last.
            let necessaryChanges = changes.filter { isNecessaryChange($0) }
            undoLog.prepend(contentsOf: necessaryChanges)
        }
        
        private func isNecessaryChange(_ change: XMLChange) -> Bool {
            switch change {
            case .create:
                return true
            case .destroy:
                return true
            case let .update(update):
                let isRedundant = undoLog.contains { existing in
                    // If something after us will overwrite or destroy
                    if case let .update(existingUpdate) = existing,
                       existingUpdate.valueID == update.valueID {
                        return true
                    } else if case let .destroy(destroy) = existing,
                              destroy.id == update.valueID {
                        return true
                    } else {
                        return false
                    }
                }
                return !isRedundant
                
            case .upsert:
                return true
            case let .upsertAttribute(upsert):
                let isRedundant = undoLog.contains { existing in
                    // If something after us will overwrite or destroy
                    if case let .upsertAttribute(existingUpsert) = existing,
                       existingUpsert.elementID == upsert.elementID,
                       existingUpsert.attributeName == upsert.attributeName {
                        return true
                    } else if case let .destroyAttribute(destroy) = existing,
                              destroy.elementID == upsert.elementID,
                              destroy.attributeName == upsert.attributeName {
                        return true
                    } else if case let .destroy(destroy) = existing,
                              destroy.id == upsert.elementID {
                        return true
                    } else {
                        return false
                    }
                }
                return !isRedundant
                
            case let .destroyAttribute(destroyAttr):
                let isRedundant = undoLog.contains { existing in
                    // If something after us will overwrite or destroy
                    if case let .upsertAttribute(existingUpsert) = existing,
                       existingUpsert.elementID == destroyAttr.elementID,
                       existingUpsert.attributeName == destroyAttr.attributeName {
                        return true
                    } else if case let .destroyAttribute(destroy) = existing,
                              destroy.elementID == destroyAttr.elementID,
                              destroy.attributeName == destroyAttr.attributeName {
                        return true
                    } else if case let .destroy(destroy) = existing,
                              destroy.id == destroyAttr.elementID {
                        return true
                    } else {
                        return false
                    }
                }
                return !isRedundant
            case .reorder:
                return true // unfortunately can't match this with anything else
            }
        }
    }
    
    final class CommandContext {
        private var referenceIDs = [String: String]()
        
        init() {}
        
        func register(_ resolvedID: String, forFuture future: XMLReferenceIDFuture) {
            referenceIDs[future.name] = resolvedID
        }
        
        func resolveFuture(_ future: XMLReferenceIDFuture) -> String? {
            referenceIDs[future.name]
        }
        
        var variables: [String: String] { referenceIDs }
        
        func updateContext() -> XMLUpdateContext {
            XMLUpdateContext(variables: variables)
        }
    }
    
    func resolve(_ path: [XMLPathSegment], from roots: [XMLID], on currentValue: XMLValue?) -> XMLValue? {
        guard let nextSegment = path.first else {
            return currentValue // done!
        }
        guard let nextValue = find(nextSegment, in: roots) else {
            return nil // we couldn't find it
        }
        
        // Recurse
        let remainingPath = Array(path.dropFirst())
        return resolve(remainingPath, from: nextValue.children, on: nextValue)
    }
    
    func find(_ segment: XMLPathSegment, in ids: [XMLID]) -> XMLValue? {
        let values = ids.compactMap { self.values[$0] }
        var i = 0
        for value in values {
            guard doesMatch(value, kind: segment.kind) else {
                continue
            }
            
            if segment.index == i {
                return value // match!
            }
            
            i += 1
        }
        return nil // no match :-(
    }
    
    func doesMatch(_ value: XMLValue, kind: XMLPathKind) -> Bool {
        switch kind {
        case let .element(elementName):
            guard case let .element(valueElement) = value else {
                return false
            }
            return elementName == valueElement.name
        case .text:
            if case .text = value {
                return true
            } else {
                return false
            }
        case .whitespace:
            if case .ignorableWhitespace = value {
                return true
            } else {
                return false
            }
        case .cdata:
            if case .cdata = value {
                return true
            } else {
                return false
            }
        case .comment:
            if case .comment = value {
                return true
            } else {
                return false
            }
        }
    }
        
    func rollback(_ undoChanges: [XMLChange]) -> Set<XMLDatabaseChange> {
        // Best effort rollback
        var changedIDs = Set<XMLDatabaseChange>()
        let context = CommandContext()
        for change in undoChanges {
            do {
                _ = try perform(change, impacting: &changedIDs, in: context)
            } catch {
                // eat it
            }
        }
        return changedIDs
    }
    
    func perform(
        _ command: XMLCommand,
        undoLog: inout [XMLChange]
    ) throws -> Set<XMLDatabaseChange> {
        do {
            var changedObjectIDs = Set<XMLDatabaseChange>()
            let commandContext = CommandContext()
            for change in command.changes {
                let undoChanges = try perform(
                    change,
                    impacting: &changedObjectIDs,
                    in: commandContext
                )
                undoLog.insert(contentsOf: undoChanges, at: 0)
            }
            
            return changedObjectIDs
        } catch {
            print("XMLDatabase.perform FAILURE")
            _ = rollback(undoLog)
            throw XMLError.commandFailed(command.name, error)
        }
    }

    func perform(
        _ change: XMLChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        switch change {
        case let .create(create):
            return try perform(create, impacting: &changedObjectIDs, in: context)
        case let .destroy(destroy):
            return try perform(destroy, impacting: &changedObjectIDs, in: context)
        case let .update(update):
            return try perform(update, impacting: &changedObjectIDs, in: context)
        case let .reorder(reorder):
            return try perform(reorder, impacting: &changedObjectIDs, in: context)
        case let .upsert(upsert):
            return try perform(upsert, impacting: &changedObjectIDs, in: context)
        case let .upsertAttribute(upsertAttribute):
            return try perform(upsertAttribute, impacting: &changedObjectIDs, in: context)
        case let .destroyAttribute(destroyAttribute):
            return try perform(destroyAttribute, impacting: &changedObjectIDs, in: context)
        }
    }
    
    func perform(
        _ change: XMLCreateChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        let new = change.factory(
            createContext(
                forInsertingInto: change.parentID,
                at: change.index,
                commandContext: context
            )
        )
        register(new, in: context)
        
        // Perform the actual change
        try insert(new.roots, into: change.parentID, at: change.index)
        
        // Make note what changed
        changedObjectIDs.formUnion(new.values.keys.map { create($0) })
        if let parentID = change.parentID {
            changedObjectIDs.insert(update(parentID))
        } else {
            changedObjectIDs.insert(.updateRoot)
        }
        
        // Create the reverse change
        let undoChanges = new.roots.reversed().map {
            XMLChange.destroy(XMLDestroyChange(id: $0))
        }
        return undoChanges
    }
    
    func perform(
        _ change: XMLDestroyChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        guard let old = values[change.id] else {
            throw XMLError.valueNotFound(change.id)
        }

        // Grab a snapshot before we remove
        let oldSnapshot = snapshot(from: change.id)

        // Perform the actual remove
        let oldIndex = try remove(old, from: old.parentID)

        // Makes sure everything is unregistered
        let removedIDs = unregister(old)

        // Make note what changed
        changedObjectIDs.formUnion(removedIDs)
        if let parentID = old.parentID {
            changedObjectIDs.insert(update(parentID))
        } else {
            changedObjectIDs.insert(.updateRoot)
        }

        // Create the undo
        let undoChange = XMLChange.create(
            XMLCreateChange(
                parentID: old.parentID,
                index: oldIndex,
                factory: { _ in oldSnapshot }
            )
        )
        return [undoChange]
    }
    
    func perform(
        _ change: XMLUpdateContentChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        guard let existing = values[change.valueID] else {
            throw XMLError.valueNotFound(change.valueID)
        }
        
        // Fetch the old value for the undo
        let existingContent = try existing.content()
        
        // Make the change
        values[change.valueID] = try existing.updateContent(change.content)
        
        // Make note of what changed
        changedObjectIDs.insert(update(change.valueID))
        
        // Create the undo record
        let undoChange = XMLChange.update(
            XMLUpdateContentChange(
                valueID: change.valueID,
                content: existingContent
            )
        )
        return [undoChange]
    }
    
    func perform(
        _ change: XMLReorderChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        // Make the change
        if let parentID = change.parentID {
            guard let parent = values[parentID] else {
                throw XMLError.valueNotFound(parentID)
            }

            values[parentID] = try parent.reorderChild(from: change.fromIndex, to: change.toIndex)
            
            // Make note of what changed
            changedObjectIDs.insert(update(parentID))
        } else {
            // We're changing the root
            
            // Make the change
            roots.reorder(from: change.fromIndex, to: change.toIndex)
            
            // Make note of what changed
            changedObjectIDs.insert(.updateRoot)
        }
        
        // Create the undo record
        let undoChange = XMLChange.reorder(
            XMLReorderChange(
                parentID: change.parentID,
                fromIndex: change.toIndex,
                toIndex: change.fromIndex
            )
        )
        return [undoChange]
    }

    func perform(
        _ change: XMLUpsertChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        // First, see if this thing already exists
        let existing = try query(change.existingElementQuery, in: change.parentID)
        var undoChanges = [[XMLChange]]()
        var upsertedElement = existing
        if existing == nil {
            let createChange = XMLCreateChange(parentID: change.parentID,
                                               index: change.index,
                                               factory: change.factory)
            let createUndoChanges = try perform(createChange, impacting: &changedObjectIDs, in: context)
            undoChanges.append(createUndoChanges)
            
            // Re-run the query
            upsertedElement = try query(change.existingElementQuery, in: change.parentID)
        }
        
        guard let upsertedElement else {
            throw XMLError.upsertFailedToCreateElement
        }
        
        // Now perform the follow up actions
        let subsequentChanges = change.changesFactory(upsertedElement)
        for change in subsequentChanges {
            let subsequentUndoChanges = try perform(change, impacting: &changedObjectIDs, in: context)
            undoChanges.append(subsequentUndoChanges)
        }
                
        return undoChanges.reversed().flatMap { $0 }
    }

    func query(_ upsertQuery: XMLUpsertQuery, in parentID: XMLID?) throws -> XMLElement? {
        switch upsertQuery {
        case let .name(name):
            return try query(byName: name, in: childElements(for: parentID))
        }
    }

    func childElements(for parentID: XMLID?) throws -> [XMLElement] {
        if let parentID {
            guard let parent = element(byID: parentID) else {
                throw XMLError.valueNotFound(parentID)
            }
            return childElements(for: parent)
        } else {
            return rootElements
        }
    }
    
    var rootElements: [XMLElement] {
        rootValues.compactMap { value in
            if case let .element(element) = value {
                return element
            } else {
                return nil
            }
        }
    }
    
    func query(byName name: XMLName, in elements: [XMLElement]) -> XMLElement? {
        elements.first(where: { $0.name == name })
    }

    func perform(
        _ change: XMLAttributeUpsertChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        guard let existing = values[change.elementID] else {
            throw XMLError.valueNotFound(change.elementID)
        }
        let oldValue = try existing.attribute(for: change.attributeName)
        
        // Make the change
        values[change.elementID] = try existing.updateAttribute(
            change.attributeValue(context.updateContext()),
            for: change.attributeName
        )
        
        // Make note of what changed
        changedObjectIDs.insert(update(change.elementID))
        
        // Create the undo record
        let undoChange: XMLChange
        if let oldValue {
            undoChange = XMLChange.upsertAttribute(
                XMLAttributeUpsertChange(
                    elementID: change.elementID,
                    attributeName: change.attributeName,
                    attributeValue: { _ in oldValue }
                )
            )
        } else {
            undoChange = XMLChange.destroyAttribute(
                XMLAttributeDestroyChange(
                    elementID: change.elementID,
                    attributeName: change.attributeName
                )
            )
        }
        return [undoChange]
    }

    func perform(
        _ change: XMLAttributeDestroyChange,
        impacting changedObjectIDs: inout Set<XMLDatabaseChange>,
        in context: CommandContext
    ) throws -> [XMLChange] {
        guard let existing = values[change.elementID],
              let oldValue = try existing.attribute(for: change.attributeName) else {
            return [] // no reason to fail. Treat like the opposite of an upsert
        }
        
        // Make the change
        values[change.elementID] = try existing.removeAttribute(for: change.attributeName)
        
        // Make note of what changed
        changedObjectIDs.insert(update(change.elementID))
        
        // Create the undo record
        let undoChange = XMLChange.upsertAttribute(
                XMLAttributeUpsertChange(
                    elementID: change.elementID,
                    attributeName: change.attributeName,
                    attributeValue: { _ in oldValue }
                )
            )
        return [undoChange]
    }

    func create(_ id: XMLID) -> XMLDatabaseChange {
        XMLDatabaseChange.create(id, changeSubjectKind(id))
    }

    func update(_ id: XMLID) -> XMLDatabaseChange {
        XMLDatabaseChange.update(id, changeSubjectKind(id))
    }

    func destroy(_ id: XMLID) -> XMLDatabaseChange {
        XMLDatabaseChange.destroy(id, changeSubjectKind(id))
    }

    func changeSubjectKind(_ id: XMLID) -> XMLDatabaseChangeSubjectKind {
        switch values[id] {
        case let .element(element): .element(element.name)
        case .text: .text
        case .cdata: .cdata
        case .comment: .comment
        case .ignorableWhitespace: .ignorableWhitespace
        case .none: .root
        }
    }
    
    func register(_ snapshot: XMLPartialSnapshot, in context: CommandContext) {
        for (id, value) in snapshot.values {
            var newValue = value
            if case let .element(element) = newValue, let futureID = snapshot.referenceIDs[id] {
                let newReferenceID = allocateReferenceID(fromTemplate: futureID.template)
                newValue = .element(element.updateAttribute(newReferenceID, for: .id))
                context.register(newReferenceID, forFuture: futureID)
            }
            
            values[id] = newValue
            if case let .element(element) = newValue, let refID = element.attributes[.id] {
                referenceIDs.insert(refID)
            }
        }
    }

    func allocateReferenceID(fromTemplate template: String) -> String {
        var proposal = template
        var suffix = 2
        while referenceIDs.contains(proposal) {
            proposal = "\(template)\(suffix)"
            suffix += 1
        }
        return proposal
    }
    
    func unregister(_ value: XMLValue) -> Set<XMLDatabaseChange> {
        var removed = Set<XMLDatabaseChange>()
        enumerateValues(on: value) { value in
            // Don't modifiy self while walking the hierarchy
            removed.insert(destroy(value.id))
        }
        
        for removedID in removed {
            guard case let .value(id) = removedID.id else {
                continue
            }
            values.removeValue(forKey: id)
        }
        
        return removed
    }
    
    func insert(_ valuesToBeInserted: [XMLID], into parentID: XMLID?, at index: XMLIndex) throws {
        if let parentID {
            guard let parent = values[parentID] else {
                throw XMLError.valueNotFound(parentID)
            }
            values[parentID] = try parent.insertChildren(contentsOf: valuesToBeInserted, at: index)
        } else {
            roots.insert(contentsOf: valuesToBeInserted, at: index)
        }
    }
    
    func remove(_ value: XMLValue, from parentID: XMLID?) throws -> XMLIndex {
        if let parentID {
            guard let parent = values[parentID] else {
                throw XMLError.valueNotFound(parentID)
            }
            let (updatedParent, removedIndex) = try parent.removeChild(value.id)
            values[parentID] = updatedParent
            return removedIndex
        } else {
            return try .at(roots.remove(where: { $0 == value.id }))
        }
    }
    
    func enumerateValues(on id: XMLID, block: (XMLValue) -> Void) {
        guard let value = values[id] else {
            return
        }
        enumerateValues(on: value, block: block)
    }
    
    func enumerateValues(on value: XMLValue, block: (XMLValue) -> Void) {
        block(value)
        for childID in value.children {
            enumerateValues(on: childID, block: block)
        }
    }
    
    func snapshot(from rootID: XMLID) -> XMLPartialSnapshot {
        var snapshotValues = [XMLID: XMLValue]()
        enumerateValues(on: rootID) { value in
            snapshotValues[value.id] = value
        }
        return XMLPartialSnapshot(roots: [rootID], values: snapshotValues)
    }
    
    func createContext(forInsertingInto parentID: XMLID?, at index: XMLIndex, commandContext: CommandContext) -> XMLCreateContext {
        guard let parentID else {
            // Root is a special case
            return XMLCreateContext(indent: 0, isFirst: false, isLast: false, variables: commandContext.variables)
        }
        let createIndent = indent(of: parentID) + 1
        let existingChildValues = element(byID: parentID).map { childValues(for: $0) } ?? []
        
        return XMLCreateContext(
            indent: createIndent,
            isFirst: existingChildValues.isEmpty || index == .at(0),
            isLast: existingChildValues.isEmpty || index == .last || index == .at(existingChildValues.count),
            variables: commandContext.variables
        )
    }
    
    func indent(of id: XMLID?) -> Int {
        // Go back until we find the first newline, then count forward until
        //  we hit the first non-whitespace character
        guard let id, let value = values[id] else {
            return 0
        }
        if let parentID = value.parentID, let parent = element(byID: parentID) {
            let previousSiblings = childValues(for: parent)
                .prefix(while: { $0.id != id })
            if let indent = indent(of: Array(previousSiblings)) {
                return indent
            } else {
                // need to recurse upwards the XML tree
                return indent(of: parentID)
            }
        } else {
            let previousSiblings = rootValues.prefix(while: { $0.id != id })
            if let indent = indent(of: Array(previousSiblings)) {
                return indent
            } else {
                // we're at the root, so must not be an indent
                return 0
            }
        }
    }
    
    
    func indent(of previousSiblings: [XMLValue]) -> Int? {
        var buffer = ""
        for prior in previousSiblings.reversed() {
            switch prior {
            case .element, .cdata, .comment:
                buffer = "" // reset the buffer
            case let .text(text):
                if let indent = updateIndentBuffer(&buffer, with: text.characters) {
                    return indent
                }
            case let .ignorableWhitespace(whitespace):
                if let indent = updateIndentBuffer(&buffer, with: whitespace.text) {
                    return indent
                }
            }
        }
        return nil
    }
    
    func updateIndentBuffer(_ buffer: inout String, with text: String) -> Int? {
        if let newlineIndex = text.lastIndex(of: "\n") {
            let characters = String(text[newlineIndex..<text.endIndex].dropFirst())
            buffer = characters + buffer
            return countIndent(of: buffer)
        } else {
            // No newline yet, so prepend it to be processed later
            buffer = text + buffer
            return nil
        }
    }
    
    func countIndent(of text: String) -> Int {
        let spacesPerTab = 2
        
        var indent = 0
        for c in text {
            if c == " " {
                indent += 1
            } else if c == "\t" {
                indent += spacesPerTab
            } else {
                break // stop
            }
        }
        
        return Int(ceil(Double(indent) / Double(spacesPerTab)))
    }
}
