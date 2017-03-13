//
//  ChatRoomsViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/12/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import ParseUI
import JSQMessagesViewController

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var roomsTable: UITableView!
    
    fileprivate var rooms: [Room] = []
    private let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureExpandingMenuButton()
        roomsTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
    }
    
    @objc func refresh() {
        let query = PFQuery(className: "ChatRooms")
        query.findObjectsInBackground { (updatedRooms: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.rooms = updatedRooms as! [Room]
                DispatchQueue.main.async{
                    self.roomsTable.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "chatRoomCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatRoomCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let room = rooms[indexPath.row]
        cell.roomTitle.text = room.title
        cell.lastMessage.text = room.lastMessage
        cell.roomImage.image =
        JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: room.title?.substring(to: 1), backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 15.0), diameter: 34).avatarImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        if (rooms[indexPath.row] != nil) {
            let room = rooms[indexPath.row]
            let chatView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatView.chatRoom = room
            chatView.navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.pushViewController(chatView, animated: true)
        }
    }


}
