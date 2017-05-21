//
//  PostViewController.swift
//  SCAM
//
//  Created by Charles Leon on 5/19/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import IQKeyboardManagerSwift

class PostViewController: UITableViewController {

    var post: Post?
    var comments: [Comment] = []
    
    @IBOutlet weak var creationTimeLabel: UILabel!
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usefulButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postBodyLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var hiddenCommentField: UITextField!
    
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentField.keyboardDistanceFromTextField = 250
        
        tableView.estimatedRowHeight = 200;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let header = self.headerView!
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.groupTableViewBackground.cgColor
        border.frame = CGRect(x: 0, y: header.frame.size.height - width, width:  self.view.frame.width, height: header.frame.size.height)
        
        border.borderWidth = width
        self.headerView.layer.addSublayer(border)
        self.headerView.layer.masksToBounds = true
        
        let footer = self.tableView.tableFooterView!
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 2)
        topBorder.backgroundColor = UIColor.groupTableViewBackground.cgColor
        footer.layer.addSublayer(topBorder)
        
        //Set up author
        let author = post?.author as? Profile
        usernameLabel.text = author?.name
        if (author?.profileImage != nil) {
            self.profileImageView.loadFromChacheThenParse(file: author!.profileImage!)
        } else {
            self.profileImageView.image = #imageLiteral(resourceName: "defaultAvatar")
        }
        

        self.postBodyLabel.sizeToFit()
        
        if (post?.image != nil) {
            self.post?.image?.getDataInBackground(block: { (data: Data?, error: Error?) in
                if (data != nil) {
                    let image = UIImage(data: data!)
                    self.postImageView.image = image
                    self.postImageView.isHidden = false
                    let ratio = self.headerView.frame.width / (image?.size.height)!
                    self.postImageViewHeight.constant = (image?.size.height)! * ratio
                }
            })
        } else {
            self.postImageView.isHidden = true
            self.postImageViewHeight.constant = 0
            self.postImageView.image = nil
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.creationTimeLabel.text = formatter.string(from: post!.createdAt!)
        
        postBodyLabel.sizeToFit()
        
        self.loadObjects()
    }
    
    @IBAction func beginCommenting(_ sender: Any) {
        
        self.hiddenCommentField.becomeFirstResponder()
        self.commentField.becomeFirstResponder()
    }
    
    @IBAction func postComment(_ sender: Any) {
        if (commentField.text == nil || commentField.text == "") {
            return
        }
        let comment = Comment()
        comment.body = commentField.text
        comment.post = post
        comment.saveInBackground { (success: Bool, error: Error?) in
            if (error == nil) {
                self.loadObjects()
            } else {
                print(error!)
            }
        }
    }
    
    @IBAction func clearComment(_ sender: Any) {
        self.commentField.text = ""
        self.commentField.resignFirstResponder()
    }
    
    @IBAction func findPostUseful(_ sender: Any) {
        let params = [
            "post": true,
            "ID" : self.post?.objectId!
        ] as [String : Any]
        PFCloud.callFunction(inBackground: "findUseful", withParameters:
        params) { (success: Any?, error: Error?) in
            if (error == nil) {
                self.usefulButton.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            }
        }
    }
    
    @IBAction func findCommentUseful(_ sender: UIButton) {
        let comment = comments[sender.tag]
        let params = [
            "post": false,
            "ID" : comment.objectId!
            ] as [String : Any]
        PFCloud.callFunction(inBackground: "findUseful", withParameters:
        params) { (success: Any?, error: Error?) in
            if (error == nil) {
                sender.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            }
        }

    }
    
    @objc func objectsDidLoad(error: Error? = nil) {
        self.tableView.reloadData()
    }
    
    @objc func loadObjects() {
        let query = Comment.query()!
        query.whereKey("post", equalTo: self.post!)
        query.includeKey("author")
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground { (updatedComments: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.commentField.text = ""
                self.commentField.resignFirstResponder()
                self.comments = updatedComments as! [Comment]
                self.objectsDidLoad()
            } else {
                self.objectsDidLoad(error: error!)
            }
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! GroupPostCell
        
        cell.indexPath = indexPath
        
        let comment = comments[indexPath.row]
        let author = comment.author as? Profile
        
        cell.bodyLabel.text = comment.body
        cell.nameLabel.text = author?.name
        cell.setDate(date: comment.createdAt!)
        
        if (author?.profileImage != nil) {
            cell.setImage(file: author!.profileImage!, circular: false, indexPath: indexPath)
        } else {
            cell.profileImageView.image = #imageLiteral(resourceName: "defaultAvatar")
        }
        
        cell.bodyLabel.sizeToFit()
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
