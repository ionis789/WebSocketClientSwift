//
//  MessageCellView.swift
//  WebSocket
//
//  Created by Ion Socol on 3/8/25.
//

import UIKit

class ChatCellView: UITableViewCell {
    var chat: Chat? {
        didSet {
            if let chat = self.chat {
                otherUserImage.image = chat.otherUserImage
                otherUserNameLabel.text = chat.otherUserName
                lastChatMessageLabel.text = "No message"
            }
        }
    }

    //MARK: Cell init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var otherUserNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 17, weight: .medium)
        l.textColor = .white
        return l
    }()
    private lazy var otherUserImage: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        v.layer.cornerRadius = 27
        return v
    }()
    private lazy var lastChatMessageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .lightGray
        l.numberOfLines = 0
        return l
    }()

    private func setupViews() {
        backgroundColor = .black
        selectionStyle = .default
        [otherUserImage, otherUserNameLabel, lastChatMessageLabel].forEach {
            contentView.addSubview($0)
        }
        // Adaugă padding la celulă prin ajustarea constantelor în constrângeri
        let horizontalPadding: CGFloat = 12
        let verticalPadding: CGFloat = 16
        let interItemSpacing: CGFloat = 12

        NSLayoutConstraint.activate([
            // Constrângeri imagine profil - cu padding la stânga
            otherUserImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            otherUserImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            otherUserImage.widthAnchor.constraint(equalToConstant: 54),
            otherUserImage.heightAnchor.constraint(equalToConstant: 54),

            // Constrângeri etichetă nume utilizator - cu padding sus
            otherUserNameLabel.leadingAnchor.constraint(equalTo: otherUserImage.trailingAnchor, constant: interItemSpacing),
            otherUserNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            otherUserNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),

            // Constrângeri etichetă ultimul mesaj - cu padding jos
            lastChatMessageLabel.leadingAnchor.constraint(equalTo: otherUserImage.trailingAnchor, constant: interItemSpacing),
            lastChatMessageLabel.topAnchor.constraint(equalTo: otherUserNameLabel.bottomAnchor, constant: 4),
            lastChatMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            lastChatMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding)
        ])
    }
}

