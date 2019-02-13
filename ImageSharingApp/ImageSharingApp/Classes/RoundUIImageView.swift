//
//  RoundUIImageView.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-01.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

@IBDesignable
class RoundUIImageView: UIImageView {
    
    @IBInspectable
    var cornerRadius:Bool = false {
        didSet {
            if cornerRadius {
                setCornerRadius(cornerRadius: Int(self.frame.width/2))
            }
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.black {
        didSet {
            drawBorder()
        }
    }
    
}

extension RoundUIImageView {
    private func drawBorder() {
        
        let viewCenter = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
        let path = UIBezierPath(arcCenter: viewCenter, radius: self.frame.width/2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 8
        
        self.layer.addSublayer(shapeLayer)
    }
    
    private func setCornerRadius(cornerRadius: Int) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }
}

