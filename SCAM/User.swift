//
//  User.swift
//  SCAM
//
//  Created by Charles Leon on 4/28/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class User: PFUser {

    @NSManaged var name: String?
    @NSManaged var profile: PFObject?
    @NSManaged var profileImage: PFFile?
    @NSManaged var hasCompletedRequiredFields: Bool
    @NSManaged var major: String?
    @NSManaged var doubleMajor: String?
    @NSManaged var minors: [String]?
    @NSManaged var classes: [String]?
    @NSManaged var clubs: [String]?
    @NSManaged var jobs: [String]?
    
    
}
