import UIKit

protocol NewsRemoteDataSourceProtocol {
    func searchNews(query: String) async throws -> [New]
    func loadImage(urlString: String?) async -> UIImage?
}

final class NewsRemoteDataSource: NewsRemoteDataSourceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func searchNews(query: String) async throws -> [New] {
        let response: NewsResponseDTO = try await networkService.request(
            endpoint: NewsEndpoint(query: query),
            requestDTO: NewsRequest()
        )
        return response.response.docs.map { New(news: $0) }
    }

    func loadImage(urlString: String?) async -> UIImage? {
        guard let urlString, let url = URL(string: urlString) else { return nil }
        return try? await networkService.downloadImage(from: url)
    }
}
