//
//  RestAcessor.swift
//  tweeter
//
//  Created by levi on 11/09/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct RestAcessor {
    
    let baseURL = "https://ios-twitter.herokuapp.com"
    let apiURL = "/api/v2/message"
    let backbar = "/"
    
    //Makes ab URL request to the server and returns a list of Tweets, or returns if an error occurs
    func performGetList(completionHandler: @escaping (_ tweets: [CTweet]) -> Void ){
        
        let currentlySaved = CTweet.getAllRecords()
        
        let completeURL = baseURL + apiURL
 
        
        Alamofire.request(completeURL).responseJSON { (response) in
            if let json = response.result.value {
                
                var tweets = [CTweet]()
                
                for case let result in json as! [Any]{
                    
                    let jsonFormated = result as! [String : Any]
                    
                    if let id = jsonFormated["_id"] as? String,
                        let text = jsonFormated["text"] as? String,
                        let latitude = jsonFormated["lat"] as? Double,
                        let longitude = jsonFormated["long"] as? Double,
                        let creation = jsonFormated["created_at"] as? String,
                        let update = jsonFormated["updated_at"] as? String{
                        
                        
                        
                        let foundTweet = currentlySaved?.filter({
                            $0.id == id
                        })
                        
                        if foundTweet?.count == 0{
                            let tweet = CTweet.create()
                            tweet.id = id
                            tweet.text = text
                            tweet.latitude = latitude
                            tweet.longitude = longitude
                            tweet.created_at = creation
                            tweet.updated_at = update
                            tweets.append(tweet)
                        }else{
                            tweets.append((foundTweet?.first)!)
                        }
                        
                    }
                    else{
                        print("unwrapping error")
                        
                    }
                }

                
                completionHandler(tweets)
            }
        }

    }
    
    
    //Makes an URL request to the server in order to delete a Tweet
    func performTweetDelete(tweetID : String, pos : IndexPath, completionHandler: @escaping (_ path: IndexPath) -> Void){
        
        let completeURL = baseURL + apiURL + backbar + tweetID
        
        
        Alamofire
            .request(completeURL, method: .delete)
            .validate(statusCode: 200..<300)
            .response { (response) in
                completionHandler(pos)

        }
        
    }
    
    
    //Makes an URL request to create a tweet, returns the recently created tweet to the view controller through the delegate
    func performCreateTweet(tweet : CTweet, completionHandler : @escaping (_ tweet: CTweet) -> Void){
        
        let completeURL = baseURL + apiURL
        
        
        Alamofire
            .request(completeURL, method: .post, parameters: tweet.toJson(), encoding: JSONEncoding.default)
            .responseJSON(completionHandler: { (response) in

                if let convertedJson = response.result.value{
 
                    let tweet = CTweet.create()
                    let jsonFormated = convertedJson as! [String: Any]
                    
                    if let id = jsonFormated["_id"] as? String,
                        let text = jsonFormated["text"] as? String,
                        let latitude = jsonFormated["lat"] as? Double,
                        let longitude = jsonFormated["long"] as? Double,
                        let creation = jsonFormated["created_at"] as? String,
                        let update = jsonFormated["updated_at"] as? String{
                        
                        tweet.id = id
                        tweet.text = text
                        tweet.latitude = latitude
                        tweet.longitude = longitude
                        tweet.created_at = creation
                        tweet.updated_at = update
                        
                        
                        completionHandler(tweet)
                        
                    }
                    else{
                        print("unwrapping error")
                        
                    }
                    
                }
            })
        }
    

    
    func performEditTweet(tweet : CTweet, position : IndexPath, completionHandler: @escaping (_ path: IndexPath)-> Void){

            let completeURL = baseURL + apiURL + backbar + tweet.id!
            
            Alamofire
                .request(completeURL, method: .put, parameters: tweet.toJson(), encoding: JSONEncoding.default)
                .responseJSON(completionHandler: { (response) in
                    if let json = response.result.value{
                        let convertedJson = json as! [String: Any]
                        
                        if let update = convertedJson["update"]{
                                if update as? Bool == true{
                                    completionHandler(position)
                                    
                                }
                                
                            }
                    }
                })
    }
    
}



