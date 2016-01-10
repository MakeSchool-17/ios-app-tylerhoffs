//
//  Options.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 12/10/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import Mapper
/**
 *  Structures to store available options from RwtTo Api. 
 */

struct Options: Mappable{
    var agencies: [Agencies]?
    var categories: [Categories]?
    
    init(map: Mapper) throws {
        agencies = map.optionalFrom("agencies") ?? []
        categories = map.optionalFrom("categories") ?? []
        }
}
    struct Agencies: Mappable{
        let _id: String
        let name: String
        let contact: Contact
        
        init(map: Mapper) throws {
            try _id = map.from("_id")
            try name = map.from("name")
            try contact = map.from("contact")
        }
        
    }
    
    struct Categories: Mappable{
        let name: String
        let _id: String
        
        init(map: Mapper) throws {
            try name = map.from("name")
            try _id = map.from("_id")
        }
    }
    
    struct Contact: Mappable{
        let tel: String?
        let email: String?
        let web: String?
        let address: String?
        
        init(map: Mapper) throws {
            tel = map.optionalFrom("tel")
            email = map.optionalFrom("email")
            web = map.optionalFrom("web")
            address = map.optionalFrom("addr")
        }
    }