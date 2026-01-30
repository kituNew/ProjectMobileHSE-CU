//
//  WebSocketClient.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.01.2026.
//

import Foundation

final class WebSocketClient: NSObject {
    private var task: URLSessionWebSocketTask?

    private(set) var isConnected = false

    var onText: ((String) -> Void)?
    var onData: ((Data) -> Void)?
    var onStateChange: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?

    func connect(url: String, headers: [String: String] = [:]) {
        guard let url = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        let task = URLSession.shared.webSocketTask(with: request)
        self.task = task
        task.resume()

        listen()

        startPing()
    }

    func disconnect() {
        isConnected = false
        onStateChange?(false)

        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    func send(text: String) {
        task?.send(.string(text)) { [weak self] error in
            if let error { self?.onError?(error) }
        }
    }

    func send(data: Data) {
        task?.send(.data(data)) { [weak self] error in
            if let error { self?.onError?(error) }
        }
    }

    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                self.onError?(error)
                self.isConnected = false
                self.onStateChange?(false)

            case .success(let message):
                switch message {
                case .string(let text):
                    self.onText?(text)
                case .data(let data):
                    self.onData?(data)
                @unknown default:
                    break
                }

                // важно: слушаем дальше (рекурсивный receive loop)
                self.listen()
            }
        }
    }

    private func startPing(interval: TimeInterval = 15) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.task?.sendPing { error in
                if let error { self?.onError?(error) }
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        isConnected = true
        onStateChange?(true)
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        isConnected = false
        onStateChange?(false)
    }
}
