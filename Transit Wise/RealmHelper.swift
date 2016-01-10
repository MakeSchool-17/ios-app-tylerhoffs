//
//  RealmHelper.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/9/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import RealmSwift

class RealmHelper{
    let realm = try! Realm()
    
    func persistOptions(apioptions: Options){
        for agency in apioptions.agencies!{
            let realmAgency = RealmAgency()
            realmAgency._id = agency._id
            realmAgency.name = agency.name
            realmAgency.tel = agency.contact.tel
            realmAgency.email = agency.contact.email
            realmAgency.web = agency.contact.web
            realmAgency.address = agency.contact.address
            
            try! realm.write{
                realm.add(realmAgency, update: true)
            }
        }
        
        for category in apioptions.categories!{
            let realmCategory = RealmCategories()
            realmCategory._id = category._id
            realmCategory.name = category.name

            
            try! realm.write{
                realm.add(realmCategory, update: true)
            }
        }
    }
}
