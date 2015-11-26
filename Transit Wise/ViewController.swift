//
//  ViewController.swift
//  Transit Wise
//
//  Created by Unathi Chonco on 11/23/15.
//  Copyright © 2015 Transit Wise. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var responseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let headers = ["app": "testing", "Content-Type": "application/json"]
        let parameters = ["start": ["loc": [-25.7561672,28.2289275], "name": "University of Pretoria - Hatfield Campus Main Entrance, Pretoria, Gauteng, South Africa"],
                        "end": ["loc": [-25.7500498,28.1688913], "name": "Pretoria Central, Pretoria, Gauteng, South Africa"],
                        "options": ["exclude": ["agencies": [], "cats":[]]],
                        "time": 900,
                        "_csrf": "Unathi Xcode"]
        
        Alamofire.request(.POST, "https://rwt.to/api/site/directions", parameters: parameters, encoding: .JSON, headers: headers).responseJSON { (response) -> Void in
            self.responseLabel.text = String(response)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

