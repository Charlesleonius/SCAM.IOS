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
    
    var messages = [JSQMessage]()
    let liveQueryClient = ParseLiveQuery.Client(server: "https://scam16.herokuapp.com/parse")
    var subscription: Subscription<Message>?
    var errorSubscription: Subscription<Message>?
    var createdSub: Subscription<Message>?
    var room = "room"
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        self.senderDisplayName = PFUser.current()?.username
        self.senderId = PFUser.current()?.objectId
        register()
        observeMessages()
        super.viewDidLoad()
    }
    
    func register() {
        let messageQuery: PFQuery<Message>  = Message.query()!.whereKeyExists("body") as! PFQuery<Message>
        subscription = liveQueryClient.subscribe(messageQuery).handleSubscribe { (_) in
                
            }.handleEvent { [weak self] (_, event) in
                self?.handleEvent(event: event)
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
        let messageQuery = PFQuery(className: "Messages")
        messageQuery.findObjectsInBackground { (messages: [PFObject]?, error: Error?) in
            for message in messages! as! [Message] {
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
