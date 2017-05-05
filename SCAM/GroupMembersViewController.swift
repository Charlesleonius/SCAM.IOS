//
//  GroupMembersViewController.swift
//  SCAM
//
//  Created by Charles Leon on 4/29/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class GroupMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var group: Group?
    fileprivate var profiles: [Profile] = []
    
    @IBOutlet weak var memberTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadObjects()
    }
    
    @objc
    func objectsDidLoad(error: Error? = nil) {
        if (error == nil) {
            self.memberTable.reloadData()
        } else {
            print(error?.localizedDescription)
        }
    }
    
    @objc
    func loadObjects() {
        let query = group?.relation(forKey: "profiles").query()
        query?.whereKey("objectId", notEqualTo: PFUser.currentProfile()?.objectId ?? "")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendSelectionCell", for: indexPath) as! FriendSelectionCell
        
        let profile = profiles[indexPath.row]
        cell.username.text = profile.name
        if (profile.profileImage != nil) {
            cell.profileImage.loadFromChacheThenParse(file: profile.profileImage!, contentMode: .scaleAspectFit, circular: true)
        }
        cell.checkBox.on = true
        
        return cell
    }
    

}
