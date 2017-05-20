//
//  SCMTextField.swift
//  SCAM
//
//  Created by Charles Leon on 3/9/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import DropDown

class SCMTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    fileprivate let dropDown = DropDown()
    fileprivate var dataSource: [String] = []
    var enableDropDown = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.masksToBounds = true
        setupDropDown()
        self.addTarget(nil, action:#selector(self.done), for:.editingDidEndOnExit)
        self.returnKeyType = .done
    }
    
    @objc
    func done() {
        self.endEditing(true)
        self.dropDown.hide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.backgroundColor = UIColor.groupTableViewBackground
        self.layer.masksToBounds = true
        setupDropDown()
        self.addTarget(self, action: #selector(self.search), for: .editingChanged)
        self.addTarget(self, action: #selector(self.showDropdown), for: .editingDidBegin)
        self.addTarget(nil, action:Selector(("firstResponderAction:")), for:.editingDidEndOnExit)
        self.returnKeyType = .done
    }
    
    func setDataSource(newDataSource: [String]) {
        self.dataSource = newDataSource
        self.dropDown.dataSource = newDataSource
    }
    
    @objc func showDropdown() {
        if (self.enableDropDown) {
            self.dropDown.show()
        }
    }
    
    @objc func search() {
        if (self.enableDropDown) {
            dropDown.show()
            dropDown.dataSource = self.dataSource
            if (self.text != "" && self.text != nil) {
                var newSource: [String] = []
                for data in dropDown.dataSource {
                    if (data.lowercased().contains(self.text!.lowercased())) {
                        newSource.append(data)
                    }
                }
                dropDown.dataSource = newSource
            }
        }
    }
    
    func setDropDownWidth(width: CGFloat) {
        dropDown.width = width
    }
    
    fileprivate func setupDropDown() {
        self.keyboardDistanceFromTextField = 250
        dropDown.direction = .bottom
        dropDown.width = self.bounds.width
        dropDown.anchorView = self
        dropDown.backgroundColor = UIColor.white
        dropDown.separatorColor = UIColor.groupTableViewBackground
        dropDown.cornerRadius = 5.0
        dropDown.width = self.bounds.width
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        dropDown.bottomOffset = CGPoint(x: 0, y: self.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        dropDown.dataSource = self.dataSource
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.text = item
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        self.dropDown.hide()
        return false
    }

}
