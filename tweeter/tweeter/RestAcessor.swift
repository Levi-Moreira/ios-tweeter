//
//  RestAcessor.swift
//  tweeter
//
//  Created by ifce on 11/09/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import Foundation

struct RestAcessor {
    
    let baseURL = "https://ios-twitter.herokuapp.com"
    let apiURL = "/api/v2/message"
    var restResponderDelegate : RestResponderDelegate?
    
    init() {
        
    }
    
    func requestList(){
        let completeURL = baseURL + apiURL
        let requestURL = URL(string: completeURL)
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            if error != nil{
                print("Error")
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
            
            var tweets = [Tweet]()
            for case let result in json!!{
                if let tweet = Tweet(json: result as! [String : Any]){
                    tweets.append(tweet)
                }
            }
            
//            print(tweets)
            
//            let responseString = String(data: data!, encoding: .utf8)
            
            self.restResponderDelegate?.getListResponse(tweets: tweets)
        }
        
        task.resume()
        
    }
    
    func requestDeleteTweet(){
        
    }
    
    func requestCreateTweet(){
        
    }
    
    func requestEditTweet(){
        
    }
    
}


protocol RestResponderDelegate{
    func getListResponse(tweets: [Tweet])
    func deleteTweetResponse(tweet : Tweet)
    func postResponse()
    func editResponse(tweet : Tweet)
}
