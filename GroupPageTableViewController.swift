//
//  GroupPageTableViewController.swift
//  SCAM
//
//  Created by Charles Leon on 4/27/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class GroupPageTableViewController: UITableViewController {

    var group: Group?
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if (PFUser.current()? ["profileImage"] != nil) {
            self.profileImageView.loadFromChacheThenParse(file: (PFUser.current()? ["profileImage"] as! PFFile), contentMode: .scaleAspectFit, circular: true)
        }
        
        if (group?.image != nil) {
            headerImageView.loadFromChacheThenParse(file: (group?.image)!, contentMode: .scaleAspectFit, circular: false)
        }
        groupTitleLabel.text = group?.title
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupPostCell", for: indexPath) as! GroupPostCell
        cell.bodyLabel.text = "Hey guys how's it going. I was wondering if I could get some help with this project I have for 131."
        
        cell.postImageViewHeight.constant = 200
        cell.bodyLabel.sizeToFit()
        
        return cell
    }

}
