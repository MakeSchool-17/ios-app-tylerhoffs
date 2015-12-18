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
import GoogleMaps

class RwtToAPIHelper{
    
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
                    ["agencies": [], "cats": []]],
            "time": 900,
            "_csrf": "Unathi Xcode"]
        
        let request    = Alamofire.request(.POST, "https://rwt.to/api/site/directions", parameters: parameters, encoding: .JSON, headers: headers)
        
        return request
    }
    
    
    func getOptions() -> Alamofire.Request{
        let request = Alamofire.request(.GET, "https://rwt.to/api/v1/options")
        
        return request
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
    
    
    //MARK: External API calls
    func getWalkingPath(start: Path.Coordinates, end: Path.Coordinates) -> Alamofire.Request{
        //let headers    = ["app": "testing", "Content-Type": "application/json"]
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.lat!),\(start.long!)&destination=\(end.lat!),\(end.long!)&mode=walking&key=AIzaSyDleSjXuhdbMEO4-yGlrnNkvWu1chkotsI"
        
        let request = Alamofire.request(.GET, url)
        return request
    }
    
}