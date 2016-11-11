//
//  Polls.swift
//  
//
//  Created by Spencer Johnson on 10/18/16.
//
//

import Foundation
class Poll {
    var answer1String : String = ""
    var answer2String : String = ""
    var expiration : String = ""
    var pollID : String = ""
    var questionString : String = ""
    var recipients : [String] = []
    var answer1Percentage : Double = 0
    var expired : Bool = false
    var senderUser : String = ""
    
    
    func expire (pollID : String) -> Void {
    
        
        
    }
}
