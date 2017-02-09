//
//  AddGroupMemberTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/8/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class AddGroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var selectFriendButton: UIButton!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var alreadyOnListLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
