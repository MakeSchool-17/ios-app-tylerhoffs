//
//  SearchLocation.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/6/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import Foundation

/// Structure to store information that will be required when making API call to search for directions
class SearchLocation{
    var lat: Double?
    var long: Double?
    var name: String? = "blank"
    let apiHelper = RwtToAPIHelper()
    typealias SearchCallback = (error: NSError?) -> Void
    
    /**
     set the values of location use a placeID
     
     - parameter placeID: GMSPlace.placeID of location
     */
    func setFromID(placeID: String, callback: SearchCallback){
        apiHelper.getPlaceDetailsFromID(placeID){ response in
            if response.error == nil{
                self.lat = (response.place?.coordinate.latitude)!
                self.long = (response.place?.coordinate.longitude)!
                self.name = (response.place?.name)!
                callback(error: nil)
            }else{
                print(response.error)
                callback(error: response.error)
            }
        }
    }
    
}