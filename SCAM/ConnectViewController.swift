//
//  ConnectViewController.swift
//  SCAM
//
//  Created by Charles Leon on 5/17/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

class ConnectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var user = User.current()
    
    var groups: [[PFObject]] = [[],[],[],[],[],[]]
    var majorGroups: [Group] = []
    var minorGroups: [Group] = []
    var classGroups: [Group] = []
    var clubGroups: [Group] = []
    var people: [Profile] = []
    
    var titles = ["Major Groups", "Minor Groups", "Class Groups", "Club Groups", "Profiles", "Groups"]
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var resultsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultsTable.refreshControl = UIRefreshControl()
        self.resultsTable.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .allEvents)
        self.hideKeyboardWhenTappedAround()
        self.resultsTable.viewController()?.hideKeyboardWhenTappedAround()
        configureExpandingMenuButton()
        self.navigationItem.titleView = searchBar
        self.loadObjects()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.resign))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    //Table and Search Controllers
    
    @objc func resign() {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    @objc
    func refresh() {
        self.resultsTable.refreshControl?.beginRefreshing()
        self.loadObjects()
        self.resultsTable.refreshControl?.endRefreshing()
    }
    
    @objc
    func objectsDidLoad(error: Error? = nil) {
        if (error == nil) {
            self.resultsTable.reloadData()
        } else {
            print(error!)
        }
    }
    
    @objc
    func searchObjects() {
        self.groups = [[],[],[],[],[],[]]
        if (searchBar.text == "") {
            return
        } else {
            for i in 0..<6 {
                self.groups[i] = []
            }
        }
        let searchText = searchBar.text!.lowercased()
        
        let groupQuery = Group.query()!
        groupQuery.whereKey("searchStrings", containedIn: [searchText])
        groupQuery.findObjectsInBackground { (searchGroups: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.groups[5] = searchGroups!
                self.objectsDidLoad()
            } else {
                self.objectsDidLoad(error: error)
            }
        }
        
        let profileQuery = Profile.query()!
        profileQuery.whereKey("searchStrings", containedIn: [searchText])
        profileQuery.whereKey("user", notEqualTo: PFUser.current()!)
        profileQuery.findObjectsInBackground { (searchProfiles: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.groups[4] = searchProfiles!
                self.objectsDidLoad()
            } else {
                self.objectsDidLoad(error: error)
            }
        }
    }
    
    @objc
    func loadObjects() {
        self.groups = [[],[],[],[],[],[]]
        let user = User.current()!
        if (user.major != nil) {
            var majors = [user.major!]
            if (user.doubleMajor != nil) {
                majors.append(user.doubleMajor!)
            }
            let query = Group.query()!
            query.whereKey("title", containedIn: majors)
            query.findObjectsInBackground { (groups: [PFObject]?, error: Error?) in
                if (error == nil) {
                    self.majorGroups = groups as! [Group]
                    self.groups[0] = groups as! [Group]
                    self.objectsDidLoad()
                } else {
                    self.objectsDidLoad(error: error)
                }
            }
        }
        
        if (user.minors != nil) {
            let query = Group.query()!
            query.whereKey("title", containedIn: user.minors!)
            query.findObjectsInBackground { (groups: [PFObject]?, error: Error?) in
                if (error == nil) {
                    self.minorGroups = groups as! [Group]
                    self.groups[1] = groups as! [Group]
                    self.objectsDidLoad()
                } else {
                    self.objectsDidLoad(error: error)
                }
            }
        }
        
        if (user.classes != nil) {
            let query = Group.query()!
            query.whereKey("title", containedIn: (user.classes)!)
            query.findObjectsInBackground { (groups: [PFObject]?, error: Error?) in
                if (error == nil) {
                    self.classGroups = groups as! [Group]
                    self.groups[2] = groups as! [Group]
                    self.objectsDidLoad()
                } else {
                    self.objectsDidLoad(error: error)
                }
            }
        }
        
        if (user.clubs != nil) {
            let query = Group.query()!
            query.whereKey("title", containedIn: (user.clubs)!)
            query.findObjectsInBackground { (groups: [PFObject]?, error: Error?) in
                if (error == nil) {
                    self.clubGroups = groups as! [Group]
                    self.groups[3] = groups as! [Group]
                    self.objectsDidLoad()
                } else {
                    self.objectsDidLoad(error: error)
                }
            }
        }
        
        createSuggestedUserQuery(user: user).findObjectsInBackground { (users: [PFObject]?, error: Error?) in
            if (error == nil) {
                let profiles = self.sortUsers(profiles: users as! [Profile])
                self.groups[4] = profiles
                self.objectsDidLoad()
            } else {
                self.objectsDidLoad(error: error)
            }
        }
        
    }
    
    func createSuggestedUserQuery(user: User) -> PFQuery<PFObject> {
        var queries: [PFQuery<PFObject>] = []
        
        let matchingMajorQuery = Profile.query()!
        matchingMajorQuery.whereKey("major", equalTo: user.major!)
        queries.append(matchingMajorQuery)
        
        if (user.classes != nil) {
            let matchingClassesQuery = Profile.query()!
            matchingClassesQuery.whereKey("classes", containedIn: user.classes!)
            queries.append(matchingClassesQuery)
        }
        
        if (user.clubs != nil) {
            let matchingClubsQuery = Profile.query()!
            matchingClubsQuery.whereKey("clubs", containedIn: user.clubs!)
            queries.append(matchingClubsQuery)
        }
        
        let finalQuery = PFQuery.orQuery(withSubqueries: queries)
        finalQuery.whereKey("user", notEqualTo: PFUser.current()!)
        return finalQuery
        
    }
    
    //Sort to determine best matches for users
    
    func sortUsers(profiles: [Profile]) -> [Profile] {
        return profiles.sorted(by: sortProfile)
    }
    
    func sortProfile(this: Profile, that: Profile) -> Bool {
        
        var thisPoints = 0.0
        var thatPoints = 0.0
        
        if (this.major == user?.major || this.major == user?.doubleMajor) {
            thisPoints += 2
        }
        
        if (that.major == user?.major || this.major == user?.doubleMajor) {
            thatPoints += 2
        }
        
        if (this.doubleMajor == user?.major || this.doubleMajor == user?.doubleMajor) {
            thisPoints += 2
        }
        
        if (that.doubleMajor == user?.major || that.doubleMajor == user?.doubleMajor) {
            thatPoints += 2
        }
        
        //Compare classes
        if (user?.classes != nil) {
            if (this.classes != nil) {
                for course in this.classes! {
                    for userCourse in user!.classes! {
                        if (course == userCourse) {
                            thisPoints += 1
                        }
                    }
                }
            }
            if (that.classes != nil) {
                for course in that.classes! {
                    for userCourse in user!.classes! {
                        if (course == userCourse) {
                            thatPoints += 1
                        }
                    }
                }
            }
        }
        
        //Compare classes
        if (user?.clubs != nil) {
            if (this.clubs != nil) {
                for club in this.clubs! {
                    for userClub in user!.clubs! {
                        if (club == userClub) {
                            thisPoints += 0.5
                        }
                    }
                }
            }
            if (that.clubs != nil) {
                for club in that.clubs! {
                    for userClubs in user!.clubs! {
                        if (club == userClubs) {
                            thatPoints += 0.5
                        }
                    }
                }
            }
        }
        
        if (thisPoints == thatPoints) {
            return (this.name?.length)! > (that.name?.length)!
        }
        
        return thisPoints > thatPoints
    }
    
    //Table View
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (groups[section].count == 0) {
            return 0.1
        }
        return 20
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        if (groups[section].count == 0) {
            return nil
        }
        return titles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "connectResultCell", for: indexPath) as! ConnectResultCell
        cell.resultImageView.image = nil
        cell.indexPath = indexPath
        cell.isExclusiveTouch = true
        if let group = groups[indexPath.section][indexPath.row] as? Group {
            if (group.image != nil) {
                cell.resultImageView.loadFromChacheThenParse(file: group.image!)
            } else {
                cell.resultImageView.image = #imageLiteral(resourceName: "defaultGroupAvatar")
            }
            cell.titleLabel.text = group.title
            cell.verificationImageView.isHidden = !group.official
            cell.object = group
        } else {
            if let profile = groups[indexPath.section][indexPath.row] as? Profile {
                cell.resultImageView.image = #imageLiteral(resourceName: "defaultAvatar")
                if (profile.profileImage != nil) {
                    cell.setImage(file: profile.profileImage!, circular: false, indexPath: indexPath)
                }
                cell.titleLabel.text = profile.name
                cell.subtitleLabel.text = profile.major
                cell.verificationImageView.isHidden = true
                cell.object = profile
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ConnectResultCell
        if let group = cell.object as? Group {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupPageTableViewController") as! GroupPageTableViewController
            vc.group = group
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let profile = cell.object as? Profile {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SharedProfileTableViewController") as! SharedProfileViewController
            vc.user = profile
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchObjects()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchBar.text == "") {
            self.loadObjects()
        }
    }

}
