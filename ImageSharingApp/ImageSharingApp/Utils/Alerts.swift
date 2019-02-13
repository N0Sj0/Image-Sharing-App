//
//  Alerts.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-15.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation
import UIKit

struct Alerts {
    
    static func createCommentAlert(actionCompletion: @escaping (_ commentText: String?)->()) -> UIAlertController {
        let alert = UIAlertController(title: "Comment", message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Your comment here"
            textfield.keyboardType = .default
        }
        let commentAction = UIAlertAction(title: "Comment", style: .default) { (_) in
            actionCompletion(alert.textFields?.first?.text)
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(commentAction)
        alert.addAction(cancelBtn)
        
        return alert
    }
    
    
    static func createSimpleAlert(title: String, message: String, cancelTitle: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alert.addAction(okBtn)
        
        return alert
    }
    
}
