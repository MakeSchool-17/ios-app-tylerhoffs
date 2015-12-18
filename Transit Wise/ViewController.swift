//
//  ViewController.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/23/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps

class ViewController: UIViewController {
    
    let apiClient = RwtToAPIHelper()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:12, bearing: 30, viewingAngle:60)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        
        self.view = mapView
        // Do any additional setup after loading the view, typically from a nib.
        
        let startName = "University of Pretoria - Hatfield Campus Main Entrance, Pretoria, Gauteng, South Africa"
        let endName = "Pretoria Central, Pretoria, Gauteng, South Africa"
        
        let request = apiClient.getDirectionRequest(-25.7561672, startLong: 28.2289275, startName: startName, endLat: -25.7500498, endLong: 28.1688913, endName: endName)
        let myTrip = Trip()
        print("Sending Request")
        request.validate().responseJSON { response in
            switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        myTrip.JSONinit(json)
                        //myTrip.createPolylines(mapView)
                        print(myTrip.cost)
                    }
                case .Failure(let error):
                    print(error)
                }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testAPI(mapView: GMSMapView){
        let apiClient = RwtToAPIHelper()
        let startName = "Menlyn Park Shopping Centre, Pretoria, South Africa"
        let endName = "Pretoria Central, Pretoria, Gauteng, South Africa"
        
        let request = apiClient.getDirectionRequest(-25.7826769, startLong: 28.2761908, startName: startName, endLat: -25.7500498, endLong: 28.1688913, endName: endName)
        let myTrip = Trip()
        print("Sending Request")
        request.validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    myTrip.JSONinit(json)
                    //myTrip.createPolylines(mapView)
                }
            case .Failure(let error):
                print(error)
            }
        }
        
    }


}

