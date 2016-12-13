//
//  WebViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/8/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var pieChartView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pieChartView = PieChartView()
        pieChartView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 400)
        pieChartView.segments = [
            Segment(color: UIColor.red, value: 57),
            Segment(color: UIColor.blue, value: 30),
            Segment(color: UIColor.green, value: 25),
            Segment(color: UIColor.yellow, value: 40)
        ]
        view.addSubview(pieChartView)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    }

 
