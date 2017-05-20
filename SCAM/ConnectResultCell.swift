//
//  ConnectResultCell.swift
//  SCAM
//
//  Created by Charles Leon on 5/18/17.
//  Copyright © 2017 SCAM16. All rights reserved.
//

import Parse
import Haneke

class ConnectResultCell: UITableViewCell {

    var indexPath: IndexPath?
    var object: PFObject?
    
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
                        self.resultImageView.image = image.circle
                    } else {
                        self.resultImageView.image = image
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var verificationImageView: UIImageView!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

}
