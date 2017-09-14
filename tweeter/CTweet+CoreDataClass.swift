//
//  CTweet+CoreDataClass.swift
//  tweeter
//
//  Created by ifce on 9/14/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import UIKit
import CoreData


public class CTweet: NSManagedObject {
    
    public static let persistentContainer : NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer


    
    func toJson() -> [String : Any ] {
        var json = [String : Any]()
        json["text"] = text
        json["latitude"] = latitude
        json["longitude"] = longitude
        
        return json
    }
    
    class func getAllRecords() -> [CTweet]? {
        let context = persistentContainer.viewContext
        var peopleArray: [CTweet]?
        do {
            try peopleArray = context.fetch(CTweet.fetchRequest()) as? [CTweet]
        } catch {
            print("Erro")
        }
        return peopleArray
    }
    
    
    class func create() -> CTweet {
        let entity = NSEntityDescription.entity(forEntityName: "CTweet", in: persistentContainer.viewContext)
        let tweet = CTweet(entity: entity!, insertInto: persistentContainer.viewContext)
        return tweet
    }
    
    func delete() {
        let context = CTweet.persistentContainer.viewContext
        context.delete(self)
    }
    
    
    
    class func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}
