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

class HomeViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, GMSMapViewDelegate {
    
    
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
    @IBOutlet weak var slideCancelButton: UIButton!
    
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
    let saBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: -24.940233, longitude: 27.000579), coordinate: CLLocationCoordinate2D(latitude: -26.955361, longitude: 29.098968))
    
    var startLocation: SearchLocation?
    var endLocation: SearchLocation?
    var currentLocation: SearchLocation?
    let apiHelper = RwtToAPIHelper()
    var nearbyStations: [Stop]?
    var availableRoutes: Routes?
    var centerMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        placesClient = GMSPlacesClient()
        startLocation = SearchLocation()
        endLocation = SearchLocation()
        currentLocation = SearchLocation()
        nearbyStations = []
        
        mainTableView.rowHeight = 100
        mainTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:16)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        mapView!.delegate = self
        mapView!.settings.myLocationButton = true
        
        centerMarker = GMSMarker()
        centerMarker!.appearAnimation = kGMSMarkerAnimationPop
        centerMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        centerMarker?.title = "Current Location"
        centerMarker!.map = mapView
        
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
        
        if #available(iOS 9.1, *) {
            let shortcut = UIApplicationShortcutItem(type: "com.transitwise.takemehome", localizedTitle: "Take Me Home", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Home), userInfo: nil)
            UIApplication.sharedApplication().shortcutItems = [shortcut]
        } else {
            // Fallback on earlier versions
        }
        


    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableViewStatus == 1){
            if let predictions = predictions{
                return predictions.count
            }else{
                return 0
            }
        }else if (tableViewStatus == 0){
            return (nearbyStations?.count)! // TODO: Get Stations List
        }else if (tableViewStatus == 2){
            print("AVAILABLE ROUTES \(self.availableRoutes?.trips?.count)")
            return (availableRoutes?.trips!.count)!
        }
        else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifier = ""
        
        if (tableViewStatus == 0){
            identifier = "busStopCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! BusStopCell
            cell.contentView.backgroundColor = getRandomColor()
            cell.stopNameLabel.text = nearbyStations![indexPath.row].name! + " Stop"
            if(nearbyStations![indexPath.row].distance! > 1){
                cell.stopDistanceLabel.text = "\(nearbyStations![indexPath.row].distance!)km"
            }
            else{
                let metres = Int(nearbyStations![indexPath.row].distance! * 1000)
                cell.stopDistanceLabel.text = "\(metres)m"
            }
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
        else if(tableViewStatus == 2){
            identifier = "searchCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SearchCell
            print(indexPath.row)
            
            cell.addressLabel?.text = self.availableRoutes?.trips![indexPath.row].shortCode
            
            //cell.cityLabel?.text = self.availableRoutes?.trips![indexPath.row].
            return cell
        }
        else{
            identifier = "recentCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            return cell
        }
        
    }
    
    
    
    
    ///http://classictutorials.com/2014/08/generate-a-random-color-in-swift/
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedWaypoint = waypoints[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //self.performSegueWithIdentifier("ShowTrip", sender: self)
        if(tableViewStatus == 0){
            startLocation?.name = nearbyStations![indexPath.row].name!
            startLocation?.long = (nearbyStations![indexPath.row].loc?.long)!
            startLocation?.lat = (nearbyStations![indexPath.row].loc?.lat)!
            startTextField.text = startLocation?.name
            dropTripPlanner()
        }
        else if(tableViewStatus == 1){
            endLocation?.setFromID(predictions![indexPath.row].placeID)
            print("endLocation SET")
        }
        else{
            self.performSegueWithIdentifier("ShowTrip", sender: self)
        }
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        NSLog("progress %f", scrollView.parallaxHeader.progress)
    }
    
    // MARK: - Button Actions
    @IBAction func slideCacelTap(sender: AnyObject) {
            self.view.endEditing(true)
            directionButton.hidden = false
            searchActive = false
            tableViewStatus = 0
            mainTableView.rowHeight = 100
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = 400
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                self.mainTableView.parallaxHeader.view?.hidden = false
                
                
                
                }, completion: { finished in
                    print("View Moved!")
            })
        
    }
    
    @IBAction func directionButtonTap(sender: UIButton) {
        dropTripPlanner()
    }
    
    func dropTripPlanner(){
        if(!self.viewDown){
            self.viewDown = true
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
        if(self.viewDown){
            self.viewDown = false
            tableViewStatus = 0
            mainTableView.rowHeight = 100
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            
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
    
    func tripSearch(){
        tableViewStatus = 1
        mainTableView.reloadData()
        
        
        availableRoutes = Routes()
        
        /*
        startLocation?.lat = -26.15041
        startLocation?.long = 28.01562
        startLocation?.name = "11 Greenfield Rd, Randburg"
        endLocation?.lat = -26.1696916
        endLocation?.long = 28.138237
        endLocation?.name = "9 Florence Ave, Germiston"
        */
        
        apiHelper.getDirectionsCallback((startLocation?.lat)!, startLong: (startLocation?.long)!, startName: (startLocation?.name)!, endLat: (endLocation?.lat)!, endLong: (endLocation?.long)!, endName: (endLocation?.name)!){ response in
            if response.error == nil{
                self.availableRoutes!.JSONinit(response.json!)
                
                self.tableViewStatus = 2
                self.mainTableView.reloadData()
            }else{
                print(response.error)
            }
        }
        
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
    
    @IBAction func searchButtonTap(sender: AnyObject) {
        self.view.endEditing(true)
        tripSearch()
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
        directionButton.hidden = true
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
            
            self.slideCancelButton.transform = CGAffineTransformMakeTranslation(-70, 0)
            
            }, completion: { finished in
                print("View Moved!")
        })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboard()
        //TODO: Bring back map
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        directionButton.hidden = false
        self.searchBarLeftConstraint.constant += 40
        self.searchBarRightConstraint.constant -= 40
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+70, 0)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        directionButton.hidden = false
        self.searchBarLeftConstraint.constant += 40
        self.searchBarRightConstraint.constant -= 40
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+70, 0)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        directionButton.hidden = false
        self.searchBarLeftConstraint.constant += 40
        self.searchBarRightConstraint.constant -= 40
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+70, 0)
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
        placesClient?.autocompleteQuery(searchText, bounds: saBounds, filter: filter, callback: { (results, error: NSError?) -> Void in
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
    
//MARK: MapViewDelegate
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        endLocation?.lat = marker.position.latitude
        endLocation?.long = marker.position.longitude
        return false
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let customInfoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil)[0] as! UIView
        if marker.hash == centerMarker?.hash{
            
        }else{
            
        }
        return customInfoWindow
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        print("Start Search")
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        centerMarker?.position = position.target
    }
    
}

extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView!.myLocationEnabled = true
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = currentLocation?.lat{
            return
        }
        if let location = locations.first {
            
            mapView!.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0)
            currentLocation?.lat = location.coordinate.latitude
            currentLocation?.long = location.coordinate.longitude
            apiHelper.getNearbyStation((currentLocation?.lat)!, long: (currentLocation?.long)!){response in
                if response.error == nil{
                    self.nearbyStations = []
                    for stop in response.json!["stops"]{
                        self.nearbyStations?.append(Stop(json: stop.1))
                    }
                    for stops in self.nearbyStations!{
                        stops.addMarker(self.mapView!)
                    }
                    self.mainTableView.reloadData()
                    //TODO: Show the stops on the TableView
                }else{
                    print(response.error)
                }
                
            }
            
            locationManager.stopUpdatingLocation()
        }
    }
    
}
