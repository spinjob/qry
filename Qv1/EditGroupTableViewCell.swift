//
//  EditGroupTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/21/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class EditGroupTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func editButtonTapped(_ sender: Any) {
    }
    
    
}
