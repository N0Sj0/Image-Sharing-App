//
//  aViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-24.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

class aViewController: UIViewController {

    @IBAction func backbtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        print("width ", image?.size.width, "height", image?.size.width)
        // Do any additional setup after loading the view.
    }
}
