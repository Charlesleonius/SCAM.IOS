//
//  InitialProfileViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/4/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class InitialProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var classesTable: UITableView!
    @IBOutlet weak var clubsTable: UITableView!
    
    @IBOutlet weak var majorTextField: UITextField!
    private var classes = 4
    private var clubs = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        majorTextField.layer.borderWidth = 2
        majorTextField.layer.cornerRadius = 5
        majorTextField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        majorTextField.backgroundColor = UIColor.groupTableViewBackground
        majorTextField.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addClass(_ sender: Any) {
        classes += 1
        classesTable.beginUpdates()
        classesTable.insertRows(at: [IndexPath(row: classes - 1, section: 0)], with: .automatic)
        classesTable.endUpdates()
    }
    
    @IBAction func addClub(_ sender: Any) {
        clubs += 1
        clubsTable.beginUpdates()
        clubsTable.insertRows(at: [IndexPath(row: clubs - 1, section: 0)], with: .automatic)
        clubsTable.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == classesTable) {
            classes -= 1
        classesTable.beginUpdates()
            classesTable.deleteRows(at: [indexPath], with: .top)
            classesTable.endUpdates()
        } else {
            clubs -= 1
            clubsTable.beginUpdates()
            clubsTable.deleteRows(at: [indexPath], with: .top)
            clubsTable.endUpdates()
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == classesTable) {
            return classes
        } else {
            return clubs
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
    
        //Update Cells
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = classesTable.cellForRow(at: indexPath) as! AddClassCell
        cell.isSelected = false
        cell.classNameField.shake()
        
    }

}
