//
//  MapViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2015/12/11.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import UIKit
import MXParallaxHeader
import GoogleMaps
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {

    @IBOutlet weak var directionsTableView: UITableView!
    let apiClient = RwtToAPIHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:12)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        // Parallax Header Setup
        //let header = mapView
        directionsTableView.parallaxHeader.view = mapView //header
        directionsTableView.parallaxHeader.height = 400
        directionsTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        directionsTableView.parallaxHeader.minimumHeight = 200

        // Do any additional setup after loading the view.
        
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
                    self.apiClient.sendJSONtoTrip(json, trip: myTrip)
                    self.apiClient.attachPathToMapView(myTrip, mapView: mapView)
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
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath)
        cell.textLabel!.text = String(format: "Height %ld", indexPath.row * 10)
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        directionsTableView.parallaxHeader.height = CGFloat(indexPath.row * 10)
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        NSLog("progress %f", scrollView.parallaxHeader.progress)
    }

    deinit {
        self.directionsTableView = nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // self.directionsTableView.removeObserver(self.directionsTableView, forKeyPath: "contentOffset")
        // self.directionsTableView.removeObserver(self.directionsTableView, forKeyPath: "contentInset")
    }
    

}
