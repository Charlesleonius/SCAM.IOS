//
//  NewGroupViewController.swift
//  SCAM
//
//  Created by Charles Leon on 4/7/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import SCLAlertView
import Parse
import BEMCheckBox
import MBContactPicker
import JSQMessagesViewController
import SCLAlertView

class NewGroupViewController: UIViewController, MBContactPickerDelegate, MBContactPickerDataSource, UIImagePickerControllerDelegate , UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var originalUsers: [PFObject]?
    fileprivate var contacts: [ParseContactModel] = []
    fileprivate var selectedContacts: [ParseContactModel] = []
    fileprivate var privacyGroup: BEMCheckBoxGroup?
    fileprivate var pickedImage: UIImage?
    
    @IBOutlet weak var pickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var contactPicker: MBContactPicker!
    @IBOutlet weak var privateCheckBox: BEMCheckBox!
    @IBOutlet weak var publicCheckBox: BEMCheckBox!
    @IBOutlet weak var groupTitleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //Setup image view
        groupImageView.layer.borderWidth = 1.0
        groupImageView.layer.masksToBounds = false
        groupImageView.layer.borderColor = UIColor.black.cgColor
        groupImageView.layer.cornerRadius = groupImageView.frame.size.width/2
        groupImageView.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(self.changeProfilePicture(_:)))
        groupImageView.isUserInteractionEnabled = true
        groupImageView.addGestureRecognizer(tapGestureRecognizer)
        
        //Setup contact picker
        contactPicker.prompt = "Members:"
        
        do {
            let query = PFUser.query()
            let users = try query?.whereKey("objectId", notEqualTo: PFUser.current()!.objectId!).findObjects()
            for user in users! {
                let model = ParseContactModel()
                model.contactTitle = user["name"] as! String
                model.contactSubtitle = "..."
                model.contactImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: model.contactTitle.substring(to: 1), backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 15.0), diameter: 34).avatarImage
                model.user = user
                self.contacts.append(model)
            }
        } catch {
            let appearance = SCLAlertView.SCLAppearance.init(
                showCloseButton: false
            )
            let errorAlert = SCLAlertView(appearance: appearance)
            errorAlert.addButton("Okay", action: { 
                self.dismiss(animated: true, completion: nil)
            })
            errorAlert.showError("Failed to load group creation", subTitle: "Please check your connection and try again later.")
        }
        
        //Setup privacy selection
        self.privacyGroup = BEMCheckBoxGroup(checkBoxes: [publicCheckBox, privateCheckBox])
        self.privacyGroup?.selectedCheckBox = publicCheckBox
        self.privacyGroup?.mustHaveSelection = true; // Define if the group must always have a selection
    }
    
    @IBAction func createGroup(_ sender: Any) {
        let group = Group()
        group.isPrivate = (privacyGroup?.selectedCheckBox == privateCheckBox) ? true : false
        group.title = groupTitleField.text
        if (self.pickedImage != nil) {
            group.image = PFFile(data: (pickedImage?.jpegData(.low))!)
        }
        for contact in self.selectedContacts {
            group.users?.append(contact.user as! PFUser)
            group.add(contact.user!, forKey: "userPointers")
            group.relation(forKey: "users").add(contact.user as! PFUser)
        }
        group.add(PFUser.current()!, forKey: "userPointers")
        group.relation(forKey: "users").add(PFUser.current()!)

        group.saveInBackground { (success: Bool, error: Error?) in
            if (error == nil) {
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
                SCLAlertView().showError("Ooops", subTitle: "Something went wrong creating your group, please try again later.")
            }
        }
    }
    
    func customFilterPredicate(_ searchString: String!) -> NSPredicate! {
        if (searchString == " ") {
            let predicate = NSPredicate(value: true)
            return predicate
        }
        let predicate = NSPredicate(format: "contactTitle BEGINSWITH[cd] %@", searchString)
        return predicate
    }
    
    func contactCollectionView(_ contactCollectionView: MBContactCollectionView, didSelectContact model: MBContactPickerModelProtocol) {
    }
    
    //Add
    func contactCollectionView(_ contactCollectionView: MBContactCollectionView, didAddContact model: MBContactPickerModelProtocol) {
        self.selectedContacts.append(model as! ParseContactModel)
        let cell = usersTable.cellForRow(at: IndexPath(row: selectedContacts.count-1, section: 0)) as? FriendSelectionCell
        cell?.checkBox.on = true
    }
    
    func contactCollectionView(_ contactCollectionView: MBContactCollectionView, didRemoveContact model: MBContactPickerModelProtocol) {
        let contact = model as! ParseContactModel
        for i in 0 ..< self.selectedContacts.count {
            if (contact == selectedContacts[i]) {
                self.selectedContacts.remove(at: i)
                let cell = usersTable.cellForRow(at: IndexPath(row: i, section: 0)) as? FriendSelectionCell
                cell?.checkBox.on = false
            }
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FriendSelectionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendSelectionCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let contact = self.contacts[indexPath.row]
        cell.contact = contact
        cell.profileImage.image = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: contact.contactTitle.substring(to: 1), backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 15.0), diameter: 34).avatarImage
        cell.username.text = contact.contactTitle
        
        if (self.selectedContacts.contains(cell.contact!)) {
            cell.checkBox.on = true
        } else {
            cell.checkBox.on = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? FriendSelectionCell
        cell?.isSelected = false
        contactPicker.add(toSelectedContacts: cell?.contact)
        cell?.checkBox.on = true
    }
    
    @IBAction func changeProfilePicture(_ sender: Any)
    {
        let pickerC = UIImagePickerController()
        pickerC.allowsEditing = false
        pickerC.sourceType = .photoLibrary
        pickerC.delegate = self
        pickerC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        pickerC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.present(pickerC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil);
        let pickedImage:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.pickedImage = pickedImage
        self.groupImageView.image = pickedImage.circle
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
