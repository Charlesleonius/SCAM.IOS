//
//  GroupPostCell.swift
//  SCAM
//
//  Created by Charles Leon on 4/27/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class GroupPostCell: UITableViewCell {

    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
