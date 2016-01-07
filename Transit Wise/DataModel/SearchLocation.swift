//
//  SearchLocation.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 1/6/16.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import Foundation

class SearchLocation{
    var lat: Float?
    var long: Float?
    var name: String? = "blank"
    let apiHelper = RwtToAPIHelper()
    
//    func setFromID(placeID: String){
//        apiHelper.getPlaceDetailsFromID(placeID){ response in
//            if response.error == nil{
//                self.lat = Float((response.place?.coordinate.latitude)!)
//                self.long = Float((response.place?.coordinate.longitude)!)
//                self.name = (response.place?.name)!
//            }else{
//                print(response.error)
//            }
//        }
//    }
    
}