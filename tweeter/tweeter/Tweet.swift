//
//  Tweet.swift
//  tweeter
//
//  Created by ifce on 11/09/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import Foundation


class Tweet{
    var _id : String
    var text: String
    var lat : Double
    var long : Double
    var created_at : String
    var updated_at: String
    
    init(_id: String, text: String, lat : Double, long : Double, created_at:String, updated_at : String) {
        self._id = _id
        self.text = text
        self.lat = lat
        self.long = long
        self.created_at = created_at
        self.updated_at = updated_at
    }
    
    init?(json: [String: Any]) {
        
        guard let id = json["_id"] as? String,
            let text = json["text"] as? String,
            let latitude = json["lat"] as? Double,
            let longitude = json["long"] as? Double,
            let creation = json["created_at"] as? String,
            let update = json["updated_at"] as? String
            else{
                return nil
        }
        
        self._id = id
        self.text = text
        self.lat = latitude
        self.long = longitude
        self.created_at = creation
        self.updated_at = update
        
        
    }
    
    func toJson() -> [String : Any ] {
        var json = [String : Any]()
        json["text"] = text
        json["latitude"] = lat
        json["longitude"] = long
        
        return json
    }
    
    
}
