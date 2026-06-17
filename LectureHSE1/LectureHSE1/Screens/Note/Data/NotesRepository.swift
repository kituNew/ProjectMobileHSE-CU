import CoreData
import Foundation

protocol NotesRepositoryProtocol {
    func fetchNotes() throws -> [Note]
    func saveNote(_ note: Note) throws -> [Note]
    func deleteNote(id: String) throws -> [Note]
}

final class CoreDataNotesRepository: NotesRepositoryProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchNotes() throws -> [Note] {
        let context = coreDataStack.viewContext
        var result: Result<[Note], Error>!

        context.performAndWait {
            result = Result {
                try fetchNotes(context: context)
            }
        }

        return try result.get()
    }

    func saveNote(_ note: Note) throws -> [Note] {
        let context = coreDataStack.viewContext
        var result: Result<[Note], Error>!

        context.performAndWait {
            result = Result {
                let object = try fetchNoteObject(id: note.id, context: context)
                    ?? NSEntityDescription.insertNewObject(
                        forEntityName: CoreDataEntity.note,
                        into: context
                    )

                object.setValue(note.id, forKey: "id")
                object.setValue(note.title, forKey: "title")
                object.setValue(note.text, forKey: "text")
                object.setValue(note.updatedAt, forKey: "updatedAt")

                try coreDataStack.saveIfNeeded()
                return try fetchNotes(context: context)
            }
        }

        return try result.get()
    }

    func deleteNote(id: String) throws -> [Note] {
        let context = coreDataStack.viewContext
        var result: Result<[Note], Error>!

        context.performAndWait {
            result = Result {
                if let object = try fetchNoteObject(id: id, context: context) {
                    context.delete(object)
                    try coreDataStack.saveIfNeeded()
                }

                return try fetchNotes(context: context)
            }
        }

        return try result.get()
    }

    private func fetchNoteObject(
        id: String,
        context: NSManagedObjectContext
    ) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.note)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func fetchNotes(context: NSManagedObjectContext) throws -> [Note] {
        let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.note)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]

        return try context.fetch(request).compactMap(Self.mapNote)
    }

    private static func mapNote(_ object: NSManagedObject) -> Note? {
        guard
            let id = object.value(forKey: "id") as? String,
            let title = object.value(forKey: "title") as? String,
            let text = object.value(forKey: "text") as? String,
            let updatedAt = object.value(forKey: "updatedAt") as? Date
        else {
            return nil
        }

        return Note(
            id: id,
            title: title,
            text: text,
            updatedAt: updatedAt
        )
    }
}
