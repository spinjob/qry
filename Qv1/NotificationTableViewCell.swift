//
//  NotificationTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/16/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationIconImageView: UIImageView!
    
    @IBOutlet weak var actionableObjectLabel: UILabel!
    
    @IBOutlet weak var notificationTypeLabel: UILabel!
    
    @IBOutlet weak var arrowIconImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
