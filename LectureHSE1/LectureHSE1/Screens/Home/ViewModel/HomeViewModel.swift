//
//  HomeViewModel.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.01.2026.
//

import UIKit

final class HomeViewModel {
    let networkService: NetworkService
        
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchNews(source: String, section: String, completion: @escaping (Result<[New]?, Error>) -> Void) async {
        if !NetworkMonitor.shared.isConnected {
            await loadCashedNews(source: source, section: section, completion: completion)
            return
        }
        
        do {
            let newsEndpoint = NewsEndpoint(source: source, section: section)
            let newsRequest = NewsRequest()

            let fetchedNews: NewsResponseDTO = try await networkService.request(
                endpoint: newsEndpoint,
                requestDTO: newsRequest
            )
            let news: [New] = fetchedNews.results.map { New(news: $0) }
            
            try networkService.localStorageManager.save(news, forKey: source+"_"+section, storageType: .caches)
            
            await MainActor.run {
                completion(.success(news))
            }
        } catch {
            await MainActor.run {
                completion(.failure(error))
            }
        }
    }
    
    func loadCashedNews(source: String, section: String, completion: @escaping (Result<[New]?, Error>) -> Void) async {
        do {
            let news: [New]? = try networkService.localStorageManager.fetch(forKey: source+"_"+section, storageType: .caches)
            await MainActor.run {
                completion(.success(news))
            }
        } catch {
            await MainActor.run {
                completion(.failure(error))
            }
        }
    }
    
    func loadImage(urlString: String?) async -> UIImage? {
        guard let urlString, let url = URL(string: urlString) else { return nil }
        return try? await networkService.downloadImage(from: url)
    }
}
