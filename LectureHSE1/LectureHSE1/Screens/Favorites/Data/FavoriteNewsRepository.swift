import CoreData
import Foundation

protocol FavoriteNewsRepositoryProtocol {
    func fetchFavorites() throws -> [New]
    func isFavorite(_ news: New) throws -> Bool
    func toggleFavorite(_ news: New) throws -> [New]
    func removeFavorite(_ news: New) throws -> [New]
}

final class CoreDataFavoriteNewsRepository: FavoriteNewsRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchFavorites() throws -> [New] {
        let context = coreDataStack.viewContext

        return try context.performAndWaitResult {
            try fetchFavorites(context: context)
        }
    }

    func isFavorite(_ news: New) throws -> Bool {
        let context = coreDataStack.viewContext

        return try context.performAndWaitResult {
            try fetchFavoriteObject(id: news.cacheIdentifier, context: context) != nil
        }
    }

    func toggleFavorite(_ news: New) throws -> [New] {
        let context = coreDataStack.viewContext

        return try context.performAndWaitResult {
            if let object = try fetchFavoriteObject(id: news.cacheIdentifier, context: context) {
                context.delete(object)
            } else {
                let object = NSEntityDescription.insertNewObject(
                    forEntityName: CoreDataEntity.favoriteNews,
                    into: context
                )
                object.setValue(news.cacheIdentifier, forKey: "id")
                object.setValue(try encoder.encode(news), forKey: "payload")
                object.setValue(Date(), forKey: "cachedAt")
            }

            try coreDataStack.saveIfNeeded()
            return try fetchFavorites(context: context)
        }
    }

    func removeFavorite(_ news: New) throws -> [New] {
        let context = coreDataStack.viewContext

        return try context.performAndWaitResult {
            if let object = try fetchFavoriteObject(id: news.cacheIdentifier, context: context) {
                context.delete(object)
                try coreDataStack.saveIfNeeded()
            }

            return try fetchFavorites(context: context)
        }
    }

    private func fetchFavoriteObject(
        id: String,
        context: NSManagedObjectContext
    ) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.favoriteNews)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func fetchFavorites(context: NSManagedObjectContext) throws -> [New] {
        let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.favoriteNews)
        request.sortDescriptors = [
            NSSortDescriptor(key: "cachedAt", ascending: false)
        ]

        return try context.fetch(request).compactMap { object in
            guard let payload = object.value(forKey: "payload") as? Data else { return nil }
            return try? decoder.decode(New.self, from: payload)
        }
    }
}
