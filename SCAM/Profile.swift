//
//  Profile.swift
//  SCAM
//
//  Created by Charles Leon on 4/28/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class Profile: PFObject, PFSubclassing {
    @NSManaged var user: PFObject?
    @NSManaged var name: String?
    @NSManaged var username: String?
    @NSManaged var profileImage: PFFile?
    
    class func parseClassName() -> String {
        return "Profile"
    }
}
