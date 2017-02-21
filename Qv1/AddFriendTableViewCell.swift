//
//  AddFriendTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/20/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var contactUserImageView: UIImageView!
    @IBOutlet weak var contactUserNameLabel: UILabel!
    
    @IBOutlet weak var selectionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
