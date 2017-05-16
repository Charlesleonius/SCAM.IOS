//
//  NewChatViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/13/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import MBContactPicker
import JSQMessagesViewController

class NewChatViewController: UIViewController, MBContactPickerDelegate, MBContactPickerDataSource {
    
    fileprivate var contacts: [ParseContactModel] = []
    fileprivate var selectedContacts: [ParseContactModel] = []
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var contactPickerView: MBContactPicker!
    @IBOutlet weak var pickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactPickerView.delegate = self;
        self.contactPickerView.datasource = self;
        contactPickerView.prompt = "To:"
        messageView.isHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.hideKeyboardWhenTappedAround()
        self.loadObjects()
    }
    
    @objc
    func objectsDidLoad(profiles: [Profile]) {
        for profile in profiles {
            let model = ParseContactModel()
            model.profile = profile
            model.contactTitle = profile.name
            model.contactSubtitle = profile.username!
            if (profile.profileImage == nil) {
                model.contactImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: model.contactTitle.substring(to: 1), backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 15.0), diameter: 34).avatarImage
            } else {
                profile.profileImage?.getDataInBackground({ (data: Data?, error: Error?) in
                    if (error == nil) {
                        let image = UIImage(data: data!)
                        model.contactImage = image?.circle
                        
                    }
                    self.contacts.append(model)
                }, progressBlock: nil)
            }
            self.contacts.append(model)
            self.contactPickerView.reloadData()
        }
    }
    
    @objc
    func loadObjects() {
        let query = Profile.query()
        query?.whereKey("user", notEqualTo: PFUser.current()!).findObjectsInBackground(block: { (profiles:[PFObject]?, error: Error?) in
            if (error == nil) {
                self.objectsDidLoad(profiles: profiles as! [Profile])
            } else {
                print(error?.localizedDescription ?? "")
            }
        })
    }
    
    /********************************/
    /********* Contact Picker *******/
    /********************************/
    
    func contactCollectionView(_ contactCollectionView: MBContactCollectionView, didSelectContact model: MBContactPickerModelProtocol) {
    }
    
    //Add
    func contactCollectionView(_ contactCollectionView: MBContactCollectionView, didAddContact model: MBContactPickerModelProtocol) {
        self.selectedContacts.append(model as! ParseContactModel)
        messageView.isHidden = (contactCollectionView.selectedContacts.count > 0) ? false : true
    }
    
    func contactCollectionView(_ contactCollectionView: MBContactCollectionView, didRemoveContact model: MBContactPickerModelProtocol) {
        let contact = model as! ParseContactModel
        for i in 0 ..< self.selectedContacts.count {
            if (contact == selectedContacts[i]) {
                self.selectedContacts.remove(at: i)
            }
        }
        messageView.isHidden = (contactCollectionView.selectedContacts.count > 0) ? false : true
    }
    
    func contactModels(for contactPickerView: MBContactPicker!) -> [Any]! {
        return self.contacts
    }
    
    func selectedContactModels(for contactPickerView: MBContactPicker!) -> [Any]! {
        return self.selectedContacts
    }
    
    //Search
    func didShowFilteredContacts(for contactPicker: MBContactPicker) {
        UIView.animate(withDuration: TimeInterval(contactPicker.animationSpeed), animations: {() -> Void in
            let pickerRectInWindow: CGRect = self.view.convert(contactPicker.frame, from: nil)
            let newHeight: CGFloat? = (self.view.window?.bounds.size.height)! - pickerRectInWindow.origin.y - contactPicker.keyboardHeight
            self.pickerHeightConstraint.constant = newHeight!
            self.view.layoutIfNeeded()
        })
    }
    
    func contactPicker(_ contactPicker: MBContactPicker, didUpdateContentHeightTo newHeight: CGFloat) {
        self.pickerHeightConstraint.constant = newHeight
        UIView.animate(withDuration: TimeInterval(contactPicker.animationSpeed), animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func didHideFilteredContacts(for contactPicker: MBContactPicker!) {
        UIView.animate(withDuration: TimeInterval(contactPicker.animationSpeed), animations: {() -> Void in
            self.pickerHeightConstraint.constant = contactPicker.currentContentHeight
            self.view.layoutIfNeeded()
        })
    }
    
}
