import UIKit
import MessageKit
import InputBarAccessoryView

class CurrentChatVC: MessagesViewController, WebSocketManagerDelegate {

    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black

        // Websocket connection
        guard let fullName = UserDefaults.standard.string(forKey: "fullName") else { return }
        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
        WebSocketManager.shared.delegate = self
        WebSocketManager.shared.connect(userID: userID)

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self

        configureMessageInputBar()
        // Close keyboard event
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false // Allow touches on messages
        messagesCollectionView.addGestureRecognizer(tapGesture)
    }
    @objc private func handleTap() {
        view.endEditing(true) // close keyboard
    }


    private func configureMessageInputBar() {

        messageInputBar.delegate = self

        // Personalizare MessageInputBar
        messageInputBar.inputTextView.placeholder = "Enter message"
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.backgroundColor = .darkGray
        messageInputBar.inputTextView.textColor = .white

        // Personalizează butonul de trimitere
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        messageInputBar.sendButton.setTitleColor(.systemGray, for: .disabled)

        // Opțional: Adaugă padding pentru a păstra un aspect mai plăcut
        messageInputBar.padding.bottom = 8
        messageInputBar.padding.top = 8
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // Afișează MessageInputBar
        reloadInputViews()
    }

    //MARK: GET New Message Event
    func didReceiveMessage(_ message: String) {
        DispatchQueue.main.async {

            if let sender = message.components(separatedBy: ":").first {
                print(sender) // Sender name

                let messageContent = message.replacingOccurrences(of: "\(sender): ", with: "")
                let newMessage = Message(
                    sender: Sender(senderId: sender, displayName: sender),
                    messageId: UUID().uuidString,
                    sentDate: Date(),
                    kind: .text(messageContent)
                )
                self.messages.append(newMessage)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    func didDisconnect() {
        print("WebSocket disconnected")
        // Show an alert or notification to the user
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Disconnected",
                message: "Connection to chat server lost",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Try To Reconnect?", style: .default) { _ in
                WebSocketManager.shared.connect(userID: UserDefaults.standard.string(forKey: "userID")!)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
}

extension CurrentChatVC: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    var currentSender: SenderType {
        return Sender(senderId: UserDefaults.standard.string(forKey: "userID")!, displayName: UserDefaults.standard.string(forKey: "userID")!)
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension CurrentChatVC: InputBarAccessoryViewDelegate {

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    // Did press send button event
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.isEmpty else { return }

        WebSocketManager.shared.sendMessage(text)
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
    }
}
