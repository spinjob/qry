//
//  PieChart.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/12/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import Foundation
import UIKit

struct Segment {
    var color : UIColor
    var value : CGFloat
}


class PieChartView: UIView {
    
    var segments = [Segment]() {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        isOpaque = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func draw(_ rect: CGRect) {
        
        //get current context
        
        let ctx = UIGraphicsGetCurrentContext()
        
        // radius is the half the frame's width or height (whichever is smallest)
        let radius = min(frame.size.width, frame.size.height)*0.5
        
        //center of the view
        let viewCenter = CGPoint(x: bounds.size.width*0.5, y: bounds.size.height*0.5)
        
        //enumerate the total value of the segments by using reduce to sum them 
        
        let valueCount = segments.reduce(0) {$0 + $1.value}

        
        // the starting angle is -90 degrees (top of the circle, as the context is flipped). By default, 0 is the right hand side of the circle, with the positive angle being in an anti-clockwise direction (same as a unit circle in maths).
        var startAngle = -CGFloat(M_PI*0.5)
        
        
        for segment in segments {
            
            //set fill color to the segment color
            ctx?.setFillColor(segment.color.cgColor)
            
            //update the end angle of the segment
            let endAngle = startAngle+CGFloat(M_PI*2)*(segment.value/valueCount)
            
            //move to the center of the pie chart
            ctx?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
            
            //add arc from the center for each segment (anticlockwise is specified for arc, but as the view flips the context, it will produce a clockwise arc)
            ctx?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            
            //fill the segment
            ctx?.fillPath()
            
            //update starting angle of the next segment to the ending angle of this segment
            startAngle = endAngle
  
            
        }
        
        
        
    }
    
}
