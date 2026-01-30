//
//  HomeViewModel.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.01.2026.
//

final class HomeViewModel {
    let webSocketClient: WebSocketClient
    
    init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
    }
    
    func connect() {
        webSocketClient.onStateChange = { connected in
            print("Connected:", connected)
        }

        webSocketClient.onText = { text in
            print("Got text:", text)
        }

        webSocketClient.onError = { error in
            print("WS error:", error)
        }

        webSocketClient.connect(url: "wss://echo.websocket.org")

        webSocketClient.send(text: #"{"type":"hello"}"#)
    }
}
