import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthorizationWindow: UIViewController {
    private var isAuthorized: Bool = false {
        didSet {
            print("New auth state: \(isAuthorized)\n")
        }
    }
    
    // MARK: - UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // Glass effect
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        // Blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 24
        blurView.layer.masksToBounds = true
        view.addSubview(blurView)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let field = createTextField(placeholder: "Email")
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        return field
    }()
    
    private lazy var passwordTextField: UITextField = {
        let field = createTextField(placeholder: "Password")
        field.isSecureTextEntry = true
        return field
    }()
    
    private lazy var authButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .myRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 25
        // Glass effect for button
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        // Shadow
        button.layer.shadowColor = UIColor.myRed.withAlphaComponent(0.6).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.5
        button.addTarget(self, action: #selector(tryAuthorize), for: .touchUpInside)
        return button
    }()
    
    private lazy var dividerStack: UIStackView = {
        let leftLine = createDividerLine()
        let rightLine = createDividerLine()
        
        let orLabel = UILabel()
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        orLabel.text = "or"
        orLabel.textColor = .white.withAlphaComponent(0.7)
        orLabel.textAlignment = .center
        orLabel.font = .systemFont(ofSize: 16)
        
        let stack = UIStackView(arrangedSubviews: [leftLine, orLabel, rightLine])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    private lazy var googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        // Add Google logo image
        let googleImage = UIImageView(image: UIImage(named: "google_logo"))
        googleImage.translatesAutoresizingMaskIntoConstraints = false
        googleImage.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign in with Google"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        button.addSubview(googleImage)
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            googleImage.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 20),
            googleImage.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            googleImage.heightAnchor.constraint(equalToConstant: 24),
            googleImage.widthAnchor.constraint(equalToConstant: 24),
            
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }()
    
    private lazy var signUpStack: UIStackView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Don't have an account?"
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 14)
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.myRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    private lazy var glowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .myRed.withAlphaComponent(0.2)
        view.layer.cornerRadius = 100
        view.alpha = 0.6
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.backgroundColor = .black
        
        // Add a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add glow effect
        view.addSubview(glowView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(authButton)
        containerView.addSubview(dividerStack)
        containerView.addSubview(googleSignInButton)
        view.addSubview(signUpStack)
        
        // Add animated background particles
        addBackgroundParticles()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Glow view
            glowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glowView.topAnchor.constraint(equalTo: view.topAnchor, constant: -50),
            glowView.widthAnchor.constraint(equalToConstant: 200),
            glowView.heightAnchor.constraint(equalToConstant: 200),
            
            // Container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 440),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Email field
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 55),
            
            // Password field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 55),
            
            // Auth button
            authButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            authButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            authButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            authButton.heightAnchor.constraint(equalToConstant: 55),
            
            // Divider
            dividerStack.topAnchor.constraint(equalTo: authButton.bottomAnchor, constant: 30),
            dividerStack.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            dividerStack.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            // Google sign in button
            googleSignInButton.topAnchor.constraint(equalTo: dividerStack.bottomAnchor, constant: 30),
            googleSignInButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            googleSignInButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 55),
            googleSignInButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            
            // Sign up stack
            signUpStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpStack.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24)
        ])
    }
    
    // MARK: - Helper Methods
    private func createTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = placeholder
        field.textColor = .white
        // Glass effect for text field
        field.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        field.layer.cornerRadius = 12
        field.clipsToBounds = true
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        
        // Add left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: field.frame.height))
        field.leftView = paddingView
        field.leftViewMode = .always
        
        return field
    }
    
    private func createDividerLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    
    private func addBackgroundParticles() {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -100)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 20
        cell.velocity = 50
        cell.velocityRange = 20
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.1
        cell.scaleRange = 0.1
        cell.alphaRange = 0.5
        cell.alphaSpeed = -0.1
        
        // Create a circular particle
        let size = 20.0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.white.cgColor)
            context.addEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
            context.fillPath()
        }
        cell.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        
        particleEmitter.emitterCells = [cell]
        view.layer.addSublayer(particleEmitter)
    }
    
    // MARK: - Animation Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateGlowView()
    }
    
    private func animateGlowView() {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.glowView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.glowView.alpha = 0.4
        })
    }
    
    // MARK: - Actions
    @objc private func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Show loading indicator
        showLoadingIndicator()
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            // Hide loading indicator
            hideLoadingIndicator()
            
            guard error == nil else {
                showAlert(title: "Error", message: "Could not sign in with Google: \(error!.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                showAlert(title: "Error", message: "No user data received")
                return
            }

            let email = user.profile?.email
            let userID = user.userID
            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName

            // Save user info
            saveUserInfo(email: email, userID: userID, fullName: fullName,
                        givenName: givenName, familyName: familyName)

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                          accessToken: user.accessToken.tokenString)

            // Authenticate with Firebase
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Authentication Error", message: error.localizedDescription)
                    return
                }
                
                self.getAccesAfterAuthorization()
            }
        }
    }
    
    private func saveUserInfo(email: String?, userID: String?, fullName: String?,
                             givenName: String?, familyName: String?) {
        if let email = email {
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
        if let userId = userID {
            UserDefaults.standard.set(userId, forKey: "userID")
        }
        if let fullName = fullName {
            UserDefaults.standard.set(fullName, forKey: "fullName")
        }
        if let givenName = givenName {
            UserDefaults.standard.set(givenName, forKey: "givenName")
        }
        if let familyName = familyName {
            UserDefaults.standard.set(familyName, forKey: "familyName")
        }
    }
    
    private func getAccesAfterAuthorization() {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? UUID().uuidString
        
        isAuthorized = true
        
        // Show success animation
        showSuccessAnimation { [weak self] in
            guard let self = self else { return }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.setRootViewController(RootTabBarVC())
            }
            
            // Establish WebSocket connection
            WebSocketManager.shared.connect(userID: userID)
        }
    }
    
    @objc private func tryAuthorize() {
        // Button press animation
        UIView.animate(withDuration: 0.1, animations: {
            self.authButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.authButton.transform = CGAffineTransform.identity
            }
        }
        
        // Show loading indicator
        showLoadingIndicator()
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            
            guard let email = self.emailTextField.text, !email.isEmpty,
                  let password = self.passwordTextField.text, !password.isEmpty else {
                self.showAlert(title: "Error", message: "Please enter both email and password")
                return
            }
            
            // Here you would typically authenticate with your backend
            // For demo purposes, we're just setting a user ID
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set(UUID().uuidString, forKey: "userID")
            UserDefaults.standard.set(email.components(separatedBy: "@").first, forKey: "fullName")
            
            self.getAccesAfterAuthorization()
        }
    }
    
    // MARK: - UI Helpers
    private func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tag = 999
        activityIndicator.center = view.center
        activityIndicator.color = .myRed
        activityIndicator.startAnimating()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.tag = 888
        blurView.alpha = 0
        
        view.addSubview(blurView)
        view.addSubview(activityIndicator)
        
        UIView.animate(withDuration: 0.3) {
            blurView.alpha = 0.7
        }
    }
    
    private func hideLoadingIndicator() {
        if let blurView = view.viewWithTag(888) {
            UIView.animate(withDuration: 0.3, animations: {
                blurView.alpha = 0
            }) { _ in
                blurView.removeFromSuperview()
            }
        }
        
        if let activityIndicator = view.viewWithTag(999) {
            activityIndicator.removeFromSuperview()
        }
    }
    
    private func showSuccessAnimation(completion: @escaping () -> Void) {
        // Create checkmark animation here
        let checkmarkSize: CGFloat = 100
        let circleLayer = CAShapeLayer()
        let checkmarkLayer = CAShapeLayer()
        
        // Circle
        let circlePath = UIBezierPath(arcCenter: view.center,
                                    radius: checkmarkSize/2,
                                    startAngle: 0,
                                    endAngle: CGFloat.pi * 2,
                                    clockwise: true)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.myRed.cgColor
        circleLayer.lineWidth = 5
        
        // Checkmark
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: view.center.x - checkmarkSize/4, y: view.center.y))
        checkmarkPath.addLine(to: CGPoint(x: view.center.x, y: view.center.y + checkmarkSize/4))
        checkmarkPath.addLine(to: CGPoint(x: view.center.x + checkmarkSize/3, y: view.center.y - checkmarkSize/4))
        
        checkmarkLayer.path = checkmarkPath.cgPath
        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.strokeColor = UIColor.white.cgColor
        checkmarkLayer.lineWidth = 5
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        
        // Add to view
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.tag = 777
        blurView.alpha = 0
        
        view.addSubview(blurView)
        view.layer.addSublayer(circleLayer)
        view.layer.addSublayer(checkmarkLayer)
        
        UIView.animate(withDuration: 0.3) {
            blurView.alpha = 0.7
        }
        
        // Animate
        let circleAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circleAnimation.duration = 0.6
        circleAnimation.fromValue = 0
        circleAnimation.toValue = 1
        circleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        circleLayer.strokeEnd = 1
        circleLayer.add(circleAnimation, forKey: "circleAnimation")
        
        let checkmarkAnimation = CABasicAnimation(keyPath: "strokeEnd")
        checkmarkAnimation.duration = 0.6
        checkmarkAnimation.fromValue = 0
        checkmarkAnimation.toValue = 1
        checkmarkAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        checkmarkAnimation.beginTime = CACurrentMediaTime() + 0.6
        checkmarkLayer.strokeEnd = 1
        checkmarkLayer.add(checkmarkAnimation, forKey: "checkmarkAnimation")
        
        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            circleLayer.removeFromSuperlayer()
            checkmarkLayer.removeFromSuperlayer()
            if let blurView = self.view.viewWithTag(777) {
                UIView.animate(withDuration: 0.3, animations: {
                    blurView.alpha = 0
                }) { _ in
                    blurView.removeFromSuperview()
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
