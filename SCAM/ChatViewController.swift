//
//  ChatViewController.swift
//  Pods
//
//  Created by Charles Leon on 2/25/17.
//
//

import JSQMessagesViewController
import Parse
import ParseLiveQuery
import SCLAlertView
import MBContactPicker

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate let liveQueryClient = ParseLiveQuery.Client(server: "https://scam16.herokuapp.com/parse")
    fileprivate var subscription: Subscription<ChatRoomObserver>?
    fileprivate var errorSubscription: Subscription<ChatRoomObserver>?
    fileprivate var createdSub: Subscription<ChatRoomObserver>?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var messages = [JSQMessage]()
    var messageIds: Set<String> = []
    var chatRoom: ChatRoom? = ChatRoom()
    
    override func viewDidLoad() {
        self.senderDisplayName = PFUser.current()?.username
        self.senderId = PFUser.current()?.objectId
        register()
        observeMessages()
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.navigationBar.tintColor = UIColor.white;
    }
    
    /**********************************************************************
     ************** Message Sendering and Recieving Handlers **************
     **********************************************************************/
    
    func register() {
        if (self.chatRoom?.objectId != nil) {
            let messageQuery: PFQuery<ChatRoomObserver>  = ChatRoomObserver.query()!.whereKey("roomID", equalTo: self.chatRoom!.objectId!) as! PFQuery<ChatRoomObserver>
            subscription = liveQueryClient.subscribe(messageQuery).handleSubscribe { (_) in
                }.handleEvent { [weak self] (_, event) in
                    self?.handleEvent(event: event)
            }
        }
    }
    
    func handleEvent(event: Event<ChatRoomObserver>) {
        // Make sure we're on main thread
        if Thread.current != Thread.main {
            return DispatchQueue.main.async { [weak self] _ in
                self?.handleEvent(event: event)
            }
        }
        
        switch event {
            case .created(let RoomUpdate), .entered(let RoomUpdate):
                print(RoomUpdate)
                observeMessages()
            case .updated(let _):
                observeMessages()
            case .deleted(let _), .left(let _):
                observeMessages()
            break
        }
    }
    
    private func addMessage(withId id: String, displayName: String, text: String, message: Message) {
        if (!messageIds.contains(message.objectId!)) {
            self.messageIds.insert(message.objectId!)
            if let message = JSQMessage(senderId: id, displayName: displayName, text: text) {
                messages.append(message)
            }
        }
    }

    private func observeMessages() {
        let messageQuery = Message.query()
        messageQuery?.whereKey("room", equalTo: self.chatRoom)
        messageQuery?.includeKey("sender")
        messageQuery?.addAscendingOrder("createdAt")
        messageQuery?.whereKey("objectId", notContainedIn: Array(messageIds))
        messageQuery?.findObjectsInBackground { (pfMessages: [PFObject]?, error: Error?) in
            if (error == nil  && pfMessages != nil) {
                for pfMessage in pfMessages! {
                    let message = pfMessage as! Message
                    let sender = message["sender"] as! PFObject
                    if let id = sender.objectId as String!, let name = message["senderDisplayName"] as! String!, let text = message["body"] as! String!, text.characters.count > 0 {
                        self.addMessage(withId: id, displayName: name, text: text, message: message)
                        self.finishReceivingMessage()
                    }
                }
            }
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        func sendMessage() {
            let message = Message()
            message.body = text
            message["room"] = self.chatRoom!
            message["observer"] = self.chatRoom!.observer!
            message.sender = PFUser.current()!
            message["senderDisplayName"] = PFUser.current()?["name"] as! String
            message.saveInBackground { (success: Bool, error: Error?) in
                if (error == nil) {
                    self.chatRoom?.observer?.updatesAvailable = true
                    self.chatRoom?.observer?.saveInBackground()
                    self.observeMessages()
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                } else {
                    SCLAlertView().showError("Oops", subTitle: "Your message didn't go through. Please try again later.")
                }
            }
        }
        
        if (self.parent is NewChatViewController) {
            if (messages.count == 0) {
                let parent = self.parent as! NewChatViewController
                parent.contactPickerView.isHidden = true
                var contactNames: [String] = []
                let contacts = parent.selectedContactModels(for: parent.contactPickerView) as! [ParseContactModel]
                contactNames.append(PFUser.current()!["name"] as! String)
                for contact in contacts {
                    contactNames.append(contact.contactTitle)
                    self.chatRoom?.add(contact.profile!, forKey: "profilePointers")
                    self.chatRoom?.relation(forKey: "profiles").add(contact.profile!)
                }
                self.chatRoom?.contactNames = contactNames
                self.chatRoom?.add(PFUser.current()!, forKey: "userPointers")
                self.chatRoom?.relation(forKey: "users").add(PFUser.current()!)
                var navTitle = contacts[0].contactTitle as String
                for i in 1..<contacts.count {
                    navTitle += ("," + contacts[i].contactTitle)
                }
                parent.messageViewTopConstraint.constant = 0
                parent.view.layoutIfNeeded()
                parent.navigationController?.navigationItem.title =  navTitle
                let acl = PFACL()
                acl.getPublicReadAccess = true
                acl.getPublicWriteAccess = true
                self.chatRoom?.acl = acl
                self.chatRoom!.saveInBackground(block: { (success: Bool, error: Error?) in
                    if (error == nil) {
                        let observer = ChatRoomObserver()
                        let acl = PFACL()
                        acl.getPublicReadAccess = true
                        acl.getPublicWriteAccess = true
                        observer.acl = acl
                        observer.room = PFObject(withoutDataWithClassName: "ChatRoom", objectId: self.chatRoom!.objectId!)
                        observer.roomID = self.chatRoom!.objectId!
                        observer.saveInBackground(block: { (success: Bool, error: Error?) in
                            if (error == nil) {
                                self.chatRoom?.observer = observer
                                self.chatRoom?.saveInBackground(block: { (success: Bool, error: Error?) in
                                    if (error == nil) {
                                        self.register()
                                        sendMessage()
                                    } else {
                                        print("setting observer failed due to: " + (error?.localizedDescription)!)
                                    }
                                })
                            } else {
                                print("Observer failed to save due to: " + (error?.localizedDescription)!)
                            }
                        })
                    } else {
                        SCLAlertView().showError("Ooops", subTitle: "Failed to create chat room.")
                    }
                })
                
            }
        } else {
            sendMessage()
        }
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    /**************************************
     ************** UI Setup **************
     **************************************/
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "SM", backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 15.0), diameter: 34)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
