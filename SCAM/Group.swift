//
//  Group.swift
//  SCAM
//
//  Created by Charles Leon on 4/8/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class Group: PFObject, PFSubclassing {
    @NSManaged var isPrivate: Bool
    @NSManaged var title: String?
    @NSManaged var profiles: [PFObject]?
    @NSManaged var profilePointers: [PFObject]?
    @NSManaged var users: [PFUser]?
    @NSManaged var userPointers: [PFObject]?
    @NSManaged var image: PFFile?
    
    class func parseClassName() -> String {
        return "Group"
    }
}
