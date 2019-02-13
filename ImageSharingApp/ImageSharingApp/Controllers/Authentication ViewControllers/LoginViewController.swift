//
//  LoginViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-10-31.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController {
    
    var loadingAlert:LoadingAlert?
    var oldViewCenter:CGPoint?
    
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBAction func loginBtn(_ sender: UIButton) {
        login(username: nil, password: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        oldViewCenter = view.center
        navigationController?.navigationBar.isHidden = true
        setLoadingState(isLoading: false)
        setTextfieldDelegates()
        clearFields()
    }
    
}


// MARK: - Login
extension LoginViewController {
    private func moveToUserView(user: User) {
        guard let homeTabBarController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.homeTabBarControllerID) as? UITabBarController else { return }
        
        present(homeTabBarController, animated: true, completion: nil)
        
        guard let navigationController = homeTabBarController.viewControllers?.first as? UINavigationController,
            let userViewController = navigationController.viewControllers.first as? UserViewController else {return}
        userViewController.user = user
        userViewController.belongsToActiveUser = true
    }
    
    func login(username: String?, password: String?) {
        if let username = username ?? usernameTextfield.text, username != "", let password = password ?? passwordTextfield.text, password != "" {
            setLoadingState(isLoading: true)
            Authentication.login(username: username, password: password) { (user) in
                DispatchQueue.main.async {
                    self.setLoadingState(isLoading: false)
                    if let user = user {
                        self.moveToUserView(user: user)
                    } else {
                        self.showWrongPasswordOrUsernameAlert()
                    }
                }
            }
        } else {
            showInputAlert()
        }
    }
}


// MARK: - Setup
extension LoginViewController {
    
    private func setTextfieldDelegates() {
        usernameTextfield.delegate = self
        passwordTextfield.delegate = self
    }
    
    func clearFields() {
        usernameTextfield.text = nil
        passwordTextfield.text = nil
    }
    
}


// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextfield:
            passwordTextfield.becomeFirstResponder()
        default:
            stopEditing()
        }
        return true
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scroll(100)
    }
    
    private func stopEditing() {
        scroll(0)
        view.endEditing(true)
    }
    
    // Positive is up
    private func scroll(_ amountToScrollFromCenter: CGFloat) {
        if let oldViewCenter = oldViewCenter {
            UIView.animate(withDuration: 0.2) {
                self.view.center.y = oldViewCenter.y - amountToScrollFromCenter
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopEditing()
    }
    
}

// MARK: - Alert Functions
extension LoginViewController {
    
    private func showInputAlert() {
        let inputAlert = Alerts.createSimpleAlert(title: "No Input", message: "You have to enter your username and password", cancelTitle: "OK")
        present(inputAlert, animated: true, completion: nil)
    }
    
    private func showWrongPasswordOrUsernameAlert() {
        let inputAlert = Alerts.createSimpleAlert(title: "Wrong Password or Username", message: "", cancelTitle: "OK")
        present(inputAlert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: LoadingAlertDelegate {
    func didCancel() {
        setLoadingState(isLoading: false)
    }
    
    private func stopLoading() {
        if let loadingAlert = loadingAlert {
            loadingAlert.removeFromSuperview()
            self.loadingAlert = nil
        }
        Authentication.cancelLoginTask()
    }
    
    private func setLoadingState(isLoading: Bool) {
        // if visible
        if self.isViewLoaded, self.view.window != nil {
            loginBtn.isEnabled = !isLoading
            registerBtn.isEnabled = !isLoading
            backgroundImageView.alpha = isLoading ? 0.5 : 1
            usernameTextfield.isEnabled = !isLoading
            passwordTextfield.isEnabled = !isLoading
            
            if isLoading {
                showLoadingAlert()
            } else {
                stopLoading()
            }
        }
    }
    
    private func showLoadingAlert() {
        let loginAlert = LoadingAlert(frame: CGRect(x: view.center.x - 125, y: view.center.y - 100, width: 250, height: 150))
        loginAlert.delegate = self
        self.loadingAlert = loginAlert
        self.view.addSubview(loginAlert)
    }
    
}
