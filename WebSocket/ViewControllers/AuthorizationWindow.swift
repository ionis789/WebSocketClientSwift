//
//  AuthorizationWindow.swift
//  WebSocket
//
//  Created by Ion Socol on 2/14/25.
//

import UIKit

class AuthorizationWindow: UIViewController {
    private var isAuthorized: Bool = false {
        didSet {
            print("Old auth value: \(oldValue)\nNew auth value: \(isAuthorized)")
        }
    }

    private lazy var authButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("Authorize", for: .normal)
        v.tintColor = .myRed
        v.addTarget(self, action: #selector(tryAuthorize), for: .touchUpInside)
        return v
    }()

    private lazy var usernameTextField: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.placeholder = "Enter username"
        return v
    }()

    private lazy var emalTextField: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.placeholder = "Enter email"
        return v
    }()

    private lazy var passwordTextField: UITextField = {
        let v = UITextField()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.placeholder = "Enter password"
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = .black
        [authButton, usernameTextField, emalTextField, passwordTextField].forEach(view.addSubview)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([


            //Username textfield
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            usernameTextField.heightAnchor.constraint(equalToConstant: 52),
            usernameTextField.widthAnchor.constraint(lessThanOrEqualToConstant: 150),

            //Email textfield
            emalTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emalTextField.centerYAnchor.constraint(equalTo: usernameTextField.centerYAnchor, constant: 50),
            emalTextField.heightAnchor.constraint(equalToConstant: 52),
            emalTextField.widthAnchor.constraint(lessThanOrEqualToConstant: 150),

            //Password textfield
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.centerYAnchor.constraint(equalTo: emalTextField.centerYAnchor, constant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 52),
            passwordTextField.widthAnchor.constraint(lessThanOrEqualToConstant: 150),

            //Auth button
            authButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor, constant: 100),
            authButton.heightAnchor.constraint(equalToConstant: 52),
            authButton.widthAnchor.constraint(lessThanOrEqualToConstant: 150)
        ])
    }

    @objc private func tryAuthorize() {

        //Establish websocket connection

        guard let user = usernameTextField.text, !user.isEmpty else {
            showAuthorizationError()
            return
        }

        isAuthorized = true
        UserDefaults.standard.set(true, forKey: "isAuthorized") // Save authorization state
        UserDefaults.standard.set(user, forKey: "userID") // Save userID info

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.setRootViewController(RootTabBarVC())
        }

        WebSocketManager.shared.connect(userID: user)

    }
    
    private func showAuthorizationError() {
        let alertController = UIAlertController(title: "Error", message: "Please enter a username", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}
        
