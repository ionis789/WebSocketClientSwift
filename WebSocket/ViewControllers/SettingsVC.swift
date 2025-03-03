//
//  SettingsVC.swift
//  WebSocket
//
//  Created by Ion Socol on 2/4/25.
//

import UIKit
class SettingsVC: UIViewController {
    private lazy var logoutButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("Logout", for: .normal)
        v.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return v
    }()

    private lazy var userNameLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textColor = .white
        v.font = .systemFont(ofSize: 20, weight: .bold)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        guard let user = UserDefaults.standard.string(forKey: "userID"), !user.isEmpty else {
            let user = "Unknown user"
            print(user)
            showErrorAlert(title: "Who are you?", message: "You need to login first!")
            return
        }
        userNameLabel.text = user
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = .black
        [logoutButton, userNameLabel].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            userNameLabel.heightAnchor.constraint(equalToConstant: 52),
            userNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),


            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.widthAnchor.constraint(equalToConstant: 150),
        ])
    }

    private func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dissmissAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let tabBarVC = self.tabBarController as? RootTabBarVC {
                tabBarVC.selectedIndex = 0
            }

            self.dismiss(animated: true) { [weak self] in
                self?.removeFromParent()
            }
        }
        alertController.addAction(dissmissAction)
        present(alertController, animated: true)
    }

    @objc private func logout() {
        // Remove the keys completely instead of setting them to default values
        UserDefaults.standard.removeObject(forKey: "isAuthorized")
        UserDefaults.standard.removeObject(forKey: "userID")
        
        // Synchronize to ensure changes are saved immediately
        UserDefaults.standard.synchronize()
        
        // Disconnect from WebSocket
        WebSocketManager.shared.disconnect()
        
        // Navigate back to authorization screen
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.setRootViewController(AuthorizationWindow())
        }
    }

}
