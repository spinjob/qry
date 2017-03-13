//
//  PollImageDetailViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/27/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import SDWebImage

class PollImageDetailViewController: UIViewController {

    var photoURL : String = ""
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print(photoURL)
        
        imageView.sd_setImage(with: URL(string: photoURL))

    }


}
