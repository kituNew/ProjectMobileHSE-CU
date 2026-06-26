import XCTest
@testable import LectureHSE1

final class CoreDataNotesRepositoryTests: XCTestCase {

    func testSaveNoteCreatesAndFetchesNoteSortedByUpdatedAt() throws {
        let repository = CoreDataNotesRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let oldNote = makeTestNote(
            id: "old",
            title: "Old",
            updatedAt: Date(timeIntervalSince1970: 1)
        )
        let newNote = makeTestNote(
            id: "new",
            title: "New",
            updatedAt: Date(timeIntervalSince1970: 2)
        )

        _ = try repository.saveNote(oldNote)
        let notes = try repository.saveNote(newNote)

        XCTAssertEqual(notes, [newNote, oldNote])
        XCTAssertEqual(try repository.fetchNotes(), [newNote, oldNote])
    }

    func testSaveNoteUpdatesExistingNoteWithoutDuplicate() throws {
        let repository = CoreDataNotesRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let original = makeTestNote(id: "same", title: "Original")
        let updated = makeTestNote(id: "same", title: "Updated")

        _ = try repository.saveNote(original)
        let notes = try repository.saveNote(updated)

        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first, updated)
    }

    func testDeleteNoteRemovesNoteById() throws {
        let repository = CoreDataNotesRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let note = makeTestNote(id: "delete-me")

        _ = try repository.saveNote(note)
        let notes = try repository.deleteNote(id: note.id)

        XCTAssertTrue(notes.isEmpty)
        XCTAssertTrue(try repository.fetchNotes().isEmpty)
    }
}
