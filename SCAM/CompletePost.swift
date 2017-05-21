//
//  CompletePost.swift
//  SCAM
//
//  Created by Charles Leon on 4/29/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//
import Parse

class CompletePost: AnyObject {
    var author: Profile?
    var body: String?
    var image: UIImage?
    var helped: [PFObject]?
}
