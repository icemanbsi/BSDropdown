//
//  ViewController.swift
//  BSDropdown
//
//  Created by Bobby Stenly Irawan on 4/9/16.
//  Copyright © 2016 Bobby Stenly Irawan. All rights reserved.
//

import UIKit
import BSDropdown

class ViewController: UIViewController, BSDropdownDelegate {

    @IBOutlet weak var bsdFirst: BSDropdown!
    @IBOutlet weak var bsdSecond: BSDropdown!
    @IBOutlet weak var bsdThird: BSDropdown!
    
    
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
            firstOptions.addObject(["title" : "Option \(i+1)", "value" : "opt \(i+1)"])
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
        self.bsdThird.setup()
        self.bsdThird.setDataSource(firstOptions)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // -- Mark: BSDropdownDelegate
    func onDropdownSelectedItemChange(dropdown: BSDropdown, selectedItem: NSDictionary?) {
        
    }
}

