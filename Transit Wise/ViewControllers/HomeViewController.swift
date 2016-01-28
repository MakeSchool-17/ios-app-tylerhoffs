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
import RealmSwift

class HomeViewController: UIViewController{
    
    
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
    @IBOutlet weak var dropShadowImage: UIImageView!
    @IBOutlet weak var dropShadowImage2: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var spinnerBackground: UIImageView!
    
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
    var currentTrip: Trip?
    var parallaxHeight: Int?
    var tableColors: [[Int]] = [[69,181,230],[69,230,131],[69,211,230],[254,196,9],[120,69,230],[230,69,72]]
    var previousColorIndex: Int = 0
    var textFieldIndex: Int = 0
    var realmHelper: RealmHelper?
    var recentSearches: Results<RecentSearches>?
    var numberTrips: Int = 0
    var foundCurrent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.transform = CGAffineTransformMakeScale(2, 2) //Change scale of loding indicator
        realmHelper = RealmHelper()
        
        //set initial height of parralax header contianing map
        parallaxHeight = Int(self.view.frame.height) - 250
        
        self.setNeedsStatusBarAppearanceUpdate() //Part of changing status bar to white.
        self.getOptions() //Update persisted options
        
        //Initialise various helpers and variables
        placesClient = GMSPlacesClient()
        startLocation = SearchLocation()
        endLocation = SearchLocation()
        currentLocation = SearchLocation()
        recentSearches = realmHelper?.getRecentSearches()
        nearbyStations = []
        
        mainTableView.rowHeight = 100
        mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        //Set initial camera position and apply it to the map
        let camera = GMSCameraPosition.cameraWithLatitude(-25.7561672,
            longitude:28.2289275, zoom:16)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        mapView!.delegate = self
        mapView!.settings.myLocationButton = true
        
        //Initialize and display centre marker
        centerMarker = GMSMarker()
        centerMarker!.appearAnimation = kGMSMarkerAnimationPop
        centerMarker!.icon = UIImage(named: "pin")
        centerMarker?.title = "Current Location"
        centerMarker?.zIndex = 999
        centerMarker!.map = mapView
        
        //Locaition Manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Parallax Header Setup
        let header = mapView
        mainTableView.parallaxHeader.view = header
        mainTableView.parallaxHeader.height = CGFloat(self.parallaxHeight!)
        mainTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        mainTableView.parallaxHeader.minimumHeight = 200
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tripPlannerView.addGestureRecognizer(tap)
        
        
        //3D Touch Shortcut Implemenation
        if #available(iOS 9.1, *) {
            let homeShortcut = UIApplicationShortcutItem(type: "com.transitwise.takemehome", localizedTitle: "Take Me Home", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Home), userInfo: nil)
            let workShortcut = UIApplicationShortcutItem(type: "com.transitwise.takemework", localizedTitle: "Take Me to Work", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Bookmark), userInfo: nil)
            UIApplication.sharedApplication().shortcutItems = [homeShortcut, workShortcut]
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    //Set the main status bar to white (LightStyle)
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowTrip") {
            let mapViewController = segue.destinationViewController as! MapViewController
            mapViewController.myTrip = currentTrip!
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
        
        directionButton.hidden = false
        self.searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+0, 0)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = CGFloat(self.parallaxHeight!)
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = false
            self.mainTableView.parallaxHeader.minimumHeight = 200
            
            
            
            }, completion: { finished in
                print("View Moved!")
        })
        
    }
    
    @IBAction func directionButtonTap(sender: UIButton) {
        self.dropTripPlanner()
        self.startLocation = self.currentLocation
        self.startTextField.text = "Current Location"
        self.endTextField.text = ""
    }
    
    func dropTripPlanner(){
        if(!self.viewDown){
            self.viewDown = true
            
            self.view.endEditing(true)
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                //var tripPlannerFrame = self.tripPlannerView.frame
                //tripPlannerFrame.origin.y = -10
                //self.tripPlannerView.frame = tripPlannerFrame
                self.tripPlannerView.transform = CGAffineTransformMakeTranslation(0,148)
                self.dropShadowImage2.transform = CGAffineTransformMakeTranslation(0,157)
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = self.mainView.frame.height - 55
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                
                
                }, completion: { finished in
                    if self.tableViewStatus == 0 {
                        if(self.startTextField.text != "Current Location"){
                            self.startTextField.text = self.startLocation?.name
                        }
                    }
                    //self.tripPlannerBottomConstraint.constant = -130
            })
        }
    }
    
    
    @IBAction func cancelButtonTap(sender: AnyObject) {
        if(self.viewDown){
            self.view.endEditing(true)
            self.viewDown = false
            tableViewStatus = 0
            searchBar.text = ""
            mainTableView.rowHeight = 100
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            
            //mainTableView.reloadData()
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                
                
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = CGFloat(self.parallaxHeight!)
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = 200
                self.tripPlannerView.transform = CGAffineTransformMakeTranslation(0,0)
                self.dropShadowImage2.transform = CGAffineTransformMakeTranslation(0,0)
                
                
                }, completion: { finished in
                    self.startTextField.text = ""
                    self.endTextField.text = ""
                    self.startLocation = SearchLocation()
                    self.endLocation = SearchLocation()
            })
            
            self.mainTableView.parallaxHeader.view?.hidden = false
        }
        
    }
    
    //Function interacting with APIHelper to send relevant information to the API and receive a list of trips
    func tripSearch(){
        self.spinnerBackground.hidden = false
        loadingIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        availableRoutes = Routes()
        
        
        apiHelper.getDirectionsCallback((startLocation?.lat)!, startLong: (startLocation?.long)!, startName: (startLocation?.name)!, endLat: (endLocation?.lat)!, endLong: (endLocation?.long)!, endName: (endLocation?.name)!){ response in
            if response.error == nil{
                self.availableRoutes!.JSONinit(response.json!)
                
                self.tableViewStatus = 2
                self.mainTableView.reloadData()
                self.mainTableView.parallaxHeader.height = 90
                self.mainTableView.parallaxHeader.minimumHeight = 90
                self.mainTableView.parallaxHeader.view?.hidden = true
                
            }else{
                print(response.error)
                self.tableViewStatus = 2
                self.mainTableView.reloadData()
                self.mainTableView.parallaxHeader.height = 90
                self.mainTableView.parallaxHeader.minimumHeight = 90
                self.mainTableView.parallaxHeader.view?.hidden = true
            }
            self.loadingIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.spinnerBackground.hidden = true
        }
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

// MARK: - Table view functions
// Extension containing all of the table view functions
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    // Table View Statuses:
    // 0: Display bus stops
    // 1: Display search results on trip planner page
    // 2: Display trips available
    // 3: Display search results on main page
    // 4: Dislpay recent searches on trip planner page
    // 5: Dislpay recent searches on main page
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableViewStatus == 1){
            if let predictions = predictions{
                return predictions.count
            }else{
                return 0
            }
        }else if (tableViewStatus == 0){
            return (nearbyStations?.count)! // TODO: Get Stations List\
            
        }else if (tableViewStatus == 2){
            if let _ = availableRoutes?.trips {
                numberTrips = (self.availableRoutes?.trips?.count)!
                return numberTrips
            }
            else{
                numberTrips = 0
                return 0
            }
            
        }
        else if (tableViewStatus == 3){
            if let predictions = predictions{
                return predictions.count
            }else{
                return 0
            }
        }
        else if (tableViewStatus == 4 || tableViewStatus == 5){
            if((recentSearches?.count)! <= 5){
                return (recentSearches?.count)!
            }
            else{
                return 5
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableViewStatus == 0){
            return 80
        }
        else{
            return 50
        }
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(tableViewStatus == 1){
            return "Search Results"
        }
        else if(tableViewStatus == 2){
            if (numberTrips == 0){
                return "No Trips Found"
            }else{
                return "Available Trips"
            }
        }
        else if(tableViewStatus == 3){
            return "Search Results"
        }
        else if(tableViewStatus == 4){
            return "Recent Searches"
        }
        else if(tableViewStatus == 5){
            return "Recent Searches"
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var identifier = ""
        
        if (tableViewStatus == 0){
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            identifier = "busStopCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! BusStopCell
            
            cell.contentView.backgroundColor = getRandomColor()
            cell.stopNameLabel.text = nearbyStations![indexPath.row].name!
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
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
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
            identifier = "tripCell"
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TripCell
            let duration = (self.availableRoutes?.trips![indexPath.row].time?.duration)!
            let minutes = duration % 60
            let hours = Int(duration/60)
            var timeString = ""
            if(hours == 0){
                timeString = "\(minutes) mins"
            }
            else if(hours < 2){
                timeString = "\(hours)" + "h " + "\(minutes)m"
            }else{
                timeString = "\(hours)" + "h " + "\(minutes)m"
            }
            var cost = (self.availableRoutes?.trips![indexPath.row].cost)!
            cell.timeLabel?.text = timeString
            if (cost == 0.0){
                cost = 40.0
            }
            cell.costLabel?.text = "R" + String(cost) + "0"
            cell.leaveLabel?.text = "Leave at: " + calcTime((self.availableRoutes?.trips![indexPath.row].time?.start)!)
            
            let images = [cell.imageOne,cell.imageTwo,cell.imageThree,cell.imageFour,cell.imageFive,cell.imageSix]
            let chevron = [cell.chevronOne,cell.chevronTwo,cell.chevronThree,cell.chevronFour,cell.chevronFive]
            
            for i in 0...5 {
                
                if(i < self.availableRoutes?.trips![indexPath.row].legs?.count){
                    print(self.availableRoutes?.trips![indexPath.row].legs![i].agency?.name)
                    if (self.availableRoutes?.trips![indexPath.row].legs![i].pathType == "Walk"){
                        images[i].image = UIImage(named: "walk")
                    }
                    else if((self.availableRoutes?.trips![indexPath.row].legs![i].agency?.name)! == "Gautrain"){
                        images[i].image = UIImage(named: "train")
                    }
                    else if((self.availableRoutes?.trips![indexPath.row].legs![i].agency?.name)! == "Metrorail Gauteng"){
                        images[i].image = UIImage(named: "train")
                    }
                    else{
                        images[i].image = UIImage(named: "busicon")
                    }
                }
                else{
                    images[i].hidden = true
                    if(i>0){
                        chevron[i-1].hidden = true
                    }
                }
            }
            
            return cell
        }
        else if(tableViewStatus == 3){
            identifier = "searchCell"
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
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
        else if(tableViewStatus == 4) || (tableViewStatus == 5){
            identifier = "recentCell"
            let numberRecent = recentSearches!.count - 1
            mainTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! RecentCell
            
            
            cell.addressLabel?.text = self.recentSearches![numberRecent - indexPath.row].name
            cell.cityLabel?.text = self.recentSearches![numberRecent - indexPath.row].subtitle
            return cell
        }
        else{
            identifier = "recentCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
            return cell
        }
        
    }
    
    func getRandomColor() -> UIColor{
        
        var randomNumber = Int(arc4random_uniform(6))
        while(randomNumber == previousColorIndex){
            randomNumber = Int(arc4random_uniform(6))
        }
        previousColorIndex = randomNumber
        let rgb = tableColors[randomNumber]
        let color = UIColor(red: CGFloat(rgb[0])/255.0, green: CGFloat(rgb[1])/255.0, blue: CGFloat(rgb[2])/255.0, alpha: 1.0)
        return color
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(tableViewStatus == 0){
            startLocation?.name = nearbyStations![indexPath.row].name!
            startLocation?.long = (nearbyStations![indexPath.row].loc?.long)!
            startLocation?.lat = (nearbyStations![indexPath.row].loc?.lat)!
            mapView?.animateToLocation(CLLocationCoordinate2DMake(CLLocationDegrees((startLocation?.lat)!), CLLocationDegrees((startLocation?.long)!)))
            dropTripPlanner()
        }
        else if(tableViewStatus == 1){
            if(textFieldIndex == 1){
                endLocation?.setFromID(predictions![indexPath.row].placeID){response in
                    if response == nil{
                        self.endTextField.text = self.endLocation?.name
                        self.realmHelper?.addRecentSearch((self.endLocation?.name)!, subtitle: self.predictions![indexPath.row].attributedSecondaryText.string , lat: (self.endLocation?.lat)!, long: (self.endLocation?.long)!)
                        if let _ = self.endLocation?.lat {
                            if let _ = self.startLocation?.lat{
                                self.tripSearch()
                            }
                        }
                    }else{
                        print("Location not set from ID")
                    }
                }
            }
            else{
                startLocation?.setFromID(predictions![indexPath.row].placeID){response in
                    if response == nil{
                        self.startTextField.text = self.startLocation?.name
                        if let _ = self.endLocation?.lat {
                            if let _ = self.startLocation?.lat{
                                self.tripSearch()
                            }
                        }
                    }else{
                        print("Location not set from ID")
                    }
                }
            }
            
        }
        else if(tableViewStatus == 2){
            currentTrip = availableRoutes?.trips![indexPath.row]
            self.performSegueWithIdentifier("ShowTrip", sender: self)
        }
        else if(tableViewStatus == 3){
            endLocation?.setFromID(predictions![indexPath.row].placeID){response in
                if response == nil{
                    self.realmHelper?.addRecentSearch((self.endLocation?.name)!, subtitle: self.predictions![indexPath.row].attributedSecondaryText.string, lat: (self.endLocation?.lat)!, long: (self.endLocation?.long)!)
                    self.dropTripPlanner()
                    self.startLocation = self.currentLocation
                    self.startTextField.text = "Current Location"
                    self.endTextField.text = self.endLocation?.name
                    self.tripSearch()
                }else{
                    print("Location not set from ID")
                }
            }
            
            
        }
        else if(tableViewStatus == 4){
            directionButton.hidden = false
            self.searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
            self.slideCancelButton.transform = CGAffineTransformMakeTranslation(+0, 0)
            self.dropTripPlanner()
            self.startLocation = self.currentLocation
            self.startTextField.text = "Current Location"
            let numberRecent = recentSearches!.count - 1
            endLocation?.name = self.recentSearches![numberRecent - indexPath.row].name
            endLocation?.lat = self.recentSearches![numberRecent - indexPath.row].lat.value
            endLocation?.long = self.recentSearches![numberRecent - indexPath.row].long.value
            self.endTextField.text = self.endLocation?.name
            self.tripSearch()
        }
        else if(tableViewStatus == 5){
            
            if(textFieldIndex == 1){
                let numberRecent = recentSearches!.count - 1
                endLocation?.name = self.recentSearches![numberRecent - indexPath.row].name
                endLocation?.lat = self.recentSearches![numberRecent - indexPath.row].lat.value
                endLocation?.long = self.recentSearches![numberRecent - indexPath.row].long.value
                self.endTextField.text = self.endLocation?.name
                self.tripSearch()
            }
            else{
                let numberRecent = recentSearches!.count - 1
                startLocation?.name = self.recentSearches![numberRecent - indexPath.row].name
                startLocation?.lat = self.recentSearches![numberRecent - indexPath.row].lat.value
                startLocation?.long = self.recentSearches![numberRecent - indexPath.row].long.value
                self.startTextField.text = self.startLocation?.name
                self.tripSearch()
            }
        }
        else{
            self.performSegueWithIdentifier("ShowTrip", sender: self)
        }
    }
    
}

// MARK: - Search bar functions
// Extension containing all of the search bar functions
extension HomeViewController: UISearchBarDelegate{
    
    //Search Bar Delegate Functions
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if(!searchActive){
            directionButton.hidden = true
            searchActive = true
            tableViewStatus = 4
            predictions = []
            
            mainTableView.rowHeight = 50
            mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            
            //Animation to slide searchbar to the left and reveal a cancel button
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                let tableHeader = self.mainTableView.parallaxHeader
                tableHeader.height = 0
                self.mainTableView.parallaxHeader.height = tableHeader.height
                self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
                self.mainTableView.parallaxHeader.view?.hidden = true
                
                self.searchBar.transform = CGAffineTransformMakeTranslation(-40, 0)
                self.slideCancelButton.transform = CGAffineTransformMakeTranslation(-80, 0)
                
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
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tableViewStatus = 3
        if NSString(string: searchText).length > 0 {
            placeAutocomplete(searchBar.text!)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }
    }
}
extension HomeViewController:  UITextFieldDelegate{
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        
        tableViewStatus = 5
        mainTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        mainTableView.rowHeight = 50
        
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            
            let tableHeader = self.mainTableView.parallaxHeader
            tableHeader.height = 90
            self.mainTableView.parallaxHeader.height = tableHeader.height
            self.mainTableView.parallaxHeader.minimumHeight = tableHeader.height
            self.mainTableView.parallaxHeader.view?.hidden = true
            
            
            }, completion: { finished in
                print("View Moved!")
        })
        
        if(textField == startTextField!){
            self.textFieldIndex = 0
            if(textField.text == "Current Location"){
                textField.text = ""
                startLocation!.lat = nil
                startLocation!.name = ""
            }
        }
        else{
            self.textFieldIndex = 1
            if(textField.text == "Current Location"){
                textField.text = ""
                endLocation!.lat = nil
                endLocation!.name = ""
            }
        }
        
        if textField.text?.characters.count > 0 {
            
            placeAutocomplete(textField.text!)
        }else{
            self.predictions = []
            self.mainTableView.reloadData()
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        tableViewStatus = 1
        var txtAfterUpdate:NSString = textField.text! as NSString
        
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        if txtAfterUpdate.length > 0 {
            
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
    
}
//MARK: MapViewDelegate
//Extension containing all the mapview reated function
extension HomeViewController: GMSMapViewDelegate{
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        //        endLocation?.lat = marker.position.latitude
        //        endLocation?.long = marker.position.longitude
        return false
    }
    
    //Function that draws a window above marker when it is tapped.
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let customInfoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil)[0] as! UIView
        if marker.hash == centerMarker?.hash{
            return customInfoWindow
        }
        return nil
    }
    
    //Function that handles taps on the window drawn above marker.
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        if marker == centerMarker{
            GMSGeocoder().reverseGeocodeCoordinate(marker.position){ response, error in
                if let address = response.firstResult(){
                    let lines = address.lines as! [String]
                    self.dropTripPlanner()
                    if(self.startTextField.text == ""){
                        self.startLocation = self.currentLocation
                        self.startTextField.text = "Current Location"
                    }
                    self.endLocation?.lat = marker.position.latitude
                    self.endLocation?.long = marker.position.longitude
                    self.endLocation?.name = lines[0]
                    
                    self.endTextField.text = self.endLocation?.name
                    self.tripSearch()
                }else{
                    self.dropTripPlanner()
                    if(self.startTextField.text == ""){
                        self.startLocation = self.currentLocation
                        self.startTextField.text = "Current Location"
                    }
                    self.endLocation?.lat = marker.position.latitude
                    self.endLocation?.long = marker.position.longitude
                    self.endLocation?.name = "marker"
                    self.endTextField.text = self.endLocation?.name
                    self.tripSearch()
                    
                }
            }
        }
    }
    
    //Funciton that hmakes marker stay centered on the map
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if saBounds.containsCoordinate(position.target){
            centerMarker?.position = position.target
        }
    }
    
    //Function handling a long press on the map
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        if saBounds.containsCoordinate(coordinate){
            mapView.animateToCameraPosition(GMSCameraPosition(target: coordinate, zoom: mapView.camera.zoom, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle))
        }
        
    }
    
}

