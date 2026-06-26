import Foundation

protocol NotesViewProtocol: AnyObject {
    func showNotes(_ notes: [Note])
    func showError(_ message: String)
}

protocol NotesPresenting: AnyObject {
    func viewDidLoad()
    func addNoteTapped()
    func editNoteTapped(_ note: Note)
    func deleteNote(id: String)
    func saveNote(_ note: Note)
}

final class NotesPresenter: NotesPresenting {
    weak var view: NotesViewProtocol?

    private let fetchNotesUseCase: FetchNotesUseCaseProtocol
    private let saveNoteUseCase: SaveNoteUseCaseProtocol
    private let deleteNoteUseCase: DeleteNoteUseCaseProtocol
    private let router: NotesRouting

    init(
        fetchNotesUseCase: FetchNotesUseCaseProtocol,
        saveNoteUseCase: SaveNoteUseCaseProtocol,
        deleteNoteUseCase: DeleteNoteUseCaseProtocol,
        router: NotesRouting
    ) {
        self.fetchNotesUseCase = fetchNotesUseCase
        self.saveNoteUseCase = saveNoteUseCase
        self.deleteNoteUseCase = deleteNoteUseCase
        self.router = router
    }

    func viewDidLoad() {
        do {
            view?.showNotes(try fetchNotesUseCase.execute())
        } catch {
            view?.showError(error.localizedDescription)
        }
    }

    func addNoteTapped() {
        router.showNoteEditor(note: nil) { [weak self] note in
            self?.saveNote(note)
        }
    }

    func editNoteTapped(_ note: Note) {
        router.showNoteEditor(note: note) { [weak self] note in
            self?.saveNote(note)
        }
    }

    func deleteNote(id: String) {
        do {
            view?.showNotes(try deleteNoteUseCase.execute(id: id))
        } catch {
            view?.showError(error.localizedDescription)
        }
    }

    func saveNote(_ note: Note) {
        do {
            view?.showNotes(try saveNoteUseCase.execute(note: note))
        } catch {
            view?.showError(error.localizedDescription)
        }
    }
}
