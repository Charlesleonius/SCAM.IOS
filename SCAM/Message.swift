//
//  File.swift
//  SCAM
//
//  Created by Charles Leon on 2/25/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class Message: PFObject, PFSubclassing {
    @NSManaged var room: PFObject?
    @NSManaged var body: String?
    @NSManaged var sender: PFObject?
    @NSManaged var observer: PFObject?
    
    class func parseClassName() -> String {
        return "Message"
    }
}
