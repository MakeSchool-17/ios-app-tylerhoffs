//
//  RwtTo Client.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/25/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RwtToApiClient{
    
    
    func callAPI() -> Alamofire.Request{
        
        
        let headers = ["app": "testing", "Content-Type": "application/json"]
        let parameters = ["start": ["loc": [-25.7561672,28.2289275], "name": "University of Pretoria - Hatfield Campus Main Entrance, Pretoria, Gauteng, South Africa"],
            "end": ["loc": [-25.7500498,28.1688913], "name": "Pretoria Central, Pretoria, Gauteng, South Africa"],
            "options": ["exclude": ["agencies": ["52ca9f657d327c6b04000010", "529751763ca4da973400000d"], "cats":[]]],
            "time": 900,
            "_csrf": "Unathi Xcode"]

        let request = Alamofire.request(.POST, "https://rwt.to/api/site/directions", parameters: parameters, encoding: .JSON, headers: headers)
        
        return request
    }
    
    func sendJSONtoTrip(json: JSON, trip: Trip){
        trip.JSONinit(json)
    }

}