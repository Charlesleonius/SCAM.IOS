//
//  Comment.swift
//  SCAM
//
//  Created by Charles Leon on 5/19/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class Comment: PFObject, PFSubclassing {
    
    @NSManaged var author: PFObject?
    @NSManaged var post: PFObject?
    @NSManaged var body: String?
    
    class func parseClassName() -> String {
        return "Comment"
    }
}
