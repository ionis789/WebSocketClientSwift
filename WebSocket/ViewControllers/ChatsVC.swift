import UIKit

class ChatsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketManagerDelegate {

    private var messages: [String] = []
    private var username: String? // This is never initialized in your original code

    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        v.dataSource = self
        v.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return v
    }()

    private lazy var messageTextField: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .darkGray
        v.layer.cornerRadius = 8
        v.placeholder = "Enter message"
        v.borderStyle = .roundedRect
        return v
    }()

    private lazy var sendButton: UIButton = {
        let v = UIButton(type: .system)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("Send", for: .normal)
        v.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setupViews()

        // Get username from UserDefaults and connect to WebSocket
        self.username = UserDefaults.standard.string(forKey: "userID") ?? "Guest"
        WebSocketManager.shared.delegate = self
        WebSocketManager.shared.connect(userID: self.username)
    }

    private func setupViews() {
        [messageTextField, sendButton, tableView].forEach { view.addSubview($0) }
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            messageTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            messageTextField.widthAnchor.constraint(equalToConstant: 250),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 10),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 40),


            tableView.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])
    }

    @objc private func sendMessage() {
        guard let message = messageTextField.text, !message.isEmpty else { return }
        // Send just the content - the WebSocketManager will format it properly
        WebSocketManager.shared.sendMessage(message)
        messageTextField.text = ""
        self.view.endEditing(true)
    }

    //MARK: GET NEW MESSAGE DELEGATE
    func didReceiveMessage(_ message: String) {
        DispatchQueue.main.async {
            self.messages.append(message)
            self.tableView.reloadData()
            self.scrollToBottom()
            
            if let username = UserDefaults.standard.string(forKey: "userID") {
                if message.contains(username) {
                    print("This meesage is written by logged User")
                } else {
                    print("This meesage is not written by logged User")
                }
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
            alert.addAction(UIAlertAction(title: "Reconnect", style: .default) { _ in
                WebSocketManager.shared.connect(userID: self.username)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }

    private func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .myRed
        return cell
    }
}
