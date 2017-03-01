//
//  SelectThreadTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/28/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class SelectThreadTableViewCell: UITableViewCell {
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var pieChartCenterView: UIView!

    @IBOutlet weak var timeLeftUnitLabel: UILabel!
    @IBOutlet weak var timeLeftNumberLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
