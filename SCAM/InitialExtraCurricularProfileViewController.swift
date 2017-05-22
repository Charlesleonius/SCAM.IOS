//
//  InitialExtraCurricularProfileViewController.swift
//  SCAM
//
//  Created by Charles Leon on 5/16/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import DropDown
import Parse
import SCLAlertView

class InitialExtraCurricularProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: PFUser?
    
    @IBOutlet weak var clubsTable: UITableView!
    @IBOutlet weak var jobsTable: UITableView!
    
    private var clubFields = 4
    private var jobFields = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        //Add Done Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.saveInfo(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        //Add Back Button
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        backButton.tintColor = UIColor.white
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        self.jobsTable.isScrollEnabled = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.jobsTable.isScrollEnabled = true
    }
    
    @objc
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addClub(_ sender: Any) {
        clubFields += 1
        clubsTable.beginUpdates()
        clubsTable.insertRows(at: [IndexPath(row: clubFields - 1, section: 0)], with: .automatic)
        clubsTable.endUpdates()
    }
    
    @IBAction func addMinor(_ sender: Any) {
        jobFields += 1
        jobsTable.beginUpdates()
        jobsTable.insertRows(at: [IndexPath(row: jobFields - 1, section: 0)], with: .automatic)
        jobsTable.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == jobsTable) {
            jobFields -= 1
            jobsTable.beginUpdates()
            jobsTable.deleteRows(at: [indexPath], with: .top)
            jobsTable.endUpdates()
        } else {
            clubFields -= 1
            clubsTable.beginUpdates()
            clubsTable.deleteRows(at: [indexPath], with: .top)
            clubsTable.endUpdates()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == clubsTable) {
            return clubFields
        } else {
            return jobFields
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "addClassCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AddClassCell
        if (tableView == jobsTable) {
            if let jobs = user?["jobs"] as? [String] {
                if (indexPath.row < jobs.count) {
                    cell.classNameField.text = jobs[indexPath.row]
                }
            }
        } else {
            if let clubs = user?["clubs"] as? [String] {
                if (indexPath.row < clubs.count) {
                    cell.classNameField.text = clubs[indexPath.row]
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddClassCell
        cell.isSelected = false
    }
    
    @IBAction func saveInfo(_ sender: Any) {
        var clubs: [String] = []
        var jobs: [String] = []
        for i in 0 ..< clubFields {
            let cell = clubsTable.cellForRow(at: IndexPath(row: i, section: 0)) as? AddClassCell
            let club = cell?.classNameField.text
            if (club != nil && club != "") {
                clubs.append(club!)
            }
        }
        
        for i in 0 ..< jobFields {
            if let cell = jobsTable.cellForRow(at: IndexPath(row: i, section: 0)) as? AddClassCell {
                let job = cell.classNameField.text
                if (job != nil && job != "") {
                    jobs.append(job!)
                }
            }
        }
        user?["jobs"] = jobs
        user?["clubs"] = clubs
        user?.saveInBackground(block: { (success: Bool, error: Error?) in
            if (success) {
                let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavigationController")
                self.present(dashboard!, animated: true, completion: nil)
            } else {
                print(error!.localizedDescription)
                SCLAlertView().showError("Ooops", subTitle: "Something went wrong saving your info. Please try again later")
            }
        })
    }
    
    
}
