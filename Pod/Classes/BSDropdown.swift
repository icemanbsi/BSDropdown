//
//  BSDropdown.swift
//  V1.3
//
//  Items selector with a pop up table list view.
//  You can use a NSMutableArray of NSDictionary for the data source
//
//  Created by Bobby Stenly Irawan ( iceman.bsi@gmail.com - http://bobbystenly.com ) on 11/21/15.
//  Copyright © 2015 Bobby Stenly Irawan. All rights reserved.
//
//  New in V1.3
//  - change viewController into weak var
//
//  New in V1.2
//  - added DataSource Protocol for custom tableview cell / layout
//  - added fixedDisplayedTitle to make the default title fixed (not change even the selected item has changed)

import Foundation
import UIKit

public protocol BSDropdownDelegate {
    func onDropdownSelectedItemChange(dropdown: BSDropdown, selectedItem: NSDictionary?)
}
extension BSDropdownDelegate {
    func onDropdownSelectedItemChange(dropdown: BSDropdown, selectedItem: NSDictionary?) {
    }
}

public protocol BSDropdownDataSource {
    func itemHeightForRowAtIndexPath(dropdown: BSDropdown, tableView: UITableView, item: NSDictionary?, indexPath: NSIndexPath) -> CGFloat
    func itemForRowAtIndexPath(dropdown: BSDropdown, tableView: UITableView, item: NSDictionary?, indexPath: NSIndexPath) -> UITableViewCell
}

public class BSDropdown:UIButton, UITableViewDelegate, UITableViewDataSource{
    //required attributes
    public weak var viewController: UIViewController?
    //--end of required attributes
    
