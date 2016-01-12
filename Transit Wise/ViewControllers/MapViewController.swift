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
    var myTrip = Trip()
    let myRoute = Routes()
    let apiClient = RwtToAPIHelper()
    var mapView: GMSMapView?
    @IBOutlet weak var directionsTableView: UITableView!
    @IBOutlet weak var departTimeLabel: UILabel!
    @IBOutlet weak var arriveTimeLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        
        self.myTrip.createPolylines(mapView!)
        self.directionsTableView.reloadData()
        self.departTimeLabel.text = "Depart at: " + self.calcTime((self.myTrip.time?.start)!)
        self.arriveTimeLabel.text = "Arrive at: " + self.calcTime((self.myTrip.time?.end)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        let camera = GMSCameraPosition.cameraWithLatitude(-26.15041,
            longitude:28.01562, zoom:16)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        // Parallax Header Setup
        //let header = mapView
        directionsTableView.parallaxHeader.view = mapView //header
        directionsTableView.parallaxHeader.height = 400
        directionsTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        directionsTableView.parallaxHeader.minimumHeight = 200

        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view, typically from a nib.
        
        /* EDGE CASE
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
        } */
        
        /*
        let startName = "Menlyn Park Shopping Centre, Pretoria, South Africa"
        let endName = "Pretoria Central, Pretoria, Gauteng, South Africa"
        
        
        apiClient.getDirectionsCallback(-25.782677, startLong: 28.276191, startName: startName, endLat: -25.7500498, endLong: 28.1688913, endName: endName){ response in
            if response.error == nil{
                self.myRoute.JSONinit(response.json!)
                self.myTrip = self.myRoute.trips![0]
                self.myTrip.createPolylines(mapView)
                self.directionsTableView.reloadData()
                self.departTimeLabel.text = "Depart at: " + self.calcTime((self.myTrip.time?.start)!)
                self.arriveTimeLabel.text = "Arrive at: " + self.calcTime((self.myTrip.time?.end)!)
            }else{
                print(response.error)
            }
        }
        */


    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.myTrip.legs?.count{
            return count + 2
        }
        else{
            return 0
        }
        
    }
    
    //Function to calculate time from minutes from Monday 00:00
    func calcTime(minutes: Int) -> String{
        let timeToday = minutes % 1440
        let minutes = timeToday % 60
        let hours = Int(timeToday/60)
        var timeString = ""
        if(minutes < 10){
            timeString = "\(hours)" + ":0" + "\(minutes)"
        }else{
            timeString = "\(hours)" + ":" + "\(minutes)"
        }
        
        return timeString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
            cell.legNameLabel.text = "Depart"
            cell.legTimeLabel.text = calcTime((self.myTrip.time?.start)!)
            return cell
            
        }
        else if(indexPath.row == ((self.myTrip.legs?.count)! + 1)){
            let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
            cell.legNameLabel.text = "Arrive"
            cell.legTimeLabel.text = calcTime((self.myTrip.time?.end)!)
            return cell
        }
        else if (self.myTrip.legs![indexPath.row-1].pathType == "Walk"){
            let cell = tableView.dequeueReusableCellWithIdentifier("directionCell", forIndexPath: indexPath) as! DirectionCell
            cell.legNameLabel.text = self.myTrip.legs![indexPath.row-1].pathType! + " for  \(self.myTrip.legs![indexPath.row-1].distance!)km"
            cell.legTimeLabel.text = "\((self.myTrip.legs![indexPath.row-1].time?.duration)!)" + " mins"
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("busDirectionCell", forIndexPath: indexPath) as! BusDirectionCell
            cell.busNameLabel.text = self.myTrip.legs![indexPath.row-1].route
            cell.busStopStart.text = self.myTrip.legs![indexPath.row-1].fromName
            cell.busStopEnd.text = self.myTrip.legs![indexPath.row-1].toName
            cell.legStartTimeLabel.text = calcTime((self.myTrip.legs![indexPath.row-1].time?.start)!)
            print((self.myTrip.legs![indexPath.row-1].time?.start)!)
            cell.legArriveTimeLabel.text = calcTime((self.myTrip.legs![indexPath.row-1].time?.end)!)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        print((self.myTrip.legs?.count)!)
        if(indexPath.row == 0){
            return 40
        }
        else if(indexPath.row == ((self.myTrip.legs?.count)! + 1)){
            return 40
        }
        else if (self.myTrip.legs![indexPath.row-1].pathType == "Walk"){
            return 40
        }else{
            return 93
        }
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
