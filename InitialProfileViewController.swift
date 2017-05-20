//
//  InitialProfileViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/4/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import DropDown
import Parse
import IQKeyboardManagerSwift

class InitialProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user = PFUser.current()
    
    @IBOutlet weak var minorsTable: UITableView!
    @IBOutlet weak var classesTable: UITableView!
    
    @IBOutlet weak var majorTextField: SCMTextField!
    @IBOutlet weak var doubleMajorField: SCMTextField!
    
    private var classFields = 4
    private var minorFields = 2
    private var knownMajors = SJSUInformation.majors
    private var knownMinors = SJSUInformation.minors
    private var knownClasses = SJSUInformation.classes
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = PFUser.current()
        
        if (user?["hasCompletedRequiredFields"] != nil) {
            if (!(user?["hasCompletedRequiredFields"] as! Bool)) {
                self.navigationItem.leftBarButtonItem = nil
            }
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        majorTextField.enableDropDown = true
        majorTextField.setDataSource(newDataSource: knownMajors)
        doubleMajorField.enableDropDown = true
        doubleMajorField.setDataSource(newDataSource: knownMajors)
        self.hideKeyboardWhenTappedAround()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    func setup() {
        self.majorTextField.text = user?["major"] as? String
        self.doubleMajorField.text = user?["doubleMajor"] as? String
    }
    
    func keyboardDidShow(notification: NSNotification) {
        self.classesTable.isScrollEnabled = false
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.classesTable.isScrollEnabled = true
    }
    
    @IBAction func addClass(_ sender: Any) {
        classFields += 1
        classesTable.beginUpdates()
        classesTable.insertRows(at: [IndexPath(row: classFields - 1, section: 0)], with: .automatic)
        classesTable.endUpdates()
    }
    
    @IBAction func addMinor(_ sender: Any) {
        minorFields += 1
        minorsTable.beginUpdates()
        minorsTable.insertRows(at: [IndexPath(row: minorFields - 1, section: 0)], with: .automatic)
        minorsTable.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == classesTable) {
            classFields -= 1
            classesTable.beginUpdates()
            classesTable.deleteRows(at: [indexPath], with: .top)
            classesTable.endUpdates()
        } else {
            minorFields -= 1
            minorsTable.beginUpdates()
            minorsTable.deleteRows(at: [indexPath], with: .top)
            minorsTable.endUpdates()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == classesTable) {
            return classFields
        } else {
            return minorFields
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "addClassCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AddClassCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.classNameField.enableDropDown = true
        
        if (tableView == classesTable) {
            cell.classNameField.setDataSource(newDataSource: knownClasses)
            if let classes = user?["classes"] as? [String] {
                if (indexPath.row < classes.count) {
                    cell.classNameField.text = classes[indexPath.row]
                }
            }
        } else {
            cell.classNameField.setDataSource(newDataSource: knownMinors)
            if let minors = user?["minors"] as? [String] {
                if (indexPath.row < minors.count) {
                    cell.classNameField.text = minors[indexPath.row]
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
        var isValid = true
        var major: String?
        var doubleMajor: String?
        var minors: [String] = []
        var classes: [String] = []
        if (!knownMajors.contains(majorTextField.text!)) {
            majorTextField.shake()
            isValid = false
        } else {
            major = majorTextField.text!
        }
        if (doubleMajorField.text != "" && !knownMajors.contains(doubleMajorField.text!)) {
            doubleMajorField.shake()
        } else {
            doubleMajor = doubleMajorField.text!
        }
        for i in 0 ..< minorFields {
            let cell = minorsTable.cellForRow(at: IndexPath(row: i, section: 0)) as! AddClassCell
            let minor = cell.classNameField.text
            if (minor != nil && minor != "") {
                if (!knownMinors.contains(minor!)) {
                    cell.classNameField.text = ""
                    cell.classNameField.shake()
                } else {
                    minors.append(minor!)
                }
            }
        }
        for i in 0 ..< classFields {
            if let cell = classesTable.cellForRow(at: IndexPath(row: i, section: 0)) as? AddClassCell {
                let course = cell.classNameField.text
                if (course != nil && course != "") {
                    if (!knownClasses.contains(course!)) {
                        cell.classNameField.text = ""
                        cell.classNameField.shake()
                    } else {
                        classes.append(course!)
                    }
                }
            }
        }
        if (!isValid) {
            return
        }
        user?["major"] = major
        if (doubleMajor != nil && doubleMajor != "") {
            user?["double"] = doubleMajor
        }
        user?["minors"] = minors
        user?["classes"] = classes
        let extraCurricVc = self.storyboard?.instantiateViewController(withIdentifier: "initialExtraCurricularViewController") as! InitialExtraCurricularProfileViewController
        extraCurricVc.user = user
        self.navigationController?.pushViewController(extraCurricVc, animated: true)
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
