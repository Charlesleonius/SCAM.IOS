//
//  GroupsViewControllerTableViewController.swift
//  SCAM
//
//  Created by Charles Leon on 3/25/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse

private let reuseIdentifier = "GroupCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 50.0, right: 20.0)
fileprivate let itemsPerRow: CGFloat = 2

class GroupsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    fileprivate var privateGroups: [Group] = []
    fileprivate var publicGroups: [Group] = []
    private let refreshControl = UIRefreshControl()
    

    @IBOutlet weak var privacySelector: UISegmentedControl!
    
    @IBAction func changePrivacy(_ sender: Any) {
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refresh()
        
        self.configureExpandingMenuButton()
    }
    
    @objc func refresh() {
        let publicQuery = PFQuery(className: "Group")
        publicQuery.addAscendingOrder("title")
        publicQuery.whereKey("isPrivate", equalTo: false)
        publicQuery.whereKey("userPointers", containsAllObjectsIn: [PFUser.current()!])
        publicQuery.findObjectsInBackground { (updatedGroups: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.publicGroups = updatedGroups as! [Group]
                DispatchQueue.main.async{
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        let privateQuery = PFQuery(className: "Group")
        privateQuery.addAscendingOrder("title")
        privateQuery.whereKey("isPrivate", equalTo: true)
        privateQuery.findObjectsInBackground { (updatedGroups: [PFObject]?, error: Error?) in
            if (error == nil) {
                self.privateGroups = updatedGroups as! [Group]
                DispatchQueue.main.async{
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @IBAction func createGroup(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGroupViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (privacySelector.selectedSegmentIndex == 1) {
            return privateGroups.count
        }
        return publicGroups.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionCell
        cell.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = true
        
        
        cell.groupImageView.image = #imageLiteral(resourceName: "spartan")
        
        var group = self.publicGroups[indexPath.row]
        
        if (privacySelector.selectedSegmentIndex == 1) {
            group = self.privateGroups[indexPath.row]
        }
        
        cell.group = group
        
        if (indexPath.section == 1) {
            group = self.privateGroups[indexPath.row]
        }
        if (group.image != nil) {
            cell.groupImageView.loadFromChacheThenParse(file: group.image!, contentMode: .scaleAspectFit, circular: true)
        }
        cell.titleLabel.text = group.title
        cell.memberCountLabel.text = (group.userPointers?.count.description ?? "-") + " Members"
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GroupCollectionCell
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupPageTableViewController") as! GroupPageTableViewController
        vc.group = cell.group
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