//MARK: CLLocationManagerDelegate
//Extension containing a location manager to deal with user's current position
extension HomeViewController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView!.myLocationEnabled = true
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation?.lat = location.coordinate.latitude
            currentLocation?.long = location.coordinate.longitude
        }
        if foundCurrent == true{
            return
        }
        foundCurrent = true
        if let location = locations.first {
            refreshCurrentLocation(location)
            mapView!.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0)
            
        }
    }
    
}

//Extention for misc. functions
extension HomeViewController{
    
    //Function that get's persisted options from last session.
    func getOptions(){
        apiHelper.getOptionsCallback(){response in
            if response.error == nil{
                let apiOptions = Options.from((response.json?.dictionaryObject)!)
                let realmHelper = RealmHelper()
                realmHelper.persistOptions(apiOptions!)
                
            }else{
                print(response.error)
            }
        }
    }
    
    func refreshCurrentLocation(location: CLLocation){
        
        apiHelper.getNearbyStation(location.coordinate.latitude, long: location.coordinate.longitude){response in
            if response.error == nil{
                self.nearbyStations = []
                for stop in response.json!["stops"]{
                    self.nearbyStations?.append(Stop(json: stop.1))
                }
                for stops in self.nearbyStations!{
                    stops.addMarker(self.mapView!)
                }
                self.mainTableView.reloadData()
            }else{
                print(response.error)
            }
            
        }
    }
    
    //Animation and function when switch button is tapped
    @IBAction func switchButtonTap(sender: AnyObject) {
        let temp = startLocation
        startLocation = endLocation
        endLocation = temp
        
        
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            
            self.startTextField.transform = CGAffineTransformMakeTranslation(0, 38)
            
            self.endTextField.transform = CGAffineTransformMakeTranslation(0, -38)
            
            }, completion: { finished in
            self.startTextField.transform = CGAffineTransformMakeTranslation(0, 0)
            self.endTextField.transform = CGAffineTransformMakeTranslation(0, 0)
            let temp2 = self.startTextField.text
            self.startTextField.text = self.endTextField.text
            self.endTextField.text = temp2
                
            if let _ = self.endLocation?.lat {
                if let _ = self.startLocation?.lat{
                    self.tripSearch()
                }
            }
        })
        
        
    }
    
    //Funciton that converts time from certain stored format to displayable format.
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
    
}
