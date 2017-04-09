//
//  FriendSelectionCell.swift
//  SCAM
//
//  Created by Charles Leon on 4/7/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import BEMCheckBox
import Parse

class FriendSelectionCell: UITableViewCell {
    
    var friend: PFUser?
    var contact: ParseContactModel?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
}
