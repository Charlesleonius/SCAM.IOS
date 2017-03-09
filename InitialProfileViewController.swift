//
//  InitialProfileViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/4/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class InitialProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var minorsTable: UITableView!
    @IBOutlet weak var classesTable: UITableView!
    
    @IBOutlet weak var majorTextField: UITextField!
    private var classes = 4
    private var minors = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in self.view.subviews {
            if let textfield = subview as? UITextField  {
                textfield.layer.borderWidth = 2
                textfield.layer.cornerRadius = 5
                textfield.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                textfield.backgroundColor = UIColor.groupTableViewBackground
                textfield.clipsToBounds = true
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addClass(_ sender: Any) {
        classes += 1
        classesTable.beginUpdates()
        classesTable.insertRows(at: [IndexPath(row: classes - 1, section: 0)], with: .automatic)
        classesTable.endUpdates()
    }
    
    @IBAction func addMinor(_ sender: Any) {
        minors += 1
        minorsTable.beginUpdates()
        minorsTable.insertRows(at: [IndexPath(row: minors - 1, section: 0)], with: .automatic)
        minorsTable.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == classesTable) {
            classes -= 1
            classesTable.beginUpdates()
            classesTable.deleteRows(at: [indexPath], with: .top)
            classesTable.endUpdates()
        } else {
            minors -= 1
            minorsTable.beginUpdates()
            minorsTable.deleteRows(at: [indexPath], with: .top)
            minorsTable.endUpdates()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == classesTable) {
            return classes
        } else {
            return minors
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "addClassCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AddClassCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.classNameField.layer.borderWidth = 2
        cell.classNameField.layer.cornerRadius = 5
        cell.classNameField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        cell.classNameField.backgroundColor = UIColor.groupTableViewBackground
        cell.classNameField.clipsToBounds = true
        cell.isExclusiveTouch = true
    
        //Update Cells
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = classesTable.cellForRow(at: indexPath) as! AddClassCell
        cell.isSelected = false
        cell.classNameField.shake()
        
    }

}
