import CoreData
import Foundation

protocol ReminderRepositoryProtocol {
    func fetchReminders() throws -> [Reminder]
    func saveReminder(_ reminder: Reminder) throws -> [Reminder]
    func deleteReminder(id: String) throws -> [Reminder]
}

final class CoreDataReminderRepository: ReminderRepositoryProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchReminders() throws -> [Reminder] {
        let context = coreDataStack.viewContext
        var result: Result<[Reminder], Error>!

        context.performAndWait {
            result = Result {
                try fetchReminders(context: context)
            }
        }

        return try result.get()
    }

    func saveReminder(_ reminder: Reminder) throws -> [Reminder] {
        let context = coreDataStack.viewContext
        var result: Result<[Reminder], Error>!

        context.performAndWait {
            result = Result {
                let object = try fetchReminderObject(id: reminder.id, context: context)
                    ?? NSEntityDescription.insertNewObject(
                        forEntityName: CoreDataEntity.reminder,
                        into: context
                    )

                object.setValue(reminder.id, forKey: "id")
                object.setValue(reminder.text, forKey: "text")
                object.setValue(reminder.description, forKey: "reminderDescription")
                object.setValue(Int16(reminder.priority.rawValue), forKey: "priorityRaw")
                object.setValue(reminder.flag, forKey: "flag")
                object.setValue(reminder.toDate, forKey: "toDate")
                object.setValue(reminder.isDone, forKey: "isDone")

                if object.value(forKey: "createdAt") == nil {
                    object.setValue(Date(), forKey: "createdAt")
                }

                try coreDataStack.saveIfNeeded()
                return try fetchReminders(context: context)
            }
        }

        return try result.get()
    }

    func deleteReminder(id: String) throws -> [Reminder] {
        let context = coreDataStack.viewContext
        var result: Result<[Reminder], Error>!

        context.performAndWait {
            result = Result {
                if let object = try fetchReminderObject(id: id, context: context) {
                    context.delete(object)
                    try coreDataStack.saveIfNeeded()
                }

                return try fetchReminders(context: context)
            }
        }

        return try result.get()
    }

    private func fetchReminderObject(
        id: String,
        context: NSManagedObjectContext
    ) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reminder)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func fetchReminders(context: NSManagedObjectContext) throws -> [Reminder] {
        let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.reminder)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        return try context.fetch(request).compactMap(Self.mapReminder)
    }

    private static func mapReminder(_ object: NSManagedObject) -> Reminder? {
        guard
            let id = object.value(forKey: "id") as? String,
            let text = object.value(forKey: "text") as? String,
            let description = object.value(forKey: "reminderDescription") as? String
        else {
            return nil
        }

        let priorityRaw = object.value(forKey: "priorityRaw") as? Int16
        let priority = Priority(rawValue: Int(priorityRaw ?? 0)) ?? .low
        let flag = object.value(forKey: "flag") as? Bool ?? false
        let toDate = object.value(forKey: "toDate") as? Date
        let isDone = object.value(forKey: "isDone") as? Bool ?? false

        return Reminder(
            id: id,
            text: text,
            description: description,
            priority: priority,
            flag: flag,
            toDate: toDate,
            isDone: isDone
        )
    }
}
