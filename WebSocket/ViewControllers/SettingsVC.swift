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
        v.font = .systemFont(ofSize: 18, weight: .bold)
        return v
    }()

    private lazy var profilePicture: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        if let imagePath = UserDefaults.standard.string(forKey: "profilePicturePath"),
            let image = UIImage(contentsOfFile: imagePath) {
            v.image = image
        } else {
            v.image = UIImage(named: "defaultProfilePicture")
        }
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 62
        //MARK: Profile UITapGestureRecognizer
        v.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        v.addGestureRecognizer(tapGesture)
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
        [logoutButton, userNameLabel, profilePicture].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: 52),
            userNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),


            profilePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePicture.bottomAnchor.constraint(equalTo: userNameLabel.topAnchor, constant: -20),
            profilePicture.widthAnchor.constraint(equalToConstant: 124),
            profilePicture.heightAnchor.constraint(equalToConstant: 124),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 20),
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
        UserDefaults.standard.removeObject(forKey: "profilePicturePath")

        // Synchronize to ensure changes are saved immediately
        UserDefaults.standard.synchronize()

        // Disconnect from WebSocket
        WebSocketManager.shared.disconnect()

        // Navigate back to authorization screen
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.setRootViewController(AuthorizationWindow())
        }
    }

    private func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        return imagePickerController
    }

    private func showImagePickerOptions() {
        let alertVC = UIAlertController(title: "Pick a Picture", message: "Choose a picture from library or take a new one", preferredStyle: .actionSheet)


        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] action in
            guard let self = self else { return }
            let librayImagePicker = self.imagePicker(sourceType: .photoLibrary)
            librayImagePicker.delegate = self
            self.present(librayImagePicker, animated: true) {
                // TO DO
                print("Library opened")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }

    private func saveProfileImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileManager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("profile.jpg")
        try? data .write(to: fileManager)
        UserDefaults.standard.set(fileManager.path, forKey: "profilePicturePath")

    }

    @objc private func didTapProfilePicture() {
        showImagePickerOptions()
        print("Tapped on profile picture!")
    }

}

extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as! UIImage
        
        saveProfileImage(image)
        
        if let imagePath = UserDefaults.standard.string(forKey: "profilePicturePath"), let profileImage = UIImage(contentsOfFile: imagePath) {
            self.profilePicture.image = profileImage
            self.profilePicture.contentMode = .scaleAspectFill
            self.profilePicture.clipsToBounds = true
            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.height / 2
            self.dismiss(animated: true, completion: nil)
        } else { return }

    }
}
