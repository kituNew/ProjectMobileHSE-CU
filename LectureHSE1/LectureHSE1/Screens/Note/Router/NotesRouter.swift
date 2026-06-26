import UIKit

protocol NotesRouting {
    func showNoteEditor(note: Note?, onSave: @escaping (Note) -> Void)
}

final class NotesRouter: NotesRouting {
    weak var viewController: UIViewController?

    func showNoteEditor(note: Note?, onSave: @escaping (Note) -> Void) {
        let editorVC = NoteEditorViewController(note: note, onSave: onSave)
        viewController?.navigationController?.pushViewController(editorVC, animated: true)
    }
}
