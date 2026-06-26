import XCTest
@testable import LectureHSE1

final class NotesUseCasesTests: XCTestCase {

    func testSaveNoteIgnoresBlankNote() throws {
        let repository = FakeNotesRepository()
        let useCase = SaveNoteUseCase(repository: repository)

        let result = try useCase.execute(
            note: Note(
                id: "1",
                title: "   ",
                text: "\n",
                updatedAt: .distantPast
            )
        )

        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(repository.saveCalls, 0)
    }

    func testSaveNoteCreatesUntitledNoteWhenTitleIsBlank() throws {
        let repository = FakeNotesRepository()
        let useCase = SaveNoteUseCase(repository: repository)

        let result = try useCase.execute(
            note: Note(
                id: "1",
                title: " ",
                text: "  Текст заметки  ",
                updatedAt: .distantPast
            )
        )

        XCTAssertEqual(result.first?.title, "Без названия")
        XCTAssertEqual(result.first?.text, "Текст заметки")
        XCTAssertEqual(repository.saveCalls, 1)
    }

    func testSaveNoteUpdatesExistingNoteWithoutDuplicate() throws {
        let repository = FakeNotesRepository(
            notes: [
                Note(
                    id: "1",
                    title: "Старый",
                    text: "old",
                    updatedAt: .distantPast
                )
            ]
        )
        let useCase = SaveNoteUseCase(repository: repository)

        let result = try useCase.execute(
            note: Note(
                id: "1",
                title: "Новый",
                text: "new",
                updatedAt: .distantPast
            )
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Новый")
        XCTAssertEqual(result.first?.text, "new")
    }

    func testDeleteNoteRemovesNoteById() throws {
        let repository = FakeNotesRepository(
            notes: [
                Note(
                    id: "1",
                    title: "Удалить",
                    text: "text",
                    updatedAt: .distantPast
                )
            ]
        )
        let useCase = DeleteNoteUseCase(repository: repository)

        let result = try useCase.execute(id: "1")

        XCTAssertTrue(result.isEmpty)
    }
}

private final class FakeNotesRepository: NotesRepositoryProtocol {
    private(set) var notes: [Note]
    private(set) var saveCalls = 0

    init(notes: [Note] = []) {
        self.notes = notes
    }

    func fetchNotes() throws -> [Note] {
        notes
    }

    func saveNote(_ note: Note) throws -> [Note] {
        saveCalls += 1

        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.insert(note, at: 0)
        }

        notes.sort { $0.updatedAt > $1.updatedAt }
        return notes
    }

    func deleteNote(id: String) throws -> [Note] {
        notes.removeAll { $0.id == id }
        return notes
    }
}
