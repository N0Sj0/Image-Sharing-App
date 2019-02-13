//
//  CropImageViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-22.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit


protocol CropImageViewControllerDelegate {
    func didChooseImage(chosenImage: UIImage)
}


class CropImageViewController: UIViewController {
    
    
    var delegate: CropImageViewControllerDelegate?
    var imageToDisplay: UIImage?
    
    var isRound = true
    
    @IBOutlet weak var transparentImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choseBtn(_ sender: UIButton) {
        if let chosenImage = crop(), let delegate = delegate {
            delegate.didChooseImage(chosenImage: chosenImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}


extension CropImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView!
    }
}


// setup functions
extension CropImageViewController {
    
    private func setUp() {
        setUpScrollView()
        setUpImageView()
        if !isRound {
            transparentImageView.isHidden = true
        }
    }
    
   private func setUpImageView() {
        if let imageToDisplay = imageToDisplay {
        imageView.image = imageToDisplay
        imageViewWidth.constant = imageToDisplay.size.width
        imageViewHeight.constant = imageToDisplay.size.height
        let scaleWidth = scrollView.frame.size.width/imageToDisplay.size.width
        let scaleHeight = scrollView.frame.size.height/imageToDisplay.size.height
            
        let maxScale = max(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = maxScale
        scrollView.zoomScale = maxScale
        
        imageView.isUserInteractionEnabled = true
        }
    }
    
    private func setUpScrollView() {
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        
        scrollView.maximumZoomScale = 2
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.contentSize = imageView.frame.size
    }
    
}

extension CropImageViewController {
    private func crop() -> UIImage? {
        transparentImageView.isHidden = true
        let image = view.snapshot(of: scrollView.frame)
        
        return image
    }
}


extension UIView {
    func snapshot(of rect: CGRect?) -> UIImage? {
    
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = wholeImage, let rect = rect else {return nil}
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
