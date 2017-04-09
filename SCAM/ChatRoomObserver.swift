//
//  RoomUpdates.swift
//  SCAM
//
//  Created by Charles Leon on 3/15/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class ChatRoomObserver: PFObject,  PFSubclassing {
    @NSManaged var room: PFObject?
    @NSManaged var roomID: String?
    @NSManaged var updatesAvailable: Bool
    @NSManaged var userIsTyping: Bool
    
    class func parseClassName() -> String {
        return "ChatRoomObserver"
    }
}
