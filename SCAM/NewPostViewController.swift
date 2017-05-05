//
//  NewPostViewController.swift
//  SCAM
//
//  Created by Charles Leon on 4/28/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import SCLAlertView

class NewPostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate var pickedImage: UIImage?
    var group: Group?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bodyImageView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var photoActionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        bodyTextView.delegate = self
        setup()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.post))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc
    func post() {
        let post = Post()
        if (self.bodyTextView.text.length > 0) {
            post.body = self.bodyTextView.text
        } else {
            SCLAlertView().showError("Oops", subTitle: "You must have some text in your post!")
            return
        }
        if (pickedImage != nil) {
            post.image = PFFile(data: (pickedImage?.jpegData(.medium))!)
        }
        if (self.group == nil) {
            return
        } else {
            post.group = self.group
        }
        post.author = (PFUser.current() as? User)?.profile
        let waitingAppearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let responder = SCLAlertView(appearance: waitingAppearance).showWait("Please Wait", subTitle: "Saving your post.")
        post.saveInBackground { (success: Bool, error: Error?) in
            responder.close()
            if (success) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroup"), object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                SCLAlertView().showError("Oops", subTitle: "Soemthing went wrong saving your post, please try again.")
            }
        }
    }
    
    func setup() {
        let user = PFUser.current() as? User
        usernameLabel.text = user?.name
        if (user?.profileImage != nil) {
            profileImageView.loadFromChacheThenParse(file: (user?.profileImage)!, contentMode: .scaleAspectFit, circular: true)
        }
    }
    
    func addedPicture() {
        if ((pickedImage?.size.height)! < 800) {
            imageHeight.constant = (pickedImage?.size.height)!
        } else {
            imageHeight.constant = 800
        }
        photoActionButton.setTitle("Remove Photo", for: .normal)
        photoActionButton.setTitleColor(UIColor.red, for: .normal)
        photoActionButton.removeTarget(nil, action: nil, for: .allEvents)
        photoActionButton.addTarget(self, action: #selector(self.removePicture), for: .touchDown)
    }
    
    @objc
    func removePicture() {
        self.pickedImage = nil
        self.bodyImageView.image = nil
        photoActionButton.setTitle("Add Photo", for: .normal)
        photoActionButton.setTitleColor((self.navigationController?.view.backgroundColor ?? UIColor.blue), for: .normal)
        photoActionButton.removeTarget(nil, action: nil, for: .allEvents)
        photoActionButton.addTarget(self, action: #selector(self.changeImage(_:)), for: .touchDown)

    }

     func textViewDidBeginEditing(_ textView: UITextView) {
        if (bodyTextView.text == "What's on your mind?")
        {
            bodyTextView.text = ""
            bodyTextView.textColor = .black
        }
        bodyTextView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (bodyTextView.text == "")
        {
            bodyTextView.text = "What's on your mind?"
            bodyTextView.textColor = .lightGray
        }
        bodyTextView.resignFirstResponder()
    }
    
    @IBAction func changeImage(_ sender: Any)
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
        self.bodyImageView.image = pickedImage
        addedPicture()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
