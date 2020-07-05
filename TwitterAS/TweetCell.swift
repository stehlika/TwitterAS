//
//  TweetCell.swift
//  TwitterAS
//
//  Created by Adam Stehlik on 30/06/2020.
//  Copyright © 2020 Adam Stehlik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class TweetCell: UITableViewCell {

    @IBOutlet weak var personIconIM: UIImageView!
    @IBOutlet weak var authorNameL: UILabel!
    @IBOutlet weak var authorUsernameL: UILabel!
    @IBOutlet weak var tweetDateL: UILabel!
    @IBOutlet weak var tweetBodyL: UITextView!
    @IBOutlet weak var likesCountL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tweetBodyL.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureCell(tweet: Tweet) {
        self.authorNameL.text = tweet.name
        self.authorUsernameL.text = "@\(tweet.username)"
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        self.tweetDateL.text = dateFormatter.string(from: tweet.date)
        self.tweetBodyL.text = tweet.body
        self.likesCountL.text = "\(tweet.noOfLikes)"
    
        AF.request(tweet.imageURL).responseImage { response in
            if case .success(let image) = response.result {
                let circularImage = image.af.imageRoundedIntoCircle()
                self.personIconIM.image = circularImage
            } else {
                debugPrint("Something went wrong in downloading the image.\(response.error?.localizedDescription ?? "Default error.")")
            }
        }
    }
}
