//
//  GroupsViewControllerTableViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/25/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class GroupsViewControllerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var privateGroups: [Group] = []
    fileprivate var publicGroups: [Group] = []
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var privacySelector: UISegmentedControl!
    @IBOutlet weak var groupTableView: UITableView!
    
    @IBAction func changePrivacy(_ sender: Any) {
        groupTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refresh()
        
        self.configureExpandingMenuButton()
    }
    
    @objc func refresh() {
        let publicQuery = PFQuery(className: "Group")
        publicQuery.addAscendingOrder("title")
        publicQuery.whereKey("isPrivate", equalTo: false)
        publicQuery.findObjectsInBackground { (updatedGroups: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.publicGroups = updatedGroups as! [Group]
                DispatchQueue.main.async{
                    self.groupTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        let privateQuery = PFQuery(className: "Group")
        privateQuery.addAscendingOrder("title")
        privateQuery.whereKey("isPrivate", equalTo: true)
        privateQuery.findObjectsInBackground { (updatedGroups: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.privateGroups = updatedGroups as! [Group]
                DispatchQueue.main.async{
                    self.groupTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (privacySelector.selectedSegmentIndex == 0) {
            return publicGroups.count
        }
        return privateGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.selectionStyle = .none
        var group = self.publicGroups[indexPath.row]
        if (privacySelector.selectedSegmentIndex == 1) {
            group = self.privateGroups[indexPath.row]
        }
        cell.groupImageView.loadFromChacheThenParse(file: group.image!)
        cell.titleLabel.text = group.title
        cell.subtitleLabel.text = "No subtitles Yet these will probably be deprecated"
        cell.memberCountLabel.text = (group.userPointers?.count.description ?? "-") + " Members"
        cell.friendsInGroupLabel.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        print("Select")
    }
    
    @IBAction func createGroup(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGroupViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
