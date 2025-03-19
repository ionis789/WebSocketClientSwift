//
//  ChatsListVC.swift
//  WebSocket
//
//  Created by Ion Socol on 3/15/25.
//

import Foundation
import UIKit
class ChatsListVC: UIViewController {

    //MARK: Chat List Table View Setup
    private lazy var chatsListTableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.register(ChatCellView.self, forCellReuseIdentifier: "chatCell")
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 80
        v.backgroundColor = .black
        v.separatorColor = .gray
        v.tableFooterView = UIView()
        return v
    }()
    private lazy var chats: [Chat] = [Chat(messages: [], otherUserName: "Putin", otherUserImage: UIImage(named: "defaultProfilePicture")!, otherUserStatus: true),Chat(messages: [], otherUserName: "Trump", otherUserImage: UIImage(named: "defaultProfilePicture")!, otherUserStatus: true),Chat(messages: [], otherUserName: "Baiden", otherUserImage: UIImage(named: "defaultProfilePicture")!, otherUserStatus: true)]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setupViews()
    }
    //MARK: Custom header for Chats List
    private func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = "Chats"
        titleLabel.textColor = .myRed
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])

        return headerView
    }

    private func setupViews() {
        //MARK: Setup Views
        [chatsListTableView].forEach { view.addSubview($0) }
        chatsListTableView.delegate = self
        chatsListTableView.dataSource = self
        //MARK: Chats Header Setup
        chatsListTableView.tableHeaderView = createTableHeader()
        chatsListTableView.contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
        
        //MARK: Line Separator Customization
        chatsListTableView.separatorInset = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 0)
        setupConstarints()
    }

    private func setupConstarints() {
        NSLayoutConstraint.activate([
            chatsListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatsListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatsListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatsListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension ChatsListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatsListTableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCellView else { return UITableViewCell() }
        cell.chat = chats[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
