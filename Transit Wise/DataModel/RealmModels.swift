//
//  RealmModels.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/9/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import RealmSwift
import CoreLocation


/// Realm Object to store Available Agencies
class RealmAgency: Object {
    dynamic var _id: String? = nil
    dynamic var name: String? = nil
    dynamic var tel: String? = nil
    dynamic var email: String? = nil
    dynamic var web: String? = nil
    dynamic var address: String? = nil
    
    override static func indexedProperties() -> [String] {
        return ["_id"]
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}

/// Realm Object to store available transport categories
class RealmCategories: Object{
    dynamic var _id: String? = nil
    dynamic var name: String? = nil
    
    override static func indexedProperties() -> [String] {
        return ["_id"]
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}

/// Realm object to store the users data
class UserData: Object{
    var home: CLLocationCoordinate2D? = nil
}

class RecentSearches: Object{
    let lat = RealmOptional<Double>()
    let long = RealmOptional<Double>()
    dynamic var name: String? = nil
}