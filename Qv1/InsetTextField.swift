//
//  InsetTextField.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/12/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import Foundation
import UIKit

class InsetLabel: UILabel {
    let topInset = CGFloat(12.0)
    let bottomInset = CGFloat(12.0)
    let leftInset = CGFloat(12.0)
    let rightInset = CGFloat(12.0)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        
        
    }

    
}

