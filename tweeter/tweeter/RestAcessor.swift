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
    
    //for making callback requests to the view controller
    var restResponderDelegate : RestResponderDelegate?
    
    init() {
        
    }
    
    
    //Makes ab URL request to the server and returns a list of Tweets, or returns if an error occurs
    func requestList(){
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
            
                var tweets = [Tweet]()
            
                if let convertedJson = json{
                    for case let result in convertedJson{
                        if let tweet = Tweet(json: result as! [String : Any]){
                            tweets.append(tweet)
                        }
                    }
                }

            
                DispatchQueue.main.async {
                    self.restResponderDelegate?.getListResponse(tweets: tweets)
                }
                
            }
        }
        
        task.resume()
        
    }
    
    
    //Makes an URL request to the server in order to delete a Tweet
    func requestDeleteTweet(tweetID : String, pos : IndexPath){
        
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
                        self.restResponderDelegate?.deleteTweetResponse(position : pos)
                    }
                }
            }
   
        }
        
        task.resume()

    }
    
    
    //Makes an URL request to create a tweet, returns the recently created tweet to the view controller through the delegate
    func requestCreateTweet(tweet : Tweet){
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
                        
                            if let tweet = Tweet(json: convertedJson){
                                DispatchQueue.main.async {
                                    self.restResponderDelegate?.postResponse(tweet: tweet)
                                }
                            }
                        
                    }
                    
                }
            }
            
            task.resume()

        
        }
    }
    
    func requestEditTweet(tweet : Tweet){
        
    }
    
}


// Protocol for creating callbacks to the main view controller
protocol RestResponderDelegate{
    func getListResponse(tweets: [Tweet])
    func deleteTweetResponse(position : IndexPath)
    func postResponse(tweet: Tweet)
    func editResponse(tweet : Tweet)
}
