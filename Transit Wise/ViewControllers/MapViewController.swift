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
    let myTrip = Trip()

    @IBOutlet weak var directionsTableView: UITableView!
    let apiClient = RwtToAPIHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.cameraWithLatitude(-26.15041,
            longitude:28.01562, zoom:12)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        // Parallax Header Setup
        //let header = mapView
        directionsTableView.parallaxHeader.view = mapView //header
        directionsTableView.parallaxHeader.height = 400
        directionsTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        directionsTableView.parallaxHeader.minimumHeight = 200

        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let startName = "11 Greenfield Rd, Randburg"
        let endName = "9 Florence Ave, Germiston"
        
        
        apiClient.getDirectionsCallback(-26.15041, startLong: 28.01562, startName: startName, endLat: -26.1696916, endLong: 28.138237, endName: endName){ response in
            if response.error == nil{
                self.myTrip.JSONinit(response.json!)
                self.myTrip.createPolylines(mapView)
                self.directionsTableView.reloadData()
            }else{
                print(response.error)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.myTrip.legs?.count{
            return count
        }
        else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
        cell.legNameLabel.text = self.myTrip.legs![indexPath.row].instructions
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //directionsTableView.parallaxHeader.height = CGFloat(indexPath.row * 10)
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //NSLog("progress %f", scrollView.parallaxHeader.progress)
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
