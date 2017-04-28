//
//  GroupCollectionCell.swift
//  SCAM
//
//  Created by Charles Leon on 4/27/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class GroupCollectionCell: UICollectionViewCell {
    
    var group: Group?
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var friendsInGroupLabel: UILabel!

}
