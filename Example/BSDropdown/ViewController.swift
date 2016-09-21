//
//  ViewController.swift
//  BSDropdown
//
//  Created by Bobby Stenly Irawan on 4/9/16.
//  Copyright © 2016 Bobby Stenly Irawan. All rights reserved.
//

import UIKit
import BSDropdown

class ViewController: UIViewController, BSDropdownDelegate, BSDropdownDataSource {

    @IBOutlet weak var bsdFirst: BSDropdown!
    @IBOutlet weak var bsdSecond: BSDropdown!
    @IBOutlet weak var bsdThird: BSDropdown!
    @IBOutlet weak var bsdFourth: BSDropdown!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //setting up first BSDropdown
        self.bsdFirst.viewController = self
        self.bsdFirst.delegate = self
        self.bsdFirst.title = "First Dropdown"
        self.bsdFirst.defaultTitle = "Default"
        self.bsdFirst.setup()
        let firstOptions = NSMutableArray()
        for i in 0 ..< 50 {
            firstOptions.add(["title" : "Option \(i+1)", "value" : "opt \(i+1)"])
        }
        self.bsdFirst.setDataSource(firstOptions)
        
        
        //setting up second BSDropdown
        self.bsdSecond.viewController = self
        self.bsdSecond.title = "Second Dropdown"
        self.bsdSecond.defaultTitle = "Searchable"
        self.bsdSecond.enableSearch = true
        self.bsdSecond.setup()
        let secondOptions = NSMutableArray(array:[
            ["title" : "Afghanistan"],
            ["title" : "Albania"],
            ["title" : "Algeria"],
            ["title" : "Andorra"],
            ["title" : "Angola"],
            ["title" : "Antigua and Barbuda"],
            ["title" : "Argentina"],
            ["title" : "Armenia"],
            ["title" : "Aruba"],
            ["title" : "Australia"],
            ["title" : "Austria"],
            ["title" : "Azerbaijan"],
            ["title" : "Bahamas"],
            ["title" : "Bahrain"],
            ["title" : "Bangladesh"],
            ["title" : "Barbados"],
            ["title" : "Belarus"],
            ["title" : "Belgium"],
            ["title" : "Belize"],
            ["title" : "Benin"],
            ["title" : "Bhutan"],
            ["title" : "Bolivia"],
            ["title" : "Bosnia and Herzegovina"],
            ["title" : "Botswana"],
            ["title" : "Brazil"],
            ["title" : "Brunei"],
            ["title" : "Bulgaria"],
            ["title" : "Burkina Faso"],
            ["title" : "Burma"],
            ["title" : "Burundi"],
            ["title" : "Indonesia"],
            ["title" : "United Kingdom"],
            ["title" : "United States"],
            ["title" : "Zambia"],
            ["title" : "Zimbabwe"],
            //Sorry, too lazy to type all of the country names.. :D
            ])
        self.bsdSecond.setDataSource(secondOptions)
        
        
        //setting up third BSDropdown
        self.bsdThird.viewController = self
        self.bsdThird.title = "Third Dropdown"
        self.bsdThird.defaultTitle = "No Done Button"
        self.bsdThird.hideDoneButton = true
        self.bsdThird.headerBackgroundColor = UIColor(red: 36.0/255.0, green: 77.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        self.bsdThird.itemTintColor = self.bsdThird.headerBackgroundColor
        self.bsdThird.setup()
        self.bsdThird.setDataSource(firstOptions)
        
        //setting up fourth BSDropdown
        self.bsdFourth.viewController = self
        self.bsdFourth.dataSource = self
        self.bsdFourth.title = "Fourth Dropdown"
        self.bsdFourth.defaultTitle = "Custom View"
        self.bsdFourth.setup()
        let fourthOptions = NSMutableArray(array:[
            ["title" : "Facebook",  "subtitle" : "A site that makes you realize you hate all your friends",     "icon" : "fb.png"],
            ["title" : "Twitter",   "subtitle" : "Follow your interests",                                       "icon" : "twitter.png"],
            ["title" : "Google +",  "subtitle" : "",                                                            "icon" : "gplus.png"],
            ["title" : "Linked In", "subtitle" : "World's largest professional website",                        "icon" : "linkedin.png"],
            ["title" : "Youtube",   "subtitle" : "Broadcast yourself",                                          "icon" : "youtube.png"],
            ["title" : "Vimeo",     "subtitle" : "Make life worth watching",                                    "icon" : "vimeo.png"],
            ["title" : "Github",    "subtitle" : "How people build software",                                   "icon" : "github.png"]
            ])
        self.bsdFourth.setDataSource(fourthOptions)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // -- Mark: BSDropdownDelegate
    func onDropdownSelectedItemChange(_ dropdown: BSDropdown, selectedItem: NSDictionary?) {
        if dropdown == self.bsdFirst {
            if let item = selectedItem {
                NSLog("bsdFirst selected item change : \(item.object(forKey: "value") as! String)")
            }
        }
    }
    
    // -- Mark: BSDropdownDataSource
    func itemHeightForRowAtIndexPath(_ dropdown: BSDropdown, tableView: UITableView, item: NSDictionary?, indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func itemForRowAtIndexPath(_ dropdown: BSDropdown, tableView: UITableView, item: NSDictionary?, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "customTableViewCell")
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "customTableViewCell", for: indexPath)
        if let cellInfoArray = item {
            
            let imgIcon = cell.viewWithTag(1) as! UIImageView
            let lblTitle = cell.viewWithTag(2) as! UILabel
            let lblSubtitle = cell.viewWithTag(3) as! UILabel
            
            if let icon = cellInfoArray.object(forKey: "icon") as? String {
                imgIcon.image = UIImage(named: icon)
            }
            else{
                imgIcon.image = nil
            }
            
            if let title = cellInfoArray.object(forKey: "title") as? String {
                lblTitle.text = title
            }
            else{
                lblTitle.text = ""
            }
            
            if let subtitle = cellInfoArray.object(forKey: "subtitle") as? String {
                lblSubtitle.text = subtitle
            }
            else{
                lblSubtitle.text = ""
            }
            
        }
        
        return cell
    }
}

