//
//  GroupMemberTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/6/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var groupMemberNameLable: UILabel!
    @IBOutlet weak var groupMemberImageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
