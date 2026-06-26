import CoreData
import UIKit

protocol NewsRepositoryProtocol {
    func searchNews(query: String) async throws -> [New]
    func loadImage(urlString: String?) async -> UIImage?
}

final class NewsRepository: NewsRepositoryProtocol {
    private let remoteDataSource: NewsRemoteDataSourceProtocol
    private let coreDataStack: CoreDataStack
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        remoteDataSource: NewsRemoteDataSourceProtocol,
        coreDataStack: CoreDataStack
    ) {
        self.remoteDataSource = remoteDataSource
        self.coreDataStack = coreDataStack
    }

    func searchNews(query: String) async throws -> [New] {
        let queryKey = cacheKey(for: query)

        if !NetworkMonitor.shared.isConnected {
            return try fetchCachedNews(queryKey: queryKey)
        }

        let news = try await remoteDataSource.searchNews(query: query)
        try saveCachedNews(news, queryKey: queryKey)
        return news
    }

    func loadImage(urlString: String?) async -> UIImage? {
        await remoteDataSource.loadImage(urlString: urlString)
    }

    private func cacheKey(for query: String) -> String {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let safeQuery = normalized.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? normalized
        return safeQuery
    }

    private func fetchCachedNews(queryKey: String) throws -> [New] {
        let context = coreDataStack.viewContext

        return try context.performAndWaitResult {
            let request = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.cachedNews)
            request.predicate = NSPredicate(format: "query == %@", queryKey)
            request.sortDescriptors = [
                NSSortDescriptor(key: "cachedAt", ascending: false)
            ]

            return try context.fetch(request).compactMap { object in
                guard let payload = object.value(forKey: "payload") as? Data else { return nil }
                return try? decoder.decode(New.self, from: payload)
            }
        }
    }

    private func saveCachedNews(
        _ news: [New],
        queryKey: String
    ) throws {
        let context = coreDataStack.viewContext

        try context.performAndWaitResult {
            let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntity.cachedNews)
            deleteRequest.predicate = NSPredicate(format: "query == %@", queryKey)
            let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            try context.execute(batchDelete)

            for article in news {
                let object = NSEntityDescription.insertNewObject(
                    forEntityName: CoreDataEntity.cachedNews,
                    into: context
                )
                object.setValue(article.id.uuidString, forKey: "id")
                object.setValue(queryKey, forKey: "query")
                object.setValue(try encoder.encode(article), forKey: "payload")
                object.setValue(Date(), forKey: "cachedAt")
            }

            try coreDataStack.saveIfNeeded()
        }
    }
}