    //optional attributes
    public var delegate: BSDropdownDelegate!
    public var dataSource: BSDropdownDataSource!
    public var modalBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.5)
    public var selectorBackgroundColor: UIColor = UIColor(white: 1, alpha: 1)
    public var headerBackgroundColor: UIColor = UIColor(white: 0, alpha: 1)
    public var titleColor: UIColor = UIColor(white: 1, alpha: 1)
    public var cancelButtonBackgroundColor: UIColor = UIColor(white: 0, alpha: 0)
    public var doneButtonBackgroundColor: UIColor = UIColor(white: 0, alpha: 0)
    public var cancelTextColor: UIColor = UIColor(white: 0.8, alpha: 1)
    public var doneTextColor: UIColor = UIColor(white: 0.8, alpha: 1)
    public var itemTextColor: UIColor = UIColor(white: 0, alpha: 1)
    public var itemTintColor: UIColor = UIColor(white: 0, alpha: 0.8)
    public var titleFont:UIFont? = UIFont(name: "Helvetica", size: 16)
    public var buttonFont:UIFont? = UIFont(name: "Helvetica", size: 13)
    public var itemFont:UIFont? = UIFont(name: "Helvetica", size: 13)
    public var title: String = "title"
    public var cancelButtonTitle: String = "Cancel"
    public var doneButtonTitle: String = "Done"
    public var defaultTitle: String = "Select Item"
    public var titleKey: String = "title"
    public var enableSearch: Bool = false
    public var searchPlaceholder: String = "Search"
    public var fixedDisplayedTitle: Bool = false
    public var hideDoneButton: Bool = false
    //-- end of optional attributes
    
    private var selectedIndex: Int = -1
    private var tempSelectedIndex: Int = -1
    private var data: NSMutableArray?
    private var originalData: NSMutableArray?
    
    private var selectorModalView: UIView!
    private var selectorView: UIView!
    private var selectorHeaderView: UIView!
    private var lblSelectorTitleLabel: UILabel!
    private var btnSelectorCancel: UIButton!
    private var btnSelectorDone: UIButton!
    private var selectorTableView: UITableView!
    private var searchView: UIView!
    private var txtKeyword: UITextField!
    
    public func setup(){
        if let vc = self.viewController {
            
            self.selectorModalView = UIView()
            self.selectorModalView.backgroundColor = self.modalBackgroundColor
            self.selectorModalView.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(self.selectorModalView)
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: 0))
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: 0))
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1,
                constant: 0))
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1,
                constant: 0))
            
            self.selectorView = UIView()
            self.selectorView.backgroundColor = self.selectorBackgroundColor
            self.selectorView.translatesAutoresizingMaskIntoConstraints = false
            self.selectorModalView.addSubview(self.selectorView)
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: 50))
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: -50))
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1,
                constant: 25))
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1,
                constant: -25))
            
            self.selectorHeaderView = UIView()
            self.selectorHeaderView.backgroundColor = self.headerBackgroundColor
            self.selectorHeaderView.translatesAutoresizingMaskIntoConstraints = false
            self.selectorView.addSubview(self.selectorHeaderView)
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 56))
            
            self.lblSelectorTitleLabel = UILabel()
            self.lblSelectorTitleLabel.text = self.title
            self.lblSelectorTitleLabel.textColor = self.titleColor
            if let font = self.titleFont {
                self.lblSelectorTitleLabel.font = font
            }
            self.lblSelectorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.selectorHeaderView.addSubview(self.lblSelectorTitleLabel)
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.lblSelectorTitleLabel,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1,
                constant: 0))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.lblSelectorTitleLabel,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1,
                constant: 0))
            
            self.btnSelectorCancel = UIButton()
            self.btnSelectorCancel.setTitle(self.cancelButtonTitle, forState: UIControlState.Normal)
            self.btnSelectorCancel.titleLabel?.textColor = self.cancelTextColor
            self.btnSelectorCancel.backgroundColor = self.cancelButtonBackgroundColor
            self.btnSelectorCancel.titleLabel?.textAlignment = NSTextAlignment.Left
            if let font = self.buttonFont {
                self.btnSelectorCancel.titleLabel?.font = font
            }
            self.btnSelectorCancel.translatesAutoresizingMaskIntoConstraints = false
            self.selectorHeaderView.addSubview(self.btnSelectorCancel)
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: 8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: -8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1,
                constant: 8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 40))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 50))
            
            self.btnSelectorDone = UIButton()
            self.btnSelectorDone.setTitle(self.doneButtonTitle, forState: UIControlState.Normal)
            self.btnSelectorDone.titleLabel?.textColor = self.doneTextColor
            self.btnSelectorDone.backgroundColor = self.doneButtonBackgroundColor
            self.btnSelectorDone.titleLabel?.textAlignment = NSTextAlignment.Right
            if let font = self.buttonFont {
                self.btnSelectorDone.titleLabel?.font = font
            }
            self.btnSelectorDone.translatesAutoresizingMaskIntoConstraints = false
            self.selectorHeaderView.addSubview(self.btnSelectorDone)
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: 8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: -8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1,
                constant: -8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 40))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 50))
            
            if self.enableSearch {
                self.searchView = UIView()
                self.searchView.translatesAutoresizingMaskIntoConstraints = false
                self.selectorView.addSubview(self.searchView)
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.selectorHeaderView,
                    attribute: NSLayoutAttribute.Bottom,
                    multiplier: 1,
                    constant: 0))
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.selectorView,
                    attribute: NSLayoutAttribute.Leading,
                    multiplier: 1,
                    constant: 0))
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.Trailing,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.selectorView,
                    attribute: NSLayoutAttribute.Trailing,
                    multiplier: 1,
                    constant: 0))
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: 46))
                
                self.txtKeyword = UITextField()
                self.txtKeyword.borderStyle = .RoundedRect
                self.txtKeyword.translatesAutoresizingMaskIntoConstraints = false
                self.searchView.addSubview(self.txtKeyword)
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1,
                    constant: 8))
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.Bottom,
                    multiplier: 1,
                    constant: -8))
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.Leading,
                    multiplier: 1,
                    constant: 8))
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.Trailing,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.Trailing,
                    multiplier: 1,
                    constant: -8))
                
                self.txtKeyword.placeholder = self.searchPlaceholder
                self.txtKeyword.font = self.itemFont
                self.txtKeyword.addTarget(self, action: #selector(BSDropdown.txtKeywordValueChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
            }
            
            self.selectorTableView = UITableView()
            self.selectorTableView.translatesAutoresizingMaskIntoConstraints = false
            self.selectorTableView.delegate = self
            self.selectorTableView.dataSource = self
            self.selectorTableView.separatorStyle = .None
            self.selectorView.addSubview(self.selectorTableView)
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.enableSearch ? self.searchView : self.selectorHeaderView,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.Leading,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.Leading,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.Trailing,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.Trailing,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: 0))
            
            self.btnSelectorCancel.addTarget(self, action: #selector(BSDropdown.btnSelectorCancelTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.btnSelectorDone.addTarget(self, action: #selector(BSDropdown.btnSelectorDoneTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.addTarget(self, action: #selector(BSDropdown.bsdDropdownClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            if self.hideDoneButton {
                self.btnSelectorDone.hidden = true
            }
            
            self.selectorModalView.hidden = true
            self.setTitle(self.defaultTitle, forState: UIControlState.Normal)
        }
        else{
            NSLog("BSDropdown Error : Please set the ViewController first")
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let values = self.data {
            return values.count
        }
        else{
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellInfoArray = self.data?.objectAtIndex(indexPath.row) as! NSDictionary
        if self.dataSource != nil {
            return self.dataSource.itemHeightForRowAtIndexPath(self, tableView: tableView, item: cellInfoArray, indexPath: indexPath)
        }
        else {
            let title = cellInfoArray.objectForKey(self.titleKey) as! String
            let minHeight:CGFloat = 35.0
            var height:CGFloat = 16.0
            var maxWidth:CGFloat = tableView.bounds.size.width - 16.0
            if indexPath.row == self.tempSelectedIndex {
                maxWidth -= 39.0
            }
            
            var titleHeight : CGFloat = title.boundingRectWithSize(
                CGSizeMake(maxWidth, 99999),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: self.itemFont!],
                context: nil
                ).size.height
            if titleHeight < 20 {
                titleHeight = 20
            }
            height += titleHeight
            
            return max(minHeight, height)
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellInfoArray = self.data?.objectAtIndex(indexPath.row) as! NSDictionary
        
        if self.dataSource != nil {
            let cell = self.dataSource.itemForRowAtIndexPath(self, tableView: tableView, item: cellInfoArray, indexPath: indexPath)
            
            cell.selectionStyle = .None
            cell.tintColor = self.itemTintColor
            
            if indexPath.row == self.tempSelectedIndex {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            
            return cell
        }
        else {
            let reuseId = "BSDropdownTableViewCell"
            var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(reuseId)
            let lblTitle: UILabel!
            let borderBottom: UIView!
            if let _ = cell {
                lblTitle = cell?.viewWithTag(1) as! UILabel
                borderBottom = cell?.viewWithTag(2)
            }
            else{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: reuseId)
                
                //add label
                lblTitle = UILabel()
                lblTitle.translatesAutoresizingMaskIntoConstraints = false
                cell!.addSubview(lblTitle)
                cell!.addConstraint(NSLayoutConstraint(item: lblTitle,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: lblTitle,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.Leading,
                    multiplier: 1,
                    constant: 8))
                cell!.addConstraint(NSLayoutConstraint(item: lblTitle,
                    attribute: NSLayoutAttribute.Trailing,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.Trailing,
                    multiplier: 1,
                    constant: 8))
                lblTitle.tag = 1
                lblTitle.textColor = self.itemTextColor
                lblTitle.font = self.itemFont
                
                //add border bottom
                borderBottom = UIView()
                borderBottom.backgroundColor = UIColor(white: 0.8, alpha: 1)
                borderBottom.translatesAutoresizingMaskIntoConstraints = false
                cell!.addSubview(borderBottom)
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.Left,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.Left,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.Right,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.Right,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.Bottom,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: 1))
                
                cell?.selectionStyle = .None
                cell?.tintColor = self.itemTintColor
            }
            
            lblTitle.text = cellInfoArray.objectForKey(self.titleKey) as? String
            
            if indexPath.row == self.tempSelectedIndex {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            else{
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
            
            return cell!
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let values = self.data {
            if indexPath.row > -1 && indexPath.row < values.count {
                self.tempSelectedIndex = indexPath.row
                self.selectorTableView.reloadData()
                if self.hideDoneButton {
                    self.btnSelectorDoneTouched(self.btnSelectorDone)
                }
            }
        }
        else{
            NSLog("BSDropdown Error : Please set the data first")
        }
    }
    
    public func bsdDropdownClicked(sender: AnyObject){
        if let vc = self.viewController {
            self.selectorTableView.reloadData()
            self.tempSelectedIndex = self.selectedIndex
            self.selectorModalView.hidden = false
            self.selectorModalView.alpha = 0
            vc.view.bringSubviewToFront(self.selectorModalView)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.selectorModalView.alpha = 1
            })
        }
    }
    
    public func btnSelectorCancelTouched(sender: AnyObject){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.selectorModalView.alpha = 0
            }, completion: { (Bool) -> Void in
                self.selectorModalView.hidden = true
                if self.enableSearch {
                    self.txtKeyword.text = ""
                    self.filterData("")
                }
        })
    }
    
    public func btnSelectorDoneTouched(sender: AnyObject){
        self.selectedIndex = self.tempSelectedIndex
        if self.tempSelectedIndex > -1 && self.tempSelectedIndex < self.data?.count {
            if let cellInfoArray = self.data?.objectAtIndex(self.tempSelectedIndex) as? NSDictionary {
                if let idx = cellInfoArray.objectForKey("bsd_index") as? NSNumber {
                    self.selectedIndex = idx.integerValue
                }
            }
        }
        if self.enableSearch {
            self.txtKeyword.text = ""
            self.filterData("")
        }
        self.setDisplayedTitle()
        self.btnSelectorCancelTouched(sender)
        
        if let d = self.delegate {
            d.onDropdownSelectedItemChange(self, selectedItem: self.getSelectedValue())
        }
    }
    
    private func setDisplayedTitle(){
        //set title
        if let value = self.getSelectedValue(){
            if !self.fixedDisplayedTitle {
                self.setTitle(value.objectForKey(self.titleKey) as? String, forState: UIControlState.Normal)
            }
            else {
                self.setTitle(self.defaultTitle, forState: UIControlState.Normal)
            }
        }
        else{
            self.setTitle(self.defaultTitle, forState: UIControlState.Normal)
        }
    }
    
    public func txtKeywordValueChanged(sender: AnyObject) {
        self.filterData(self.txtKeyword.text!)
        self.selectorTableView.reloadData()
    }
    
    private func filterData(keyword: String){
        self.data?.removeAllObjects()
        self.tempSelectedIndex = -1
        var i: Int = 0
        if let oriData = self.originalData {
            for item in oriData {
                if let cellInfoArray = item as? NSMutableDictionary {
                    if keyword == "" || (cellInfoArray.objectForKey(self.titleKey) as! String).lowercaseString.rangeOfString( keyword.lowercaseString ) != nil {
                        cellInfoArray.setValue(NSNumber(integer: i), forKey: "bsd_index")
                        self.data?.addObject(cellInfoArray)
                    }
                }
                else if let dict = item as? NSDictionary {
                    let cellInfoArray = NSMutableDictionary(dictionary: dict)
                    if keyword == "" || (cellInfoArray.objectForKey(self.titleKey) as! String).lowercaseString.rangeOfString( keyword.lowercaseString ) != nil {
                        cellInfoArray.setValue(NSNumber(integer: i), forKey: "bsd_index")
                        self.data?.addObject(cellInfoArray)
                    }
                }
                else{
                    NSLog("cellInfoArray invalid : %i", i)
                }
                i += 1
            }
        }
        
    }
    
    //public get set
    public func setDataSource(dataSource: NSMutableArray){
        self.originalData = dataSource
        self.data = NSMutableArray()
        self.filterData("")
    }
    
    public func setSelectedIndex(index: Int){
        self.selectedIndex = index
        self.setDisplayedTitle()
    }
    
    public func getSelectedIndex() -> Int {
        return self.selectedIndex
    }
    
    public func getSelectedValue() -> NSDictionary?{
        if let dataSource = self.originalData {
            if self.selectedIndex > -1 && self.selectedIndex < dataSource.count{
                return dataSource.objectAtIndex(self.selectedIndex) as? NSDictionary
            }
            else{
                return nil
            }
        }
        else{
            return nil
        }
    }
}