//
//  RegisterViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-01.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    var loadingAlert:LoadingAlert?
    private var oldCenter:CGPoint?
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBAction func registerBtn(_ sender: UIButton) {
        register()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldCenter = view.center
        setUpNavigationBar()
        setUpTextfieldDelegates()
        setLoadingState(isLoading: false)
    }

}

// MARK: - SetUp
extension RegisterViewController {
    private func setUpTextfieldDelegates() {
        usernameTextField.delegate = self
        password1TextField.delegate = self
        password2TextField.delegate = self
    }
    
    private func setUpNavigationBar() {
        navigationItem.title = "Register"
        navigationController?.navigationBar.isHidden = false
    }
}


// MARK: - Register
extension RegisterViewController {
    private func moveToUserView(with user: User) {
        guard let homeTabBarController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.homeTabBarControllerID) as? UITabBarController else { return }
        
        present(homeTabBarController, animated: true, completion: nil)
        
        guard let navigationController = homeTabBarController.viewControllers?.first as? UINavigationController,
            let userViewController = navigationController.viewControllers.first as? UserViewController else {return}
        userViewController.user = user
        userViewController.belongsToActiveUser = true
    }
    
    private func register() {
        
        if password1TextField.text != password2TextField.text {
            showDifferentPasswordAlert()
            return
        }
        
        if let username = usernameTextField.text, let password = password1TextField.text, username != "", password != "" {
            
            if username.containsInvalidCharacters {
                showInvalidCharactersAlert()
                return
            }
            setLoadingState(isLoading: true)
            Authentication.registerUser(username: username, password: password) { (user,error)  in
                if let user = user, error == nil {
                    // successfully created a new user
                    User.activeUser = user
                    User.activeUserPassword = password
                    Keychain.saveActiveUser(password: password)
                    DispatchQueue.main.async {
                        self.moveToUserView(with: user)
                    }
                } else {
                    // something went wrong
                    DispatchQueue.main.async {
                        self.setLoadingState(isLoading: false)
                        if error == RegisterError.UsernameTaken {
                            self.showNotAvailableUsernameAlert()
                        } else {
                            self.showCheckInternetAlert()
                        }
                    }
                }
            }
        } else {
            showInvalidInputAlert()
        }
    }
}


extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            password1TextField.becomeFirstResponder()
        case password1TextField:
            password2TextField.becomeFirstResponder()
        default:
            view.endEditing(true)
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}


// MARK: - Alerts
extension RegisterViewController: LoadingAlertDelegate {
    
    func didCancel() {
        setLoadingState(isLoading: false)
    }
    
    private func stopLoading() {
        if let loadingAlert = loadingAlert {
            loadingAlert.removeFromSuperview()
            self.loadingAlert = nil
        }
        Authentication.cancelRegisterTask()
    }
    
    private func setLoadingState(isLoading: Bool) {
        // if visible
        if self.isViewLoaded, self.view.window != nil {
            registerBtn.isEnabled = !isLoading
            usernameTextField.isEnabled = !isLoading
            password1TextField.isEnabled = !isLoading
            password2TextField.isEnabled = !isLoading
            
            if isLoading {
                showLoadingAlert()
            } else {
                stopLoading()
            }
        }
    }
    
    private func showLoadingAlert() {
        let loadingAlert = LoadingAlert(frame: CGRect(x: view.center.x - 125, y: view.center.y - 100, width: 250, height: 150))
        loadingAlert.delegate = self
        self.loadingAlert = loadingAlert
        self.view.addSubview(loadingAlert)
    }
    
}


extension RegisterViewController {
    
    private func showDifferentPasswordAlert() {
        let alert = Alerts.createSimpleAlert(title: "Passwords Not Matching", message: "", cancelTitle: "OK")
        present(alert, animated: true, completion: nil)
    }
    
    private func showInvalidCharactersAlert() {
        let alert = Alerts.createSimpleAlert(title: "Invalid Characters", message: "You're Username can only contain letters A-Z", cancelTitle: "OK")
        present(alert, animated: true, completion: nil)
    }
    
    private func showInvalidInputAlert() {
        let alert = Alerts.createSimpleAlert(title: "Invalid Input", message: "You need to input a username and a password", cancelTitle: "OK")
        present(alert, animated: true, completion: nil)
    }
    
    private func showNotAvailableUsernameAlert() {
        let alert = Alerts.createSimpleAlert(title: "Username is already taken", message: "", cancelTitle: "OK")
        present(alert, animated: true, completion: nil)
    }
    
    private func showCheckInternetAlert() {
        let alert = Alerts.createSimpleAlert(title: "No response", message: "Check your internet connection", cancelTitle: "OK")
        present(alert, animated: true, completion: nil)
    }
}
