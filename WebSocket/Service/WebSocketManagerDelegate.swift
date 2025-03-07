import Foundation

protocol WebSocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
    func didDisconnect()
}

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketManager()
    
    private var userID: String?
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 2.0
    weak var delegate: WebSocketManagerDelegate?
    
    // Updated URL endpoint to match Spring Boot's SockJS endpoint
    // Using the raw WebSocket endpoint that SockJS exposes
    private let serverURL = URL(string: "ws://127.0.0.1:8080/ws/websocket")!
    
    private override init() {
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect(userID: String?) {
        guard !isConnected else { return }
        self.userID = userID ?? "unknown"
        webSocket = session?.webSocketTask(with: serverURL)
        webSocket?.resume()
        isConnected = true
        
        // Send STOMP connect frame
        sendStompConnect()
        
        // Subscribe to the public topic
        sendStompSubscribe()
        
        // Send join message
        connectUser()
        
        receiveMessage()
    }
    
    private func sendStompConnect() {
        let connectFrame = """
        CONNECT
        accept-version:1.1,1.2
        heart-beat:10000,10000
        
        \u{0}
        """
        sendRawMessage(connectFrame)
    }
    
    private func sendStompSubscribe() {
        let subscribeFrame = """
        SUBSCRIBE
        id:sub-0
        destination:/topic/public
        
        \u{0}
        """
        sendRawMessage(subscribeFrame)
    }
    
    private func connectUser() {
        guard let userID = self.userID else { return }
        let joinMessage = """
        SEND
        destination:/app/chat.addUser
        content-type:application/json
        
        {"type":"JOIN","sender":"\(userID)","content":null}
        \u{0}
        """
        sendRawMessage(joinMessage)
    }
    
    func sendMessage(_ content: String) {
        guard let userID = self.userID else { return }
        // Fixed the format to match what the server expects
        let messageFrame = """
        SEND
        destination:/app/chat.sendMessage
        content-type:application/json
        
        {"type":"CHAT","content":"\(content)","sender":"\(userID)"}
        \u{0}
        """
        sendRawMessage(messageFrame)
    }
    
    private func sendRawMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocket?.send(message) { error in
            if let error = error {
                print("Send error: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    // Parse STOMP message
                    self?.handleStompMessage(text)
                case .data(_):
                    break
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("Receive error: \(error)")
                self?.attemptReconnect()
            }
        }
    }
    
    private func handleStompMessage(_ message: String) {
        // Improved STOMP message parser
        print("Received: \(message)") // Debug logging
        
        // Handle CONNECTED frame
        if message.hasPrefix("CONNECTED") {
            print("Successfully connected to STOMP broker")
            return
        }
        
        // Handle MESSAGE frame
        if message.hasPrefix("MESSAGE") {
            // Find the body which comes after a blank line
            let components = message.components(separatedBy: "\n\n")
            if components.count >= 2 {
                let body = components[1].replacingOccurrences(of: "\u{0}", with: "")
                
                // Parse JSON message
                if let data = body.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // Extract message data based on the expected format
                    let type = json["type"] as? String
                    let sender = json["sender"] as? String ?? "Unknown"
                    let content = json["content"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        if type == "JOIN" {
                            self.delegate?.didReceiveMessage("\(sender) joined the chat")
                        } else if type == "LEAVE" {
                            self.delegate?.didReceiveMessage("\(sender) left the chat")
                        } else {
                            self.delegate?.didReceiveMessage("\(sender): \(content)")
                        }
                    }
                }
            }
        }
    }
    
    func disconnect() {
        let disconnectFrame = """
        DISCONNECT
        
        \u{0}
        """
        sendRawMessage(disconnectFrame)
        webSocket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
    
    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnect attempts reached")
            DispatchQueue.main.async {
                self.delegate?.didDisconnect()
            }
            return
        }
        
        reconnectAttempts += 1
        isConnected = false
        
        DispatchQueue.global().asyncAfter(deadline: .now() + reconnectDelay) {
            print("Reconnecting... Attempt \(self.reconnectAttempts)")
            self.connect(userID: self.userID ?? "unknown")
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket closed: \(closeCode)")
        isConnected = false
        attemptReconnect()
    }
}
