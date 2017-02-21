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
   
    var dateCreated : String = ""
    var expiration : String = ""
    var dateExpired : String = ""
    var minutesUntilExpiration = 0
    var isExpired : Bool = false
    
    var pollID : String = ""
    var questionString : String = ""
    var answer1Percentage : Double = 0
    
    var senderUser : String = ""
    var pollURL : String = ""
    var pollImageURL : String = ""
    var pollImageTitle : String = ""
    var pollImageDescription : String = ""
    var pollQuestionImageURL : String = ""
    var answer1Count : Int = 0
    var answer2Count : Int = 0
    var groupMembers : [Recipient] = []
    var isGifPoll : Bool = false
    
    
}
