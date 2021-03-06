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
    
    
    /**
     Get Number of minutes that have passed since Monday 00:00.
     
     - returns: minutes returned as integer
     */
    func getCurrentMinutes()->Int {
        
        let myCalendar = NSCalendar.currentCalendar()
        var myComponents = myCalendar.components(.Weekday, fromDate: NSDate())
        let weekDay = myComponents.weekday
        myComponents = myCalendar.components(.Hour, fromDate: NSDate())
        let hour = myComponents.hour
        myComponents = myCalendar.components(.Minute, fromDate: NSDate())
        let minute = myComponents.minute
        return ((weekDay-1)*1440 + (hour*60) + minute)
    }
    
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
    func getDirectionsCallback(startLat: Double, startLong: Double, startName: String, endLat: Double, endLong: Double, endName: String, callback: ApiCallback){
        let time = getCurrentMinutes()
        let headers    = ["app": "testing", "Content-Type": "application/json"]
        let params = ["start":
            ["loc": [startLat,startLong], "name": startName],
            "end":
                ["loc": [endLat,endLong], "name": endName],
            "options":
                ["exclude":
                    ["agencies": [], "cats": []]],
            "time": time,
            "_csrf": "Transit Wise iOS App",
            "multiple": true]
        
        let request    = Alamofire.request(.POST, "https://rwt.to/api/site/directions", parameters: params as? [String : AnyObject], encoding: .JSON, headers: headers)
        
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
    func getNearbyStation(lat: Double, long: Double, callback: ApiCallback){
        
        //let params = ["loc": [lat,long]]
        let request = Alamofire.request(.GET, "https://rwt.to/api/v1/nearby/stops?loc=[\(lat),\(long)]")
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
    
    /**
     Get details of a location using GMSPlaceID
     
     - parameter placeID:  placeID from GMSPlaceID
     - parameter callback: Callback once response received
     */
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