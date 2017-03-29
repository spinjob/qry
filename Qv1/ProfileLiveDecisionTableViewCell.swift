//
//  ProfileLiveDecisionTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 3/24/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ProfileLiveDecisionTableViewCell: UITableViewCell {
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var answerPieChartView: UIView!
    
    @IBOutlet weak var pieChartCenterView: UIView!
    @IBOutlet weak var questionTextView: UITextView!

    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var timerViewCenterView: UIView!
    
    @IBOutlet weak var timeLeftAmountLabel: UILabel!
    @IBOutlet weak var timeLeftUnitLabel: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        groupCollectionView.delegate = dataSourceDelegate
        groupCollectionView.dataSource = dataSourceDelegate
        groupCollectionView.reloadData()
    }

}
