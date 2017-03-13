//
//  ChatRoomCell.swift
//  SCAM
//
//  Created by Charles Leon on 3/12/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class ChatRoomCell: UITableViewCell {

    @IBOutlet weak var roomImage: UIImageView!
    @IBOutlet weak var roomTitle: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
