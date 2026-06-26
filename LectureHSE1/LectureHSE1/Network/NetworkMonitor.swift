//
//  NetworkMonitor.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 09.03.2026.
//

import Network
import Foundation

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isConnected: Bool = true

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let newValue = (path.status == .satisfied)
            if self.isConnected != newValue {
                self.isConnected = newValue
                NotificationCenter.default.post(name: .networkStatusChanged, object: newValue)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
    
    func isNetworkError(_ error: Error) -> Bool {
        guard let e = error as? URLError else { return false }
        switch e.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}
