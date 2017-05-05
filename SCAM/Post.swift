//
//  Post.swift
//  SCAM
//
//  Created by Charles Leon on 4/28/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class Post: PFObject, PFSubclassing {
    
    @NSManaged var author: PFObject?
    @NSManaged var group: PFObject?
    @NSManaged var body: String?
    @NSManaged var image: PFFile?
    
    class func parseClassName() -> String {
        return "Post"
    }}
