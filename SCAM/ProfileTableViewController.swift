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

class ProfileTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   

    @IBOutlet weak var userInfoTable: UITableView!
    
    fileprivate var user: User?
    fileprivate var pickedImage: UIImage?
    fileprivate var titles: [String] = ["Major"]
    fileprivate var sectionCounts: [String : Int] = [:]
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberDateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureExpandingMenuButton()
        self.user = PFUser.currentUserSubclass()
        userInfoTable.refreshControl = UIRefreshControl()
        userInfoTable.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .allEvents)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeProfilePicture(_:)))
        self.profileImageView.addGestureRecognizer(tap)
        setup()
    }

    @objc func refresh() {
        self.userInfoTable.refreshControl?.beginRefreshing()
        user?.fetchInBackground(block: { (user: PFObject?, error: Error?) in
            self.userInfoTable.reloadData()
            self.userInfoTable.refreshControl?.endRefreshing()
        })
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
        if (user?.doubleMajor != nil && user?.doubleMajor != "") {
            titles.append("Double Major")
            sectionCounts["Double Major"] = 1
        }
        if (user?.minors != nil) {
            if ((user?.minors?.count)! > 0) {
                titles.append("Minors")
                sectionCounts["Minors"] = (user?.minors?.count)!
            }
        }
        if (user?.classes != nil) {
            if ((user?.classes?.count)! > 0) {
                titles.append("Classes")
                sectionCounts["Classes"] = (user?.classes?.count)!
            }
        }
        if (user?.clubs != nil) {
            if ((user?.clubs?.count)! > 0) {
                titles.append("Clubs")
                sectionCounts["Clubs"] = (user?.clubs?.count)!
            }
        }
        if (user?.jobs != nil) {
            if ((user?.jobs?.count)! > 0) {
                titles.append("Jobs")
                sectionCounts["Jobs"] = (user?.jobs?.count)!
            }
        }

    }
    
    @IBAction func editProfile(_ sender: Any) {
        let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "requiredProfileNavigationController")
        self.present(dashboard!, animated: true, completion: nil)
    }
    
    
    @IBAction func saveUpdates(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let waitingAlert = SCLAlertView(appearance: appearance)
        let responder = waitingAlert.showWait("Please Wait", subTitle: "Saving your changes")
        
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
        return titles.count
    }
    
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        return titles[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        let title = titles[section]
        return sectionCounts[title] ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileDataCell", for: indexPath) as! ProfileInformationCell
        let title = titles[indexPath.section]
        switch title {
            case "Major":
                cell.informationLabel.text = user?.major
            case "Double Major":
                cell.informationLabel.text = user?.doubleMajor
            case "Minors":
                cell.informationLabel.text = user?.minors?[indexPath.row]
            case "Classes":
                cell.informationLabel.text = user?.classes?[indexPath.row]
            case "Clubs":
                cell.informationLabel.text = user?.clubs?[indexPath.row]
            case "Jobs":
                cell.informationLabel.text = user?.jobs?[indexPath.row]
            default:
            break
        }
        return cell
    }
    
    @IBAction func logout(_ sender: Any) {
        let logoutSheet: UIAlertController = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        let logoutActionButton: UIAlertAction = UIAlertAction(title: "Logout", style: .destructive) { action -> Void in
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
        if (pickedImage != nil) {
            let file = PFFile(data: pickedImage.jpegData(.low)!)
            user?.profileImage = file
            user?.saveInBackground()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


}
