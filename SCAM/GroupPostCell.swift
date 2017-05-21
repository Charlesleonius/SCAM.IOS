//
//  GroupPostCell.swift
//  SCAM
//
//  Created by Charles Leon on 4/27/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import Haneke

class GroupPostCell: UITableViewCell {

    
    @IBOutlet weak var bodyImageView: UIImageView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var usefulCountLabel: UILabel!
    @IBOutlet weak var findUsefulButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func setDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.creationDateLabel.text = formatter.string(from: date)
    }
    
    var indexPath: IndexPath?
    
    func setImage(file: PFFile, circular: Bool, indexPath: IndexPath) {
        var url = file.url!
        if (!url.contains("https")) {
            url = url.insert(string: "s", ind: 4)
        }
        let URL = NSURL(string: url)!
        let cache = Shared.imageCache
        let fetcher = NetworkFetcher<UIImage>(URL: URL as URL)
        cache.fetch(fetcher: fetcher).onSuccess { image in
            DispatchQueue.main.async() { () -> Void in
                if (self.indexPath == indexPath) {
                    if (circular == true) {
                        self.profileImageView.image = image.circle
                    } else {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }

}
