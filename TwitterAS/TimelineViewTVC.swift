//
//  TimelineViewTVC.swift
//  TwitterAS
//
//  Created by Adam Stehlik on 30/06/2020.
//  Copyright © 2020 Adam Stehlik. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TimelineViewTVC: UITableViewController {
    
    private var accessToken: String?
    private let consumerKey = "aKRoCQMY24pyUOVGu0KM8UFA5"
    private let consumerSecret = "y8aionCapxYIuoT3aPWDBuXqrcdRX48YiewFT74EGzx6UR9uvr"
    private let baseUrlString = "https://api.twitter.com/1.1/"
    private let pageSize = 20
    private var account = "elonmusk"
    private var _tweets = [Tweet]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        getTimelineForScreenName()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tweets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as? TweetCell {
            let tweet = self._tweets[indexPath.row]
            cell.configureCell(tweet: tweet)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        let alert = UIAlertController(title: "Change timeline", message: "Please input twitter name", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Submit", style: .default) { (alertAction) in
          let textField = alert.textFields![0] as UITextField
            debugPrint(textField.text)
            if let text = textField.text, text.count > 3 {
                self.account = text
                self.getTimelineForScreenName()
            }
        }
        
        alert.addTextField { (textField) in
        textField.placeholder = "@... (please enter without @)"
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
}


extension TimelineViewTVC {
    private func authenticate(completionBlock: @escaping () -> ()) {
        if accessToken != nil {
            completionBlock()
        }
        
        let params: [String : Any] = ["grant_type": "client_credentials"]
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                                   "Authorization": "Basic \(getBase64EncodeString())"]
        AF.request("https://api.twitter.com/oauth2/token", method: .post, parameters: params, headers: header)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success( _):
                    do {
                        let token = try JSON(data: response.data!)
                        if let bearerToken = token["access_token"].string {
                            self.accessToken = bearerToken
                            completionBlock()
                        }
                        completionBlock()
                        
                    } catch let error as NSError {
                        print("error: \(error.localizedDescription)")
                        self.showAlert(message: error.localizedDescription)
                    }
                    
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                }
            })
    }
    
    func getBase64EncodeString() -> String {
        let consumerKeyRFC1738 = consumerKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let consumerSecretRFC1738 = consumerSecret.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let concatenateKeyAndSecret = consumerKeyRFC1738! + ":" + consumerSecretRFC1738!
        let secretAndKeyData = concatenateKeyAndSecret.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedString(options: NSData.Base64EncodingOptions())
        return base64EncodeKeyAndSecret!
    }
    
    func getTimelineForScreenName() {
        self._tweets = []
        self.showActivityIndicator()
        authenticate {
            guard let _token = self.accessToken else {
                return
            }
            
            let headers: HTTPHeaders = ["Authorization": "Bearer \(_token)"]
            AF.request(self.baseUrlString + "statuses/user_timeline.json?screen_name=\(self.account)&count=10", headers: headers).validate()
                .responseJSON(completionHandler: {
                    response in
                    switch response.result {
                    case .success( _):
                        do {
                            let tweets = try JSON(data: response.data!)
                            debugPrint(tweets[0])
                            for tweet in tweets.array! {
                                let _tweet = Tweet(data: tweet)
                                self._tweets.append(_tweet)
                            }
                        }
                        catch let error as NSError {
                            print("Error: \(error.localizedDescription)")
                            self.showAlert(message: error.localizedDescription)
                        }
                        
                    case .failure(let error):
                        print("Request error: \(error.localizedDescription)")
                        self.showAlert(message: error.localizedDescription)
                        
                    }
                })
        }
    }
    
    func showAlert(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
           self.present(alert, animated: true, completion: nil)
    }
    
}

extension TimelineViewTVC {
    func showActivityIndicator() {
        DispatchQueue.main.async {
            let activityView = UIActivityIndicatorView(style: .medium)
            
            self.tableView.backgroundView = activityView
            activityView.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.tableView.backgroundView = nil
        }
    }
}
