//
//  HomeViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2015/12/07.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import UIKit
import MXParallaxHeader
import GoogleMaps
import CoreLocation

class HomeViewController: UIViewController,CLLocationManagerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tripPlannerView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var tripPlannerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    var viewDown: Bool = false
    var locationManager = CLLocationManager()
    var mapView : GMSMapView?
    var didFindMyLocation: Bool = true
    var tableViewStatus = 0
    var searchActive = false
    var pickedPlace: GMSPlace?
    var placesClient: GMSPlacesClient?
    var predictions: [GMSAutocompletePrediction]?
    let regularFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
    let boldFont = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        placesClient = GMSPlacesClient()
        
        mainTableView.rowHeight = 100
        mainTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:12)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        //Locaition Manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        // Parallax Header Setup
        let header = mapView
        mainTableView.parallaxHeader.view = header
        mainTableView.parallaxHeader.height = 400
        mainTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        mainTableView.parallaxHeader.minimumHeight = 200
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tripPlannerView.addGestureRecognizer(tap)
        //mapView?.addGestureRecognizer(tap)


    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView!.myLocationEnabled = true
        }
    }
    
   /* func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    } */
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let predictions = predictions{
            return predictions.count
        }else if (tableViewStatus == 1){
            return 0
        }else{
            return 20 // TODO: Get Stations List
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifier = ""
        //var cell: UITableViewCell
        
        if (tableViewStatus == 0){
            identifier = "busStopCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! BusStopCell
            return cell
        }
        else if(tableViewStatus == 1){
            identifier = "searchCell"
            
            let bolded = predictions![indexPath.row].attributedPrimaryText.mutableCopy() as! NSMutableAttributedString
            bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? self.regularFont : self.boldFont
                bolded.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            let city = predictions![indexPath.row].attributedSecondaryText.mutableCopy() as! NSMutableAttributedString
            city.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, city.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? self.regularFont : self.boldFont
                city.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SearchCell
            
            cell.addressLabel?.attributedText = bolded
            cell.cityLabel?.attributedText = city

            return cell
            
        }
        else{
            identifier = "recentCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            return cell
        }
        
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedWaypoint = waypoints[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.performSegueWithIdentifier("ShowTrip", sender: self)
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        NSLog("progress %f", scrollView.parallaxHeader.progress)
    }
    
    // MARK: - Button Actions
    
    @IBAction func directionButtonTap(sender: UIButton) {
        if(!self.viewDown){
            self.view.endEditing(true)
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                var tripPlannerFrame = self.tripPlannerView.frame
                tripPlannerFrame.origin.y = 0
                self.tripPlannerView.frame = tripPlannerFrame
                
  
                }, completion: { finished in
                    //self.viewDown = true
                    self.tripPlannerBottomConstraint.constant = -156.00
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        
                        let tableHeader = self.mainTableView.parallaxHeader
                        tableHeader.height = self.mainView.frame.height - 50
                        self.mainTableView.parallaxHeader.height = tableHeader.height
                        self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                        
                        
                        }, completion: { finished in
                            print("View Moved!")
                    })
            })
        }
    }
    
    
    @IBAction func cancelButtonTap(sender: AnyObject) {
        if(!self.viewDown){
            
            tableViewStatus = 0
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            mainTableView.rowHeight = 100
            //mainTableView.reloadData()
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                
                
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = 400
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                
                
                }, completion: { finished in
                    self.tripPlannerBottomConstraint.constant = 19
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                        var tripPlannerFrame = self.tripPlannerView.frame
                        tripPlannerFrame.origin.y = -156

                        self.tripPlannerView.frame = tripPlannerFrame
                        
                        
                        
                        }, completion: { finished in
                            print("View Moved2!")
                    })
            })
            
            self.mainTableView.parallaxHeader.view?.hidden = false
        }

    }
    
    @IBAction func searchButtonTap(sender: AnyObject) {
        self.view.endEditing(true)
        
        tableViewStatus = 1
        mainTableView.reloadData()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 110
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = true
            
            
            }, completion: { finished in
                print("View Moved!")
        })
        
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier{
            switch identifier {
            case "Add":
                print("ADD")
            case "Cancel":
                print("No Trip")
            default:
                print("No Trip")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeViewController{
    
    //Search Bar Delegate Functions
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if(!searchActive){
        searchActive = true
        tableViewStatus = 1
        mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        mainTableView.rowHeight = 70
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 0
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = true
            
            print(self.searchBarLeftConstraint.constant)
            self.searchBarLeftConstraint.constant -= 40
            self.searchBarRightConstraint.constant += 40
            
            }, completion: { finished in
                print("View Moved!")
        })
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        self.searchBarLeftConstraint.constant += 40
        self.searchBarRightConstraint.constant -= 40
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        self.searchBarLeftConstraint.constant += 40
        self.searchBarRightConstraint.constant -= 40
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        self.searchBarLeftConstraint.constant += 40
        self.searchBarRightConstraint.constant -= 40
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if NSString(string: searchText).length > 0 {
            placeAutocomplete(searchBar.text!)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }
    }
    
    //Text Field Delegate Funtions
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        tableViewStatus = 1
        mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        mainTableView.rowHeight = 70
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 110
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = true
            
            
            }, completion: { finished in
                print("View Moved!")
        })
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("Change Called")
        var txtAfterUpdate:NSString = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)

        if txtAfterUpdate.length > 0 {
            print("TEXTFIELD TEXT_" + (txtAfterUpdate as String)+"_END")
            placeAutocomplete(txtAfterUpdate as String)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }
        return true
    }
    
    
    func placeAutocomplete(searchText: String) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        placesClient?.autocompleteQuery(searchText, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            self.predictions = []
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    self.predictions?.append(result)
                }
            }
            self.mainTableView.reloadData()
        })
    }
}
