//
//  Tweet.swift
//  TwitterAS
//
//  Created by Adam Stehlik on 30/06/2020.
//  Copyright © 2020 Adam Stehlik. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Tweet: Decodable {
    let id: String
    let name: String
    let username: String
    let body: String
    let noOfLikes: Int
    let imageURL: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username = "screen_name"
        case body = "text"
        case noOfLikes = "favourites_count"
        case imageURL = "profile_image_url_https"
        case date = "created_at"
    }
    

    public static func tempTweet() -> Tweet {
        return Tweet(id: UUID().description, name: "Tim Cook", username: "t_cook()", body: "Lorem Ipsum", noOfLikes: 5, imageURL: "TODO", date: Date())
    }
}

extension Tweet {
    public init(data: JSON) {

        self.id = data["id"].string ?? "-1"
        self.name = data["user"]["name"].string!
        self.username = data["user"]["screen_name"].string!
        self.imageURL = data["user"]["profile_image_url_https"].string!
        self.body = data["text"].string!
        self.noOfLikes = data["favorite_count"].int!
        
        let _date = data["created_at"].string!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        self.date = dateFormatter.date(from: _date)!
        
    }
}
