//
//  ImageResizer.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-07.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import Foundation
import UIKit

class ImageResizer {
    
    static func resizeImage(image: UIImage, newWidth: Int, newHeight: Int) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
