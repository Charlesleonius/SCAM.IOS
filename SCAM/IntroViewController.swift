//
//  IntroViewController.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Change status bar appearance when view appears or dissapears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }

}
