//
//  Room.swift
//  SCAM
//
//  Created by Charles Leon on 3/12/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class ChatRoom: PFObject,  PFSubclassing {
    @NSManaged var title: String?
    @NSManaged var lastMessage: String?
    @NSManaged var observer: ChatRoomObserver?
    @NSManaged var messages: PFRelation<Message>?
    @NSManaged var contactNames: [String]?
    
    class func parseClassName() -> String {
        return "ChatRoom"
    }
}
