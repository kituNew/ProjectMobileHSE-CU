import CoreData
import Foundation

final class CoreDataStack {
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "LectureHSE1Storage",
            managedObjectModel: Self.makeModel()
        )

        guard let storeDescription = container.persistentStoreDescriptions.first else {
            fatalError("Core Data store description is missing")
        }

        if inMemory {
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        storeDescription.setOption(
            true as NSNumber,
            forKey: NSMigratePersistentStoresAutomaticallyOption
        )
        storeDescription.setOption(
            true as NSNumber,
            forKey: NSInferMappingModelAutomaticallyOption
        )

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data store failed to load: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveIfNeeded() throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            makeCachedNewsEntity(),
            makeFavoriteNewsEntity(),
            makeNoteEntity(),
            makeReminderEntity()
        ]
        return model
    }

    private static func makeCachedNewsEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataEntity.cachedNews
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            attribute("id", .stringAttributeType, isOptional: false),
            attribute("query", .stringAttributeType, isOptional: false),
            attribute("payload", .binaryDataAttributeType, isOptional: false),
            attribute("cachedAt", .dateAttributeType, isOptional: false)
        ]
        return entity
    }

    private static func makeFavoriteNewsEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataEntity.favoriteNews
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            attribute("id", .stringAttributeType, isOptional: false),
            attribute("payload", .binaryDataAttributeType, isOptional: false),
            attribute("cachedAt", .dateAttributeType, isOptional: false)
        ]
        return entity
    }

    private static func makeNoteEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataEntity.note
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            attribute("id", .stringAttributeType, isOptional: false),
            attribute("title", .stringAttributeType, isOptional: false),
            attribute("text", .stringAttributeType, isOptional: false),
            attribute("updatedAt", .dateAttributeType, isOptional: false)
        ]
        return entity
    }

    private static func makeReminderEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataEntity.reminder
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            attribute("id", .stringAttributeType, isOptional: false),
            attribute("text", .stringAttributeType, isOptional: false),
            attribute("reminderDescription", .stringAttributeType, isOptional: false),
            attribute("priorityRaw", .integer16AttributeType, isOptional: false),
            attribute("flag", .booleanAttributeType, isOptional: false),
            attribute("toDate", .dateAttributeType, isOptional: true),
            attribute("isDone", .booleanAttributeType, isOptional: false),
            attribute("createdAt", .dateAttributeType, isOptional: false)
        ]
        return entity
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        isOptional: Bool
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = isOptional
        return attribute
    }
}

enum CoreDataEntity {
    static let cachedNews = "CachedNewsEntity"
    static let favoriteNews = "FavoriteNewsEntity"
    static let note = "NoteEntity"
    static let reminder = "ReminderEntity"
}
