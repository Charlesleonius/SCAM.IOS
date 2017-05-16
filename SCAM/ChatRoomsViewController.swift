//
//  ChatRoomsViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/12/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import ParseUI
import JSQMessagesViewController
import SCLAlertView

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var roomsTable: UITableView!
    
    fileprivate var rooms: [ChatRoom] = []
    private let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureExpandingMenuButton()
        roomsTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name:NSNotification.Name(rawValue: "refreshRooms"), object: nil)
        refresh()
    }
    
    @objc func refresh() {
        let query = PFQuery(className: "ChatRoom")
        query.addDescendingOrder("updatedAt")
        query.findObjectsInBackground { (updatedRooms: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.rooms = updatedRooms as! [ChatRoom]
                DispatchQueue.main.async{
                    self.roomsTable.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @IBAction func createChat(_ sender: Any) {
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "NewChatViewController")
        chatView?.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.pushViewController(chatView!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        rooms[indexPath.row].deleteInBackground(block: { (success: Bool, error: Error?) in
            if (success) {
                self.refresh()
            }
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "chatRoomCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatRoomCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let room = rooms[indexPath.row]
        if (room.title != nil) {
            cell.roomTitle.text = room.title
        } else {
            let currentUsername = PFUser.current()!["name"] as! String
            var nameTitle = ""
            for name in room.contactNames! {
                if (name != currentUsername) {
                    nameTitle = name
                }
            }
            cell.roomTitle.text = nameTitle
        }
        
        func setImage(string: String) {
            cell.roomImage?.image =
                JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: string.substring(to: 1), backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 15.0), diameter: 34).avatarImage
        }
        
        if (room.title != nil) {
            setImage(string: room.title!)
        } else {
            setImage(string: "SCAM")
        }
        if (room.profilePointers?.count == 1) {
            for profile in room.profilePointers! {
                if (profile.objectId != PFUser.currentProfile()?.objectId) {
                    profile.fetchInBackground(block: { (updatedProfile: PFObject?, error: Error?) in
                        if (error == nil) {
                            let updatedProfile = updatedProfile as! Profile
                            if (updatedProfile.profileImage != nil) {
                                cell.roomImage?.loadFromChacheThenParse(file: profile.profileImage!, contentMode: .scaleAspectFit, circular: true)
                            } else {
                                setImage(string: updatedProfile.name!)
                            }
                        }
                    })
                }
            }
        }
        
        cell.lastMessage.text = room.lastMessage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        let room = rooms[indexPath.row]
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController")
                as! ChatViewController
        chatView.chatRoom = room
        self.navigationController?.pushViewController(chatView, animated: true)
    }


}
