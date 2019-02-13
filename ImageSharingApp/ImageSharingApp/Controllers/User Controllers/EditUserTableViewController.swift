//
//  EditUserTableViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-07.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

class EditUserTableViewController: UITableViewController {
    
    var hasChangedProfilePic = false
    var hasChangedProfileInfo = false
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var profilePicRoundImageView: RoundUIImageView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
            profilePicRoundImageView.addGestureRecognizer(tapRecognizer)
            profilePicRoundImageView.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
}

// MARK: - UITextFieldDelegate, UITextViewDelegate
extension EditUserTableViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hasChangedProfileInfo = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        hasChangedProfileInfo = true
    }
    
}

// MARK: - Logout
extension EditUserTableViewController{
    
    private func logout() {
        User.activeUser = nil
        User.activeUserPassword = nil
        Keychain.deleteActiveUserProperties()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            logout()
        }
    }
}


// setup
extension EditUserTableViewController {
    private func setUpDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        bioTextView.delegate = self
    }
    
    private func setUp() {
        setUpNavigationBar()
        setUpUserElements()
        setUpDelegates()
    }
    
    private func setUpUserElements() {
        profilePicRoundImageView.image = User.activeUser?.profileImage
        firstNameTextField.text = User.activeUser?.firstname
        lastNameTextField.text = User.activeUser?.lastname
        bioTextView.text = User.activeUser?.bio
    }
    
    private func setUpNavigationBar() {
        navigationItem.title = "Edit"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }
}

// MARK: - Save
extension EditUserTableViewController {
    
    @objc private func save() {
        if hasChangedProfilePic, let user = User.activeUser, let password = User.activeUserPassword {
            saveProfilePicture(user: user, password: password) { (imageSuccess) in
                if imageSuccess && self.hasChangedProfileInfo {
                    self.saveProfileInfo {
                        self.pop()
                    }
                } else {
                    self.pop()
                }
            }
        } else if hasChangedProfileInfo {
            self.saveProfileInfo {
                self.pop()
            }
        }
    }
    
    private func saveProfileInfo(completion: @escaping () -> () ) {
        
        if let activeUser = User.activeUser, let password = User.activeUserPassword {
            activeUser.firstname = firstNameTextField.text ?? ""
            activeUser.lastname = lastNameTextField.text ?? ""
            activeUser.bio = bioTextView.text
            
            toggleUpdateState(updating: true)
            activeUser.updateProfile(password: password) { (updatedActiveUser) in
                if let updatedActiveUser = updatedActiveUser {
                    //success
                    User.activeUser = updatedActiveUser
                    completion()
                } else {
                    // TODO error
                }
            }
        } else {
            // TODO: failed to update
        }
    }
    
    
    private func saveProfilePicture(user: User, password: String, completion: @escaping (_ success: Bool) ->() ) {
        if let profileImage = profilePicRoundImageView.image {
            toggleUpdateState(updating: true)
            user.setProfilePicture(profilePicture: profileImage, password: password) { (updatedUser) in
                if updatedUser != nil {
                    // success
                    User.activeUser = updatedUser
                    User.activeUser?.profileImage = nil
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}

// MARK: - ProfileImage
extension EditUserTableViewController: CropImageViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func didChooseImage(chosenImage: UIImage) {
        profilePicRoundImageView.image = chosenImage
        hasChangedProfilePic = true
    }
    
    private func showImagePicker() {
        let profileImagePicker = UIImagePickerController()
        profileImagePicker.delegate = self
        profileImagePicker.sourceType = .photoLibrary
        present(profileImagePicker, animated: true, completion: nil)
    }
    
    @objc private func changeProfileImage() {
        showImagePicker()
    }
    
    private func cropImage(image: UIImage) {
        let cropImageViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.cropImageViewControllerID) as! CropImageViewController
        cropImageViewController.imageToDisplay = image
        cropImageViewController.delegate = self

        present(cropImageViewController, animated: true, completion: nil)
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newProfilePic = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            cropImage(image: newProfilePic)
        }
    }
}

// MARK: - Utils
extension EditUserTableViewController {
    private func pop() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func toggleUpdateState(updating: Bool) {
        DispatchQueue.main.async {
            self.tableView.alpha = updating ? 0.5 : 1
        }
    }
}
