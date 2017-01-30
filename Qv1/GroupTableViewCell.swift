//
//  GroupTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/31/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupMember1ImageView: UIImageView!

    @IBOutlet weak var groupMemberCollectionView: UICollectionView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
