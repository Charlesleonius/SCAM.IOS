//
//  SidePanelViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/3/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import SideMenu
import Parse

class SidePanelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var titles = ["Profile", "Settings"]
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.image = profilePicture.image?.circle
        profilePicture.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SideMenuManager.menuAnimationDismissDuration = 0.35
        let currentUser = PFUser.current()!
        usernameLabel.text = currentUser.username
        tableView.alwaysBounceVertical = false;
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SidePanelViewController.changeProfilePicture(_:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func changeProfilePicture(_ img: AnyObject)
    {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Change your profile picture?", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in}
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default)
        { action -> Void in
            let pickerC = UIImagePickerController()
            pickerC.allowsEditing = false
            pickerC.sourceType = .photoLibrary
            pickerC.delegate = self
//            pickerC.navigationBar.barTintColor = UIColor(netHex: 0x04bd1a0)
            pickerC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
            pickerC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
            self.present(pickerC, animated: true, completion: nil)
        }
        
        actionSheetControllerIOS8.addAction(cancelActionButton)
        actionSheetControllerIOS8.addAction(saveActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil);
        picker.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "sidepanelcell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SidePanelCells
        
        cell.label.text = titles[(indexPath as NSIndexPath).row]
//        cell.icon.image = images[(indexPath as NSIndexPath).row]
        
        cell.tag = (indexPath as NSIndexPath).row
        //Update Cells
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SideMenuManager.menuAnimationDismissDuration = 0.2
        switch (indexPath as NSIndexPath).row {
        case 0:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "InitialProfileNavigationController")
            self.present(vc!, animated: true, completion: nil)
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }
    }
}
