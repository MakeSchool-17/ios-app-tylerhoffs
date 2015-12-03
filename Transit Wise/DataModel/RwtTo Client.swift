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
    
//MARK: API Calls
    
    /**
    Get Request object which will get JSON response containing direction details from start to end
    
    - parameter startLat:  Latitdue of Starting point
    - parameter startLong: Longitude of Starting point
    - parameter startName: Name of Starting point
    - parameter endLat:    Latitude of Ending point
    - parameter endLong:   Longitude of Ending point
    - parameter endName:   Name of Ending point
    
    - returns: Alomofire request which will be used to complete the request action where it is being called
    */
    func getDirectionRequest(startLat: Float, startLong: Float, startName: String, endLat: Float, endLong: Float, endName: String) -> Alamofire.Request{
        
        
        let headers    = ["app": "testing", "Content-Type": "application/json"]
        let parameters = ["start":
                            ["loc": [startLat,startLong], "name": startName],
                         "end":
                            ["loc": [endLat,endLong], "name": endName],
                         "options":
                            ["exclude":
                                ["agencies": getAgencyExcludes(), "cats": getCategoryExcludes()]],
                         "time": 900,
                         "_csrf": "Unathi Xcode"]

        let request    = Alamofire.request(.POST, "https://rwt.to/api/site/directions", parameters: parameters, encoding: .JSON, headers: headers)

        return request
    }
    
    /**
     Call API endpoint to get agencies to exclude
     
     - returns: Array of Agency IDs to exclude
     */
    func getAgencyExcludes() -> [String]{
        return ["52ca9f657d327c6b04000010", "529751763ca4da973400000d"]
    }
    
    /**
     Call API endpoint to get categories to exclude
     
     - returns: Array of categories to excldue
     */
    func getCategoryExcludes() -> [String]{
        return []
    }
    
    /**
     Call API endpoint to get list of all nearby stations
     
     - parameter lat:  Latitude of current position
     - parameter long: Longitude of currenct position
     
     - returns: Array of Stations
     */
    func getNearbyStation(lat: Float, long: Float) -> [Station]{
        return []
    }

//MARK: JSON parsing calls
    
    /**
    Will parse all JSON into received Trip object
    
    - parameter json: JSON data that needs to be parsed
    - parameter trip: Trip object to be updated
    */
    func sendJSONtoTrip(json: JSON, trip: Trip){
        trip.JSONinit(json)
    }
    
    

}