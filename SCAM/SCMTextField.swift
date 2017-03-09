//
//  SCMTextField.swift
//  SCAM
//
//  Created by Charles Leon on 3/9/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class SCMTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.masksToBounds = true
    }

}
