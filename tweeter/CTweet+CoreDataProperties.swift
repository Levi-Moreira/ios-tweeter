//
//  CTweet+CoreDataProperties.swift
//  tweeter
//
//  Created by ifce on 9/14/17.
//  Copyright © 2017 ifce. All rights reserved.
//

import Foundation
import CoreData


extension CTweet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CTweet> {
        return NSFetchRequest<CTweet>(entityName: "CTweet");
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var created_at: String?
    @NSManaged public var updated_at: String?
    


}
