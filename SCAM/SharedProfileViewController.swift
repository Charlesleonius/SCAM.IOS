//
//  SharedProfileViewController.swift
//  SCAM
//
//  Created by Charles Leon on 5/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import SCLAlertView
import DropdownMenu

class SharedProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userInfoTable: UITableView!
    
    var user: Profile?
    
    fileprivate var pickedImage: UIImage?
    fileprivate var titles: [String] = ["Major"]
    fileprivate var sectionCounts: [String : Int] = [:]
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberDateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureExpandingMenuButton()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        setup()
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
    
}
