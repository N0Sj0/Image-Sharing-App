//
//  LoadingAlert.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-31.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import UIKit
import JTMaterialSpinner


protocol LoadingAlertDelegate {
    func didCancel()
}


class LoadingAlert: UIView {

    var delegate: LoadingAlertDelegate?
    
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        // TODO: - other image
        let backgroundImageView = createBackgroundImageView()
        
        let spinner = createSpinner()
        
        let cancelBtn = createCancelBtn()
        
        self.addSubview(backgroundImageView)
        self.addSubview(cancelBtn)
        self.addSubview(spinner)
        spinner.beginRefreshing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func cancelBtnClick() {
        if let delegate = delegate {
            delegate.didCancel()
        }
    }
    
}


// functions to create parts of alert
extension LoadingAlert {
    
    private func createSpinner() -> JTMaterialSpinner {
        let spinner = JTMaterialSpinner()
        
        let spinnerSide = LoadingAlertConstants.spinnerSide
        let spinnerYOffset = LoadingAlertConstants.spinnerYOffset
        
        
        let frame = CGRect(x: self.frame.width/2 - (spinnerSide/2), y: spinnerYOffset, width: spinnerSide, height: spinnerSide)
        
        spinner.circleLayer.lineWidth = LoadingAlertConstants.spinnerLineWidth
        spinner.circleLayer.strokeColor = LoadingAlertConstants.spinnerColor
        spinner.animationDuration = LoadingAlertConstants.spinnerAnimationDuration
        spinner.frame = frame
        
        return spinner
    }
    
    private func createBackgroundImageView() -> UIImageView{
        
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let backgroundImage = UIImage(named: "LoadingAlert")
        let backgroundImageFrame = frame
        
        let backgroundImageView = UIImageView(frame: backgroundImageFrame)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleToFill
        
        return backgroundImageView
    }
    
    private func createCancelBtn() -> UIButton {
        
        let height = LoadingAlertConstants.cancelBtnHeight
        let width = LoadingAlertConstants.cancelBtnWidth
        let yOffset = LoadingAlertConstants.cancelBtnYOffsetFromCenter
        
        let frame = CGRect(x: self.frame.width/2 - (width/2), y: self.frame.height/2 + yOffset, width: width, height: height)
        
        let buttonFrame = frame
        let cancelBtn = UIButton(frame: buttonFrame)
        cancelBtn.setTitleColor(.blue, for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        
        return cancelBtn
    }
    
}
