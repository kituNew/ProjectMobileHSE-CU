import XCTest
@testable import LectureHSE1

final class NotesPresenterTests: XCTestCase {

    func testViewDidLoadShowsFetchedNotes() {
        let notes = [makeTestNote(title: "Loaded")]
        let view = FakeNotesView()
        let presenter = NotesPresenter(
            fetchNotesUseCase: FakeFetchNotesUseCase(notes: notes),
            saveNoteUseCase: FakeSaveNoteUseCase(),
            deleteNoteUseCase: FakeDeleteNoteUseCase(),
            router: FakeNotesRouter()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.notes, notes)
    }

    func testSaveNoteShowsSavedNotes() {
        let note = makeTestNote(title: "Saved")
        let view = FakeNotesView()
        let presenter = NotesPresenter(
            fetchNotesUseCase: FakeFetchNotesUseCase(),
            saveNoteUseCase: FakeSaveNoteUseCase(notes: [note]),
            deleteNoteUseCase: FakeDeleteNoteUseCase(),
            router: FakeNotesRouter()
        )
        presenter.view = view

        presenter.saveNote(note)

        XCTAssertEqual(view.notes, [note])
    }

    func testDeleteNoteShowsRemainingNotes() {
        let note = makeTestNote(title: "Remaining")
        let view = FakeNotesView()
        let presenter = NotesPresenter(
            fetchNotesUseCase: FakeFetchNotesUseCase(),
            saveNoteUseCase: FakeSaveNoteUseCase(),
            deleteNoteUseCase: FakeDeleteNoteUseCase(notes: [note]),
            router: FakeNotesRouter()
        )
        presenter.view = view

        presenter.deleteNote(id: "deleted")

        XCTAssertEqual(view.notes, [note])
    }

    func testAddNoteTappedOpensEditorAndSavesReturnedNote() {
        let note = makeTestNote(title: "From editor")
        let view = FakeNotesView()
        let router = FakeNotesRouter(noteToReturnFromEditor: note)
        let presenter = NotesPresenter(
            fetchNotesUseCase: FakeFetchNotesUseCase(),
            saveNoteUseCase: FakeSaveNoteUseCase(notes: [note]),
            deleteNoteUseCase: FakeDeleteNoteUseCase(),
            router: router
        )
        presenter.view = view

        presenter.addNoteTapped()

        XCTAssertNil(router.openedNote)
        XCTAssertEqual(view.notes, [note])
    }

    func testEditNoteTappedOpensEditorWithSelectedNote() {
        let note = makeTestNote(title: "Existing")
        let router = FakeNotesRouter()
        let presenter = NotesPresenter(
            fetchNotesUseCase: FakeFetchNotesUseCase(),
            saveNoteUseCase: FakeSaveNoteUseCase(),
            deleteNoteUseCase: FakeDeleteNoteUseCase(),
            router: router
        )

        presenter.editNoteTapped(note)

        XCTAssertEqual(router.openedNote, note)
    }

    func testViewDidLoadShowsErrorWhenFetchFails() {
        let view = FakeNotesView()
        let presenter = NotesPresenter(
            fetchNotesUseCase: FakeFetchNotesUseCase(error: TestError.expected),
            saveNoteUseCase: FakeSaveNoteUseCase(),
            deleteNoteUseCase: FakeDeleteNoteUseCase(),
            router: FakeNotesRouter()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.errorMessage, TestError.expected.localizedDescription)
    }
}

private final class FakeNotesView: NotesViewProtocol {
    private(set) var notes: [Note] = []
    private(set) var errorMessage: String?

    func showNotes(_ notes: [Note]) {
        self.notes = notes
    }

    func showError(_ message: String) {
        errorMessage = message
    }
}

private final class FakeFetchNotesUseCase: FetchNotesUseCaseProtocol {
    let notes: [Note]
    let error: Error?

    init(notes: [Note] = [], error: Error? = nil) {
        self.notes = notes
        self.error = error
    }

    func execute() throws -> [Note] {
        if let error {
            throw error
        }
        return notes
    }
}

private final class FakeSaveNoteUseCase: SaveNoteUseCaseProtocol {
    let notes: [Note]
    let error: Error?

    init(notes: [Note] = [], error: Error? = nil) {
        self.notes = notes
        self.error = error
    }

    func execute(note: Note) throws -> [Note] {
        if let error {
            throw error
        }
        return notes
    }
}

private final class FakeDeleteNoteUseCase: DeleteNoteUseCaseProtocol {
    let notes: [Note]
    let error: Error?

    init(notes: [Note] = [], error: Error? = nil) {
        self.notes = notes
        self.error = error
    }

    func execute(id: String) throws -> [Note] {
        if let error {
            throw error
        }
        return notes
    }
}

private final class FakeNotesRouter: NotesRouting {
    let noteToReturnFromEditor: Note?
    private(set) var openedNote: Note?

    init(noteToReturnFromEditor: Note? = nil) {
        self.noteToReturnFromEditor = noteToReturnFromEditor
    }

    func showNoteEditor(note: Note?, onSave: @escaping (Note) -> Void) {
        openedNote = note
        if let noteToReturnFromEditor {
            onSave(noteToReturnFromEditor)
        }
    }
}
