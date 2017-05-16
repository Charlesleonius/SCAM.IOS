//
//  GroupMemberCell.swift
//  SCAM
//
//  Created by Charles Leon on 5/14/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class GroupMemberCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
