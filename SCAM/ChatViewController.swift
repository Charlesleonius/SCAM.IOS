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

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate let liveQueryClient = ParseLiveQuery.Client(server: "https://scam16.herokuapp.com/parse")
    fileprivate var subscription: Subscription<Message>?
    fileprivate var errorSubscription: Subscription<Message>?
    fileprivate var createdSub: Subscription<Message>?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var messages = [JSQMessage]()
    var room = "room"
    var chatRoom: Room?
    
    override func viewDidLoad() {
        self.senderDisplayName = PFUser.current()?.username
        self.senderId = PFUser.current()?.objectId
        register()
        observeMessages()
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationController?.title = room
        self.navigationController?.navigationItem.title = room
    }
    
    func register() {
        let messageQuery: PFQuery<Message>  = Message.query()!.whereKeyExists("body") as! PFQuery<Message>
        subscription = liveQueryClient.subscribe(messageQuery).handleSubscribe { (_) in }.handleEvent { [weak self] (_, event) in self?.handleEvent(event: event)
        }
    }
    
    func handleEvent(event: Event<Message>) {
        // Make sure we're on main thread
        if Thread.current != Thread.main {
            return DispatchQueue.main.async { [weak self] _ in
                self?.handleEvent(event: event)
            }
        }
        
        switch event {
        case .created(let obj), .entered(let obj):
            let sender = obj.sender
            if let id = sender?["objectId"] as! String!, let name = obj["room"] as! String!, let text = obj["body"] as! String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            }
        case .updated(let obj):
            print(obj)
            
        case .deleted(let obj), .left(let obj):
            print(obj)
        }
    }

    private func observeMessages() {
        let messageQuery = chatRoom?.messages?.query()
        messageQuery?.addAscendingOrder("createdAt")
        messageQuery?.findObjectsInBackground { (messages: [Message]?, error: Error?) in
            for message in messages! {
                let sender = message["sender"] as! PFObject
                if let id = sender.objectId as String!, let name = message["room"] as! String!, let text = message["body"] as! String!, text.characters.count > 0 {
                    self.addMessage(withId: id, name: name, text: text)
                    self.finishReceivingMessage()
                }

            }

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
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
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
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
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = Message()
        message.body = text
        message.room = "room"
        let acl = PFACL()
        acl.getPublicReadAccess = true
        acl.getPublicWriteAccess = true
        message.acl = acl
        message["sender"] = PFUser.current()!
        message.saveInBackground { (success: Bool, error: Error?) in
            if (!success) {
                SCLAlertView().showError("Oops", subTitle: "Your message didn't go through. Please try again later.")
            } else {
                let relation = self.chatRoom!.relation(forKey: "messages")
                relation.add(message)
                self.chatRoom!.lastMessage = message.body!
                self.chatRoom!.saveInBackground(block: { (success: Bool, error: Error?) in
                    print(success)
                })
            }
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
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
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
