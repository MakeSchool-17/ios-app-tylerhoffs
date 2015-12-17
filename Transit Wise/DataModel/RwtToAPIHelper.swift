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
    func attachPathToMapView(trip: Trip, mapView: GMSMapViewWithPolyHistory){
        
        for leg in trip.legs!{
            if leg.pathType! == "Group"{
                for innerLeg in leg.legs!{
                    workWithLeg(innerLeg, mapView: mapView)
                }
            }else{
                workWithLeg(leg, mapView: mapView)
            }
        }
        
    }
    
    /**
     Add path of single leg onto map
     
     - parameter leg:     Leg object containing leg to be addded to map
     - parameter mapView: GMSMapViewWithPolyHistory object that leg should be placed on
     */
    func workWithLeg(leg: Leg, mapView: GMSMapViewWithPolyHistory){

        let polyline = GMSPolyline()
        
        if leg.pathType == "Walk"{
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
                        polyline.strokeWidth = 4
                        polyline.map = mapView
                        mapView.polylines?.append(polyline) //FIXME: Does not append
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }else{
            let path = GMSMutablePath()
            
            switch leg.pathType!{
            case "Bus":
                polyline.strokeColor = UIColor.blueColor()
            case "Rail":
                polyline.strokeColor = UIColor.yellowColor()
            default:
                polyline.strokeColor = UIColor.blueColor()
            }
            
            for point in (leg.path?.points)!{
                path.addLatitude(point.lat!, longitude: point.long!)
            }
            polyline.path = path
            
            polyline.strokeWidth = 4
            polyline.map = mapView
            mapView.polylines?.append(polyline) //FIXME: Does not append
        }
        
        //TODO: Add marker for legs to decribe?

    }
    
//MARK: External API calls
    func getWalkingPath(start: Path.Coordinates, end: Path.Coordinates) -> Alamofire.Request{
        //let headers    = ["app": "testing", "Content-Type": "application/json"]
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.lat!),\(start.long!)&destination=\(end.lat!),\(end.long!)&mode=walking&key=AIzaSyDleSjXuhdbMEO4-yGlrnNkvWu1chkotsI"
        
        let request = Alamofire.request(.GET, url)
        return request
    }

}