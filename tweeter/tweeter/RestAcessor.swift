//
//  RestAcessor.swift
//  tweeter
//
//  Created by levi on 11/09/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import Foundation

struct RestAcessor {
    
    
    
    let baseURL = "https://ios-twitter.herokuapp.com"
    let apiURL = "/api/v2/message"
    let backbar = "/"
    
    
    init() {
        
    }
    
    
    //Makes ab URL request to the server and returns a list of Tweets, or returns if an error occurs
    func performGetList(completionHandler: @escaping (_ tweets: [CTweet]) -> Void ){
        
        let currentlySaved = CTweet.getAllRecords()
        
        let completeURL = baseURL + apiURL
        let requestURL = URL(string: completeURL)
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            if error != nil{
                print("Error when requesting a list of tweets. Sorry")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [Any]{
            
                var tweets = [CTweet]()
            
                if let convertedJson = json{
                    for case let result in convertedJson{
                        
                        let jsonFormated = result as! [String : Any]
                        
                         if let id = jsonFormated["_id"] as? String,
                            let text = jsonFormated["text"] as? String,
                            let latitude = jsonFormated["lat"] as? Double,
                            let longitude = jsonFormated["long"] as? Double,
                            let creation = jsonFormated["created_at"] as? String,
                            let update = jsonFormated["updated_at"] as? String{
                            
                            //check here if it exists in the database already
                                let tweet = CTweet.create()
                                tweet.id = id
                                tweet.text = text
                                tweet.latitude = latitude
                                tweet.longitude = longitude
                                tweet.created_at = creation
                                tweet.updated_at = update
                        
                                tweets.append(tweet)
                            }
                            else{
                                print("unwrapping error")
                                
                            }
                    }
                }

            
                DispatchQueue.main.async {
                    completionHandler(tweets)
                }
                
            }
        }
        
        task.resume()
        
    }
    
    
    //Makes an URL request to the server in order to delete a Tweet
    func performTweetDelete(tweetID : String, pos : IndexPath, completionHandler: @escaping (_ path: IndexPath) -> Void){
        
        let completeURL = baseURL + apiURL + backbar + tweetID
        let requestURL = URL(string: completeURL)
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            if error != nil{
                print("Error when deleting the tweet. Nothing will be affected")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 200{
                    DispatchQueue.main.async {
                        completionHandler(pos)
                    }
                }
            }
   
        }
        
        task.resume()

    }
    
    
    //Makes an URL request to create a tweet, returns the recently created tweet to the view controller through the delegate
    func performCreateTweet(tweet : CTweet, completionHandler : @escaping (_ tweet: CTweet) -> Void){
        if let jsonData = try? JSONSerialization.data(withJSONObject: tweet.toJson(), options: []) {
            
            
            let completeURL = baseURL + apiURL
            let requestURL = URL(string: completeURL)
            var request = URLRequest(url: requestURL!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            request.httpBody = jsonData


            let task = URLSession.shared.dataTask(with: request){
                data, response, error in
                
                if error != nil{
                    print("Error when creating a new Tweet. Nothing will happen")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]{
                    
                    
                    if let convertedJson = json{
                        
                        let tweet = CTweet.create()
                        let jsonFormated = convertedJson 
                        
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
                            
                            DispatchQueue.main.async {
                                
                                completionHandler(tweet)
                            }
                        }
                        else{
                            print("unwrapping error")
                            
                        }

    
                        
                    }
                    
                }
            }
            
            task.resume()

        
        }
    }
    
    func performEditTweet(tweet : CTweet, position : IndexPath, completionHandler: @escaping (_ path: IndexPath)-> Void){
        if let jsonData = try? JSONSerialization.data(withJSONObject: tweet.toJson(), options: []) {
            
            
            let completeURL = baseURL + apiURL + backbar + tweet.id!

            let requestURL = URL(string: completeURL)
            var request = URLRequest(url: requestURL!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            
            
            let task = URLSession.shared.dataTask(with: request){
                data, response, error in
                
                if error != nil{
                    print("Error when creating a new Tweet. Nothing will happen")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]{
                    
                    
                    if let convertedJson = json{
                        
                        if let update = convertedJson["update"]{
                            
                            if update as? Bool == true{
                                DispatchQueue.main.async {

                                    completionHandler(position)
                                }
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            task.resume()
            
        }

    }
    
}



