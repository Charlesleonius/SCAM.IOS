//
//  ProfileTableViewController.swift
//  SCAM
//
//  Created by Charles Leon on 4/28/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import SCLAlertView
import DropdownMenu

class ProfileTableViewController: UIViewController, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    fileprivate var user: User?
    fileprivate var pickedImage: UIImage?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberDateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureExpandingMenuButton()
        user = PFUser.current() as? User
        setup()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeProfilePicture(_:)))
        self.profileImageView.addGestureRecognizer(tap)
    }

    func setup() {
        self.usernameLabel.text = user?.name
        if (user?.profileImage != nil) {
            profileImageView.loadFromChacheThenParse(file: user!.profileImage!, contentMode: .scaleAspectFit, circular: true)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.string(from: (user?.createdAt!)!)
        memberDateLabel.text = "Member Since: " + date
    }
    
    @IBAction func saveUpdates(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let waitingAlert = SCLAlertView(appearance: appearance)
        let responder = waitingAlert.showWait("Please Wait", subTitle: "Saving your changes")
        if (pickedImage != nil) {
            let file = PFFile(data: pickedImage!.jpegData(.low)!)
            user?.profileImage = file
        }
        user?.saveInBackground(block: { (success: Bool, error: Error?) in
            responder.close()
            if (error == nil) {
                SCLAlertView().showSuccess("Success!", subTitle: "Your changes have been saved!")
                self.setup()
            } else {
                SCLAlertView().showError("Oops", subTitle: "Something went wrong saving your changes.")
            }
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    @IBAction func logout(_ sender: Any) {
        let logoutSheet: UIAlertController = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        let logoutActionButton: UIAlertAction = UIAlertAction(title: "Logout", style: .destructive) { action -> Void in
            PFCloud.callFunction(inBackground: "unsetInstallations", withParameters: [:])
            PFUser.logOut()
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController")
            self.dismiss(animated: true) {
                appDelegate.window?.makeKeyAndVisible()
            }
        }
        logoutSheet.addAction(cancelActionButton)
        logoutSheet.addAction(logoutActionButton)
        self.present(logoutSheet, animated: true, completion: nil)

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
        self.profileImageView.image = pickedImage.circle
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


}
