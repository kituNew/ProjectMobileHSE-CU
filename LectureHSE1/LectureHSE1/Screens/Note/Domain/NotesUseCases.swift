import Foundation

protocol FetchNotesUseCaseProtocol {
    func execute() throws -> [Note]
}

final class FetchNotesUseCase: FetchNotesUseCaseProtocol {
    private let repository: NotesRepositoryProtocol

    init(repository: NotesRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [Note] {
        try repository.fetchNotes()
    }
}

protocol SaveNoteUseCaseProtocol {
    func execute(note: Note) throws -> [Note]
}

final class SaveNoteUseCase: SaveNoteUseCaseProtocol {
    private let repository: NotesRepositoryProtocol

    init(repository: NotesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(note: Note) throws -> [Note] {
        var noteToSave = note
        let trimmedTitle = noteToSave.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = noteToSave.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty || !trimmedText.isEmpty else { return try repository.fetchNotes() }

        noteToSave.title = trimmedTitle.isEmpty ? "Без названия" : trimmedTitle
        noteToSave.text = trimmedText
        noteToSave.updatedAt = Date()
        return try repository.saveNote(noteToSave)
    }
}

protocol DeleteNoteUseCaseProtocol {
    func execute(id: String) throws -> [Note]
}

final class DeleteNoteUseCase: DeleteNoteUseCaseProtocol {
    private let repository: NotesRepositoryProtocol

    init(repository: NotesRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) throws -> [Note] {
        try repository.deleteNote(id: id)
    }
}
