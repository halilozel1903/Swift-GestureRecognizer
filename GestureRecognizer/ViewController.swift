//
//  ViewController.swift
//  GestureRecognizer
//
//  Created by Halil on 6.10.2017.
//  Copyright © 2017 Halil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var HalilPicture = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled=true
        
        let gestureRecognizer = UITapGestureRecognizer(target : self ,action : #selector(ViewController.changePic))
        
        imageView.addGestureRecognizer(gestureRecognizer)
        
    }

    @objc func changePic()
     {
        if HalilPicture == true {
            imageView.image=UIImage(named:"halil.jpg")
            nameLabel.text = "Halil"
            HalilPicture = false
        }
        else if HalilPicture == false {
            imageView.image=UIImage(named:"ibrahim.jpg")
            nameLabel.text="İbrahim"
            HalilPicture = true
        }
    }
        
   


}

