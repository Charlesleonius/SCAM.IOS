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
    var posts: [Post] = []
    var completePosts: [CompletePost] = []
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var newPostView: UIView!
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .allEvents)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "refreshGroup"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.createNewPost))
        newPostView.addGestureRecognizer(tap)
        
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
        
        self.loadObjects()
        
    }
    
    @objc
    func refresh() {
        self.refreshControl?.beginRefreshing()
        self.loadObjects()
    }
    
    func objectsDidLoad(error: Error? = nil) {
        if (error == nil) {
            completePosts = []
            for post in posts {
                let completePost = CompletePost()
                completePost.author = post.author as? Profile
                completePost.body = post.body
                do {
                    let data = try post.image?.getData()
                    if (data != nil) {
                        completePost.image = UIImage(data: data!)
                    }
                    completePosts.append(completePost)
                } catch {
                    completePosts.append(completePost)
                }
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadObjects() {
        let query = group?.relation(forKey: "posts").query()
        query?.includeKey("author")
        query?.addDescendingOrder("createdAt")
        query?.findObjectsInBackground { (updatedPosts: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.posts = updatedPosts as! [Post]
                self.objectsDidLoad()
            } else {
                
            }
        }
    }
    
    @objc
    func createNewPost() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
        vc.group = self.group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewMembers(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupMembersViewControllers") as! GroupMembersViewController
        vc.group = self.group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupPostCell", for: indexPath) as! GroupPostCell
        
        let post = completePosts[indexPath.row]
        cell.bodyLabel.text = post.body
        
        if let author = post.author {
            cell.nameLabel.text = author.name
            if (author.profileImage != nil) {
                cell.profileImageView.loadFromChacheThenParse(file: author.profileImage!, contentMode: .scaleAspectFit, circular: true)
            }
        }
        
        if (post.image != nil) {
            cell.bodyImageView.isHidden = false
            cell.bodyImageView.image = post.image
            let ratio =  cell.frame.width / (post.image?.size.height)!
            
            cell.postImageViewHeight.constant = (post.image?.size.height)! * ratio
        } else {
            cell.bodyImageView.isHidden = true
            cell.postImageViewHeight.constant = 0
            cell.bodyImageView.image = nil
        }
        
        cell.bodyLabel.sizeToFit()
        
        return cell
    }

}