//
//  OptionsViewController.swift
//  Transit Wise
//
//  Created by Tyler Hoffman on 2016/01/10.
//  Copyright © 2016 Transit Wise. All rights reserved.
//

import UIKit
import RealmSwift

class OptionsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var appIconImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var optionsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let realmHelper =  RealmHelper()
    var agencies: [Agency]?
    var links: [String] = ["Send Feedback", "Follow @transitwise", "Like TransitWise on Facebook", "Share"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        agencies = realmHelper.getAgencies()
        
        // setup table view 
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        
    }
    
//    override func viewDidAppear(animated: Bool) {
//        agencies = realmHelper.getAgencies()
//    }
    
    //Set status bar colour to white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            return agencies!.count
        }
        else{
            return links.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("agencyOptionCell", forIndexPath: indexPath) as! AgencyOptionCell
            cell.agencyNameLabel.text = agencies![indexPath.row].name
            cell.id = agencies![indexPath.row]._id
            cell.agencySelectedSwitch.setOn(agencies![indexPath.row].filter_state!.boolValue, animated: false)
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("linkCell", forIndexPath: indexPath) as! LinkCell
            cell.linkNameLabel.text = links[indexPath.row]
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(optionsSegmentedControl.selectedSegmentIndex == 1){
            if(indexPath.row == 0){
                let email = "support@transitwise.co.za"
                let url = NSURL(string: "mailto:\(email)")
                UIApplication.sharedApplication().openURL(url!)
            }
            else if(indexPath.row == 1){
                UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/transitwise")!)
            }
            else if(indexPath.row == 2){
                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/transitwise/")!)
            }
            else if(indexPath.row == 3){
                let shareString = "String to share"
                
                let objectsToShare = [shareString]
                
                let activityViewController      = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
                
                presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }

    //Segment controller for two different option screeens
    @IBAction func segmentChange(sender: AnyObject) {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        if(optionsSegmentedControl.selectedSegmentIndex == 0){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.tableView.transform = CGAffineTransformMakeTranslation(0, 0)
                self.headerLabel.hidden = false
                self.versionLabel.hidden = true
                self.nameLabel.hidden = true
                self.appIconImage.hidden = true
                
                }, completion: { finished in
                    print("View Moved!")
            })
        }
        else{
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.tableView.transform = CGAffineTransformMakeTranslation(0, 200)
                self.headerLabel.hidden = true
                self.versionLabel.hidden = false
                self.nameLabel.hidden = false
                self.appIconImage.hidden = false

                }, completion: { finished in
                    print("View Moved!")
            })
        }
    }
    
}

