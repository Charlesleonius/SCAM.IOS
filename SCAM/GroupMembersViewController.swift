//
//  GroupMembersViewController.swift
//  SCAM
//
//  Created by Charles Leon on 4/29/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class GroupMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Instance Varibales
    var group: Group?
    fileprivate var profiles: [Profile] = []
    
    //Referencing Outlets
    @IBOutlet weak var memberTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadObjects()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMember))
    }
    
    
    //To Be Implemented
    
    @objc
    func addMember() {
        
    }
    
    @IBAction func removeMember(_ sender: UIButton) {
        
    }
    
    //Table View Controllers
    
    @objc
    func objectsDidLoad(error: Error? = nil) {
        if (error == nil) {
            self.memberTable.reloadData()
        } else {
            print(error!.localizedDescription)
        }
    }
    
    @objc
    func loadObjects() {
        let query = group?.relation(forKey: "profiles").query()
        query?.whereKey("objectId", notEqualTo: User.currentProfile()?.objectId ?? "")
        query?.addDescendingOrder("name")
        query?.findObjectsInBackground(block: { (updatedProfiles: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.profiles = updatedProfiles as! [Profile]
                self.objectsDidLoad()
            } else {
                self.objectsDidLoad(error: error)
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! GroupMemberCell
        
        let profile = profiles[indexPath.row]
        cell.usernameLabel.text = profile.name
        if (profile.profileImage != nil) {
            cell.profileImageView.loadFromChacheThenParse(file: profile.profileImage!, contentMode: .scaleAspectFit, circular: true)
        } else {
            cell.profileImageView.image = #imageLiteral(resourceName: "defaultAvatar")
        }
        
        cell.actionButton.tag = indexPath.row
        if (group!.acl!.getWriteAccess(for: PFUser.current()!)) {
            cell.actionButton.isHidden = false
            cell.actionButton.addTarget(self, action: #selector(self.removeMember(_:)), for: .allEvents)
        } else {
            cell.actionButton.isHidden = true
        }
        
        return cell
    }
    

}
