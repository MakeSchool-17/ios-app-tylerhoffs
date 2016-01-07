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
    
    typealias ApiCallback = (json: JSON?, error: NSError?) -> Void
    typealias CoordinatesCallback = (place: GMSPlace?, error: NSError?) -> Void
    
    //MARK: API Calls
    
    /**
    Will get the directions from API
    
    - parameter startLat:  Latitdue of Starting point
    - parameter startLong: Longitude of Starting point
    - parameter startName: Name of Starting point
    - parameter endLat:    Latitude of Ending point
    - parameter endLong:   Longitude of Ending point
    - parameter endName:   Name of Ending point
    
    */
    func getDirectionsCallback(startLat: Float, startLong: Float, startName: String, endLat: Float, endLong: Float, endName: String, callback: ApiCallback){
        
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
        
        request.validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    callback(json: json, error: nil)
                }
            case .Failure(let error):
                callback(json: nil, error: error)
            }
        }
    }
    
    /**
     Get latest options data from Rwt.to
     
     - parameter callback: callback once response of options received from Rwt.To api
     */
    func getOptionsCallback(callback: ApiCallback) {
        let request = Alamofire.request(.GET, "https://rwt.to/api/v1/options")
        request.validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    callback(json: json, error: nil)
                }
            case .Failure(let error):
                callback(json: nil, error: error)
            }
        }
    }
    
    /**
     Call API endpoint to get list of all nearby stations
     
     - parameter lat:  Latitude of current position
     - parameter long: Longitude of currenct position
     
     - returns: Array of Stations
     */
    func getNearbyStation(lat: Float, long: Float, callback: ApiCallback){
        //TODO: Get correct URL for nearest stations
        let request = Alamofire.request(.GET, "https://rwt.to/api/v1/stations")
        request.validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    callback(json: json, error: nil)
                }
            case .Failure(let error):
                callback(json: nil, error: error)
            }
        }
    }
    
    
    //MARK: External API calls
    
    /**
    Get Google's walking directions
    
    - parameter start:    starting coordinates
    - parameter end:      destination coordinates
    - parameter callback: Callback once response received from Google API
    */
    func getWalkingPath(start: Path.Coordinates, end: Path.Coordinates, callback: ApiCallback){
        //let headers    = ["app": "testing", "Content-Type": "application/json"]
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.lat!),\(start.long!)&destination=\(end.lat!),\(end.long!)&mode=walking&key=AIzaSyDleSjXuhdbMEO4-yGlrnNkvWu1chkotsI"
        
        let request = Alamofire.request(.GET, url)
        
        request.validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    callback(json: json, error: nil)
                }
            case .Failure(let error):
                callback(json: nil, error: error)
            }
        }
        
    }
    
    
    func getPlaceDetailsFromID(placeID: String, callback: CoordinatesCallback){
        let placesClient = GMSPlacesClient()
        placesClient.lookUpPlaceID(placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                callback(place: nil, error: error)
                return
            }
            
            if let place = place {
                callback(place: place, error: nil)
            } else {
                print("No place details for \(placeID)")
            }
        })
        
    }
    
}