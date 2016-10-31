//
//  SuggestedAnswerOptionTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/28/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

protocol FeaturedAnswerCellDelegate {
    func answer1ButtonTapped(customCell : SuggestedAnswerOptionTableViewCell)
    func answer2ButtonTapped(customCell : SuggestedAnswerOptionTableViewCell)
}

class SuggestedAnswerOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var featuredAnswer1Button: UIButton!
    @IBOutlet weak var featuredAnswer2Button: UIButton!
    
    var delegate : FeaturedAnswerCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func featuredAnswer1Tapped(_ sender: Any) {
        delegate?.answer1ButtonTapped(customCell: self)
    }
    
    @IBAction func featuredAnswer2Tapped(_ sender: Any) {
        delegate?.answer2ButtonTapped(customCell: self)
        
    }
    
}
