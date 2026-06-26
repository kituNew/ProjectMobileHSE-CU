import CoreData
import Foundation

enum CoreDataContextExecutionError: Error {
    case missingResult
}

extension NSManagedObjectContext {
    func performAndWaitResult<T>(_ block: () throws -> T) throws -> T {
        var result: Result<T, Error>?

        performAndWait {
            result = Result {
                try block()
            }
        }

        guard let result else {
            throw CoreDataContextExecutionError.missingResult
        }

        return try result.get()
    }
}
