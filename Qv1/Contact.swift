//
//  Contact.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/30/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import Foundation
import UIKit

class Contact: NSObject {
    
    var name: String!
    var phone: String?
    var image: UIImage?
    var isUser: Bool!

    init(name: String, email: String, phone: String, image: UIImage?) {
        self.name = name
        self.phone = phone
        self.image = image
        self.isUser = false
    }

}
