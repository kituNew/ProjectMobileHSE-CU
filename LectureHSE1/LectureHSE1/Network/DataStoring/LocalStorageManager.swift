//
//  LocalStorageManager.swift
//  SiriusYoungCon
//
//  Created by Никита Агафонов on 02.04.2025.
//

import Foundation

// MARK: - Protocols
protocol LocalStorageProtocol {
    func save<T: Encodable>(_ value: T, forKey key: String, storageType: StorageType) throws
    func fetch<T: Decodable>(forKey key: String, storageType: StorageType) throws -> T?
    func remove(forKey key: String, storageType: StorageType) throws
    func clear(storageType: StorageType) throws
}

// MARK: - Local storage manager
final class LocalStorageManager: LocalStorageProtocol {
    // MARK: - Properties
    private let fileManager = FileManager.default
    
    // MARK: - Public methods
    func save<T: Encodable>(_ value: T, forKey key: String, storageType: StorageType) throws {
        guard
            let directory = getDirectory(for: storageType)
        else {
            throw NSError(domain: "LocalStorageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Directory not found"])
        }
        
        let fileURL = directory.appendingPathComponent(key)
        let data = try JSONEncoder().encode(value)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func fetch<T: Decodable>(forKey key: String, storageType: StorageType) throws -> T? {
        guard
            let directory = getDirectory(for: storageType)
        else {
            throw NSError(domain: "LocalStorageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Directory not found"])
        }
        
        let fileURL = directory.appendingPathComponent(key)
        
        guard
            fileManager.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let object = try JSONDecoder().decode(T.self, from: data)
        
        return object
    }
    
    func remove(forKey key: String, storageType: StorageType) throws {
        guard
            let directory = getDirectory(for: storageType)
        else {
            return
        }
        
        let fileURL = directory.appendingPathComponent(key)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func clear(storageType: StorageType) throws {
        guard
            let directory = getDirectory(for: storageType)
        else {
            return
        }
        
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        
        for file in contents {
            try fileManager.removeItem(at: file)
        }
    }
    
    // MARK: - Private methods
    private func getDirectory(for storageType: StorageType) -> URL? {
        switch storageType {
        case .documents:
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        case .caches:
            return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        }
    }
}
