//
//  EditGroupMemberTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/29/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class EditGroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var groupMemberNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var groupMemberImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
