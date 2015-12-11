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

//MARK: JSON parsing calls
    
    /**
    Will parse all JSON into received Trip object
    
    - parameter json: JSON data that needs to be parsed
    - parameter trip: Trip object to be updated
    */
    func sendJSONtoTrip(json: JSON, trip: Trip){
        trip.JSONinit(json)
    }
    
    /**
     Draw Path on Google Map View
     
     - parameter trip:    Trip object reference to the trip that contains the path
     - parameter mapView: MapView that the path should be drawn on.
     */
    func attachPathToMapView(trip: Trip, mapView: GMSMapView){
        
        for leg in trip.legs!{

            let polyline = GMSPolyline()
            
            switch leg.pathType!{
                case "Walk":
                    polyline.strokeColor = UIColor.greenColor()
                    var path: GMSPath = GMSPath()
                    
                    let request = self.getWalkingPath((leg.path?.points![0])!, end: (leg.path?.points![1])!)
                    
                    request.validate().responseJSON { response in
                        switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                let encodedRoute = json["routes"][0]["overview_polyline"]["points"].stringValue
                                path = GMSPath(fromEncodedPath: encodedRoute)
                                polyline.path = path
                                polyline.strokeWidth = 3.5
                                polyline.tappable = true
                                polyline.map = mapView
                            }
                        case .Failure(let error):
                            print(error)
                        }
                    }
                case "Bus":
                    let path = GMSMutablePath()
                    polyline.strokeColor = UIColor.blueColor()
                    for point in (leg.path?.points)!{
                        path.addLatitude(point.lat!, longitude: point.long!)
                    }
                    polyline.path = path
                case "Rail":
                    let path = GMSMutablePath()
                    polyline.strokeColor = UIColor.yellowColor()
                    for point in (leg.path?.points)!{
                        path.addLatitude(point.lat!, longitude: point.long!)
                    }
                    polyline.path = path
                default:
                    let path = GMSMutablePath()
                    polyline.strokeColor = UIColor.blueColor()
                    for point in (leg.path?.points)!{
                        path.addLatitude(point.lat!, longitude: point.long!)
                    }
                    polyline.path = path
            }
            
            polyline.strokeWidth = 3.5
            polyline.tappable = true
            polyline.map = mapView
        }
        
    }
    
//MARK: External API calls
    func getWalkingPath(start: Path.Coordinates, end: Path.Coordinates) -> Alamofire.Request{
        //let headers    = ["app": "testing", "Content-Type": "application/json"]
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.lat!),\(start.long!)&destination=\(end.lat!),\(end.long!)&mode=walking&key=AIzaSyDleSjXuhdbMEO4-yGlrnNkvWu1chkotsI"
        
        let request = Alamofire.request(.GET, url)
        return request
    }

}