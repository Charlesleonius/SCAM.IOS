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
    @NSManaged var major: String?
    @NSManaged var doubleMajor: String?
    @NSManaged var minors: [String]?
    @NSManaged var classes: [String]?
    @NSManaged var clubs: [String]?
    @NSManaged var jobs: [String]?
    
    class func parseClassName() -> String {
        return "Profile"
    }
}
