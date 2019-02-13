//
//  PostViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-10.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var postImageView: UIImageView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImagePicker))
            postImageView.isUserInteractionEnabled = true
            postImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    
    @IBAction func postBtn(_ sender: UIButton) {
        post()
    }
    
    @IBOutlet weak var postBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
    }
    
    
}

// MARK: - Post
extension PostViewController {
    private func showIfSuccessfullyPostedAlert(success: Bool) {
        
        if success {
            resetPostView()
        }
        
        let title = success ? "Successfully uploaded your post" : "Something went wrong"
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        toggleUpdateState(updating: false)
    }
    
    private func post() {
        if postImageView.image == UIImage(named: ImageConstants.chooseAnImagePlaceholderId) {
            showIfSuccessfullyPostedAlert(success: false)
            return
        }
        if let postImage = postImageView.image, let description = descriptionTextView.text {
            toggleUpdateState(updating: true)
            Post.uploadPost(description: description, postImage: postImage) { (postedPost) in
                DispatchQueue.main.async {
                    self.showIfSuccessfullyPostedAlert(success:  (postedPost != nil) ? true: false)
                }
            }
        }
    }
}

// MARK: - SetUp
extension PostViewController {
    private func setUpDelegates() {
        descriptionTextView.delegate = self
    }
    
    private func toggleUpdateState(updating: Bool) {
        postImageView.alpha = updating ? 0.5 : 1
        descriptionTextView.alpha = updating ? 0.5 : 1
        postBtn.alpha = updating ? 0.5 : 1
    }
    
    
    private func resetPostView() {
        postImageView.image = UIImage(named: ImageConstants.chooseAnImagePlaceholderId)
        descriptionTextView.text = "Description"
    }
}

// MARK: - UITextViewDelegate
extension PostViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.text = ""
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}


// MARK: - UIImagePickerControllerDelegate
extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let postImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            presentCropImageViewController(image: postImage)
        }
    }
    
}


// MARK: - CropImageViewControllerDelegate
extension PostViewController: CropImageViewControllerDelegate {
    
    func didChooseImage(chosenImage: UIImage) {
        postImageView.image = chosenImage
    }
    
    func presentCropImageViewController(image: UIImage) {
        let cropImageViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.cropImageViewControllerID) as! CropImageViewController
        cropImageViewController.imageToDisplay = image
        cropImageViewController.isRound = false
        cropImageViewController.delegate = self
        present(cropImageViewController, animated: true, completion: nil)
    }
    
    
}
