//
//  File.swift
//  SCAM
//
//  Created by Charles Leon on 2/25/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//


import Foundation
import Parse

class Message: PFObject, PFSubclassing {
    @NSManaged var room: String?
    @NSManaged var body: String?
    @NSManaged var sender: PFObject?
    
    class func parseClassName() -> String {
        return "Messages"
    }
}
