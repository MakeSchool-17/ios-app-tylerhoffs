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
            realmAgency.filter_state = RealmOptional<Bool>(true)
            
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
    
    func getAgencies() -> [Agency]{
        let agencies = realm.objects(RealmAgency)
        var returnList: [Agency] = []
        for agency in agencies{
            returnList.append(Agency(name: agency.name, id: agency._id, url: agency.web, filter: agency.filter_state.value))
        }
        
        return returnList
    }
    
    func switchAgencyFilterState(id: String, state: Bool){
        let agencies = realm.objects(RealmAgency).filter("_id = '\(id)'")
        try! realm.write{
            realm.create(RealmAgency.self, value: ["_id": agencies[0]._id!, "filter_state": state], update: true)
        }
    }
    
    func clearAllPersistance(){
        try! realm.write {
            realm.deleteAll()
        }
    }
}
