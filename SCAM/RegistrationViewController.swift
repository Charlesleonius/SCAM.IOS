//
//  RegistrationViewController.swift
//  SCAM
//
//  Created by Charles Leon on 2/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class RegistrationViewController: UIViewController {

    @IBOutlet weak var termsOfService: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    
    private var validEmail = false
    private var validPassword = false
    private var validPasswordConfirmation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fields = [emailField,  passwordField, passwordConfirmationField]
        for field in fields {
            field?.layer.borderWidth = 1
            field?.layer.borderColor = UIColor.lightGray.cgColor
            field?.layer.masksToBounds = true
            field?.autocorrectionType = .no
        }
        
        //Style terms of service to make it stand out
        let termsOfServiceText = "By signing up, you agree to our Terms of Service."
        let attributedString = NSMutableAttributedString(string: "By signing up, you agree to our Terms of Service.")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: self.navigationController?.view.backgroundColor ?? UIColor.blue , range: (termsOfServiceText as NSString).range(of: "Terms of Service."))
        termsOfService.attributedText = attributedString
        
    }

    @IBAction func verifyEmail(_ sender: Any) {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        if (test.evaluate(with: emailField.text)) {
            emailField.layer.borderColor = self.navigationController?.view.backgroundColor?.cgColor ?? UIColor.blue.cgColor
            validEmail = true
        } else {
            emailField.layer.borderColor = UIColor.red.cgColor
            validEmail = false
        }
        if (emailField.text == "") {
            emailField.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBAction func verifyPassword(_ sender: Any) {
        passwordConfirmationField.text = ""
        passwordConfirmationField.layer.borderColor = UIColor.lightGray.cgColor
        let regex = "[a-zA-Z0-9!@#$%^&*.(+=._-]{6,}"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        if(test.evaluate(with: passwordField.text)) {
            passwordField.layer.borderColor = self.navigationController?.view.backgroundColor?.cgColor ?? UIColor.blue.cgColor
            validPassword = true
        } else {
            passwordField.layer.borderColor = UIColor.red.cgColor
            validPassword = false
        }
        if (passwordField.text == "") {
            passwordField.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBAction func verifyPasswordConfirmation(_ sender: Any) {
        if (passwordConfirmationField.text == passwordField.text) {
            passwordConfirmationField.layer.borderColor = self.navigationController?.view.backgroundColor?.cgColor ?? UIColor.blue.cgColor
            validPasswordConfirmation = true
        } else {
            passwordConfirmationField.layer.borderColor = UIColor.red.cgColor
            validPasswordConfirmation = false
        }
        if (passwordConfirmationField.text == "") {
            passwordConfirmationField.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    @IBAction func register(_ sender: Any) {
        if (validEmail && validPassword && validPasswordConfirmation) {
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let waitingAlert = SCLAlertView(appearance: appearance)
            let responder = waitingAlert.showWait("Please Wait", subTitle: "", closeButtonTitle: nil, duration: 0, colorStyle: 0x1461ab, colorTextButton: 0x1461ab, circleIconImage: nil, animationStyle: .topToBottom)
            let newUser = PFUser()
            newUser.username = emailField.text?.lowercased()
            newUser.password = passwordField.text
            newUser.email = emailField.text?.lowercased()
            newUser["deviceID"] = UIDevice.current.identifierForVendor!.uuidString
            var localTimeZoneName: String { return (NSTimeZone.local as NSTimeZone).name }
            newUser["timeZone"] = localTimeZoneName
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if (error == nil) {
//                    if let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String {
//                        PFCloud.callFunction(inBackground: "updateInstallation", withParameters: ["deviceToken": deviceToken.lowercased()])
//                    }
                    responder.close()
                } else {
                    responder.close()
                    print(error?.localizedDescription ?? "")
                    let errorAlert = SCLAlertView()
                    var errorMessage = "Something went wrong, try again later!"
                    switch error!._code {
                    case 203:
                        errorMessage = "This email is already is use, please try another."
                        break
                    case 202:
                        errorMessage = "This email is already in use, please try another."
                        break
                    default:
                        break
                    }
                    errorAlert.showError("Oops", subTitle: errorMessage)
                }
            }
        } else {
            SCLAlertView().showError("Ooops", subTitle: "Please check all the fields for errors. When all the fields are blue, you're good to go.")
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
