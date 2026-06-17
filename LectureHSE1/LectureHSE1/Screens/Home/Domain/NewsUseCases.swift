import UIKit

protocol SearchNewsUseCaseProtocol {
    func execute(query: String) async throws -> [New]
}

final class SearchNewsUseCase: SearchNewsUseCaseProtocol {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [New] {
        try await repository.searchNews(query: query)
    }
}

protocol LoadNewsImageUseCaseProtocol {
    func execute(urlString: String?) async -> UIImage?
}

final class LoadNewsImageUseCase: LoadNewsImageUseCaseProtocol {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(urlString: String?) async -> UIImage? {
        await repository.loadImage(urlString: urlString)
    }
}
