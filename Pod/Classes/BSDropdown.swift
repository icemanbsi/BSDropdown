//
//  BSDropdown.swift
//  V2.0.1
//
//  Items selector with a pop up table list view.
//  You can use a NSMutableArray of NSDictionary for the data source
//
//  Created by Bobby Stenly Irawan ( iceman.bsi@gmail.com - http://bobbystenly.com ) on 11/21/15.
//  Copyright © 2015 Bobby Stenly Irawan. All rights reserved.
//
//  New in V2.0.1
//  - update to swift 3
//
//  New in V1.3
//  - change viewController into weak var
//
//  New in V1.2
//  - added DataSource Protocol for custom tableview cell / layout
//  - added fixedDisplayedTitle to make the default title fixed (not change even the selected item has changed)

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public protocol BSDropdownDelegate {
    func onDropdownSelectedItemChange(_ dropdown: BSDropdown, selectedItem: NSDictionary?)
}
extension BSDropdownDelegate {
    func onDropdownSelectedItemChange(_ dropdown: BSDropdown, selectedItem: NSDictionary?) {
    }
}

public protocol BSDropdownDataSource {
    func itemHeightForRowAtIndexPath(_ dropdown: BSDropdown, tableView: UITableView, item: NSDictionary?, indexPath: IndexPath) -> CGFloat
    func itemForRowAtIndexPath(_ dropdown: BSDropdown, tableView: UITableView, item: NSDictionary?, indexPath: IndexPath) -> UITableViewCell
}

open class BSDropdown:UIButton, UITableViewDelegate, UITableViewDataSource{
    //required attributes
    open weak var viewController: UIViewController?
    //--end of required attributes
    
    //optional attributes
    open var delegate: BSDropdownDelegate!
    open var dataSource: BSDropdownDataSource!
    open var modalBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.5)
    open var selectorBackgroundColor: UIColor = UIColor(white: 1, alpha: 1)
    open var headerBackgroundColor: UIColor = UIColor(white: 0, alpha: 1)
    open var titleColor: UIColor = UIColor(white: 1, alpha: 1)
    open var cancelButtonBackgroundColor: UIColor = UIColor(white: 0, alpha: 0)
    open var doneButtonBackgroundColor: UIColor = UIColor(white: 0, alpha: 0)
    open var cancelTextColor: UIColor = UIColor(white: 0.8, alpha: 1)
    open var doneTextColor: UIColor = UIColor(white: 0.8, alpha: 1)
    open var itemTextColor: UIColor = UIColor(white: 0, alpha: 1)
    open var itemTintColor: UIColor = UIColor(white: 0, alpha: 0.8)
    open var titleFont:UIFont? = UIFont(name: "Helvetica", size: 16)
    open var buttonFont:UIFont? = UIFont(name: "Helvetica", size: 13)
    open var itemFont:UIFont? = UIFont(name: "Helvetica", size: 13)
    open var title: String = "title"
    open var cancelButtonTitle: String = "Cancel"
    open var doneButtonTitle: String = "Done"
    open var defaultTitle: String = "Select Item"
    open var titleKey: String = "title"
    open var enableSearch: Bool = false
    open var searchPlaceholder: String = "Search"
    open var fixedDisplayedTitle: Bool = false
    open var hideDoneButton: Bool = false
    //-- end of optional attributes
    
    fileprivate var selectedIndex: Int = -1
    fileprivate var tempSelectedIndex: Int = -1
    fileprivate var data: NSMutableArray?
    fileprivate var originalData: NSMutableArray?
    
    fileprivate var selectorModalView: UIView!
    fileprivate var selectorView: UIView!
    fileprivate var selectorHeaderView: UIView!
    fileprivate var lblSelectorTitleLabel: UILabel!
    fileprivate var btnSelectorCancel: UIButton!
    fileprivate var btnSelectorDone: UIButton!
    fileprivate var selectorTableView: UITableView!
    fileprivate var searchView: UIView!
    fileprivate var txtKeyword: UITextField!
    
    open func setup(){
        if let vc = self.viewController {
            
            self.selectorModalView = UIView()
            self.selectorModalView.backgroundColor = self.modalBackgroundColor
            self.selectorModalView.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(self.selectorModalView)
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.top,
                multiplier: 1,
                constant: 0))
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: 0))
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1,
                constant: 0))
            vc.view.addConstraint(NSLayoutConstraint(item: self.selectorModalView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: vc.view,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1,
                constant: 0))
            
            self.selectorView = UIView()
            self.selectorView.backgroundColor = self.selectorBackgroundColor
            self.selectorView.translatesAutoresizingMaskIntoConstraints = false
            self.selectorModalView.addSubview(self.selectorView)
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1,
                constant: 50))
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: -50))
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1,
                constant: 25))
            self.selectorModalView.addConstraint(NSLayoutConstraint(item: self.selectorView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorModalView,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1,
                constant: -25))
            
            self.selectorHeaderView = UIView()
            self.selectorHeaderView.backgroundColor = self.headerBackgroundColor
            self.selectorHeaderView.translatesAutoresizingMaskIntoConstraints = false
            self.selectorView.addSubview(self.selectorHeaderView)
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorHeaderView,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
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
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1,
                constant: 0))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.lblSelectorTitleLabel,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1,
                constant: 0))
            
            self.btnSelectorCancel = UIButton()
            self.btnSelectorCancel.setTitle(self.cancelButtonTitle, for: UIControlState())
            self.btnSelectorCancel.titleLabel?.textColor = self.cancelTextColor
            self.btnSelectorCancel.backgroundColor = self.cancelButtonBackgroundColor
            self.btnSelectorCancel.titleLabel?.textAlignment = NSTextAlignment.left
            if let font = self.buttonFont {
                self.btnSelectorCancel.titleLabel?.font = font
            }
            self.btnSelectorCancel.translatesAutoresizingMaskIntoConstraints = false
            self.selectorHeaderView.addSubview(self.btnSelectorCancel)
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1,
                constant: 8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: -8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1,
                constant: 8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
                multiplier: 1,
                constant: 40))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorCancel,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
                multiplier: 1,
                constant: 50))
            
            self.btnSelectorDone = UIButton()
            self.btnSelectorDone.setTitle(self.doneButtonTitle, for: UIControlState())
            self.btnSelectorDone.titleLabel?.textColor = self.doneTextColor
            self.btnSelectorDone.backgroundColor = self.doneButtonBackgroundColor
            self.btnSelectorDone.titleLabel?.textAlignment = NSTextAlignment.right
            if let font = self.buttonFont {
                self.btnSelectorDone.titleLabel?.font = font
            }
            self.btnSelectorDone.translatesAutoresizingMaskIntoConstraints = false
            self.selectorHeaderView.addSubview(self.btnSelectorDone)
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.top,
                multiplier: 1,
                constant: 8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: -8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorHeaderView,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1,
                constant: -8))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
                multiplier: 1,
                constant: 40))
            self.selectorHeaderView.addConstraint(NSLayoutConstraint(item: self.btnSelectorDone,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
                multiplier: 1,
                constant: 50))
            
            if self.enableSearch {
                self.searchView = UIView()
                self.searchView.translatesAutoresizingMaskIntoConstraints = false
                self.selectorView.addSubview(self.searchView)
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.top,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.selectorHeaderView,
                    attribute: NSLayoutAttribute.bottom,
                    multiplier: 1,
                    constant: 0))
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.leading,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.selectorView,
                    attribute: NSLayoutAttribute.leading,
                    multiplier: 1,
                    constant: 0))
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.trailing,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.selectorView,
                    attribute: NSLayoutAttribute.trailing,
                    multiplier: 1,
                    constant: 0))
                self.selectorView.addConstraint(NSLayoutConstraint(item: self.searchView,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 1,
                    constant: 46))
                
                self.txtKeyword = UITextField()
                self.txtKeyword.borderStyle = .roundedRect
                self.txtKeyword.translatesAutoresizingMaskIntoConstraints = false
                self.searchView.addSubview(self.txtKeyword)
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.top,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.top,
                    multiplier: 1,
                    constant: 8))
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.bottom,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.bottom,
                    multiplier: 1,
                    constant: -8))
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.leading,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.leading,
                    multiplier: 1,
                    constant: 8))
                self.searchView.addConstraint(NSLayoutConstraint(item: self.txtKeyword,
                    attribute: NSLayoutAttribute.trailing,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.searchView,
                    attribute: NSLayoutAttribute.trailing,
                    multiplier: 1,
                    constant: -8))
                
                self.txtKeyword.placeholder = self.searchPlaceholder
                self.txtKeyword.font = self.itemFont
                self.txtKeyword.addTarget(self, action: #selector(BSDropdown.txtKeywordValueChanged(_:)), for: UIControlEvents.editingChanged)
            }
            
            self.selectorTableView = UITableView()
            self.selectorTableView.translatesAutoresizingMaskIntoConstraints = false
            self.selectorTableView.delegate = self
            self.selectorTableView.dataSource = self
            self.selectorTableView.separatorStyle = .none
            self.selectorView.addSubview(self.selectorTableView)
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.enableSearch ? self.searchView : self.selectorHeaderView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.leading,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.leading,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.trailing,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.trailing,
                multiplier: 1,
                constant: 0))
            self.selectorView.addConstraint(NSLayoutConstraint(item: self.selectorTableView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.selectorView,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1,
                constant: 0))
            
            self.btnSelectorCancel.addTarget(self, action: #selector(BSDropdown.btnSelectorCancelTouched(_:)), for: UIControlEvents.touchUpInside)
            self.btnSelectorDone.addTarget(self, action: #selector(BSDropdown.btnSelectorDoneTouched(_:)), for: UIControlEvents.touchUpInside)
            self.addTarget(self, action: #selector(BSDropdown.bsdDropdownClicked(_:)), for: UIControlEvents.touchUpInside)
            
            if self.hideDoneButton {
                self.btnSelectorDone.isHidden = true
            }
            
            self.selectorModalView.isHidden = true
            self.setTitle(self.defaultTitle, for: UIControlState())
        }
        else{
            NSLog("BSDropdown Error : Please set the ViewController first")
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let values = self.data {
            return values.count
        }
        else{
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellInfoArray = self.data?.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        if self.dataSource != nil {
            return self.dataSource.itemHeightForRowAtIndexPath(self, tableView: tableView, item: cellInfoArray, indexPath: indexPath)
        }
        else {
            let title = cellInfoArray.object(forKey: self.titleKey) as! String
            let minHeight:CGFloat = 35.0
            var height:CGFloat = 16.0
            var maxWidth:CGFloat = tableView.bounds.size.width - 16.0
            if (indexPath as NSIndexPath).row == self.tempSelectedIndex {
                maxWidth -= 39.0
            }
            
            var titleHeight : CGFloat = title.boundingRect(
                with: CGSize(width: maxWidth, height: 99999),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
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
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfoArray = self.data?.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        
        if self.dataSource != nil {
            let cell = self.dataSource.itemForRowAtIndexPath(self, tableView: tableView, item: cellInfoArray, indexPath: indexPath)
            
            cell.selectionStyle = .none
            cell.tintColor = self.itemTintColor
            
            if (indexPath as NSIndexPath).row == self.tempSelectedIndex {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell
        }
        else {
            let reuseId = "BSDropdownTableViewCell"
            var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseId)
            let lblTitle: UILabel!
            let borderBottom: UIView!
            if let _ = cell {
                lblTitle = cell?.viewWithTag(1) as! UILabel
                borderBottom = cell?.viewWithTag(2)
            }
            else{
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseId)
                
                //add label
                lblTitle = UILabel()
                lblTitle.translatesAutoresizingMaskIntoConstraints = false
                cell!.addSubview(lblTitle)
                cell!.addConstraint(NSLayoutConstraint(item: lblTitle,
                    attribute: NSLayoutAttribute.centerY,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.centerY,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: lblTitle,
                    attribute: NSLayoutAttribute.leading,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.leading,
                    multiplier: 1,
                    constant: 8))
                cell!.addConstraint(NSLayoutConstraint(item: lblTitle,
                    attribute: NSLayoutAttribute.trailing,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.trailing,
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
                    attribute: NSLayoutAttribute.left,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.left,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.right,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.right,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.bottom,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cell,
                    attribute: NSLayoutAttribute.bottom,
                    multiplier: 1,
                    constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: borderBottom,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 1,
                    constant: 1))
                
                cell?.selectionStyle = .none
                cell?.tintColor = self.itemTintColor
            }
            
            lblTitle.text = cellInfoArray.object(forKey: self.titleKey) as? String
            
            if (indexPath as NSIndexPath).row == self.tempSelectedIndex {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else{
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell!
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let values = self.data {
            if (indexPath as NSIndexPath).row > -1 && (indexPath as NSIndexPath).row < values.count {
                self.tempSelectedIndex = (indexPath as NSIndexPath).row
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
    
    open func bsdDropdownClicked(_ sender: AnyObject){
        if let vc = self.viewController {
            self.selectorTableView.reloadData()
            self.tempSelectedIndex = self.selectedIndex
            self.selectorModalView.isHidden = false
            self.selectorModalView.alpha = 0
            vc.view.bringSubview(toFront: self.selectorModalView)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.selectorModalView.alpha = 1
            })
        }
    }
    
    open func btnSelectorCancelTouched(_ sender: AnyObject){
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.selectorModalView.alpha = 0
            }, completion: { (Bool) -> Void in
                self.selectorModalView.isHidden = true
                if self.enableSearch {
                    self.txtKeyword.text = ""
                    self.filterData("")
                }
        })
    }
    
    open func btnSelectorDoneTouched(_ sender: AnyObject){
        self.selectedIndex = self.tempSelectedIndex
        if self.tempSelectedIndex > -1 && self.tempSelectedIndex < self.data?.count {
            if let cellInfoArray = self.data?.object(at: self.tempSelectedIndex) as? NSDictionary {
                if let idx = cellInfoArray.object(forKey: "bsd_index") as? NSNumber {
                    self.selectedIndex = idx.intValue
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
    
    fileprivate func setDisplayedTitle(){
        //set title
        if let value = self.getSelectedValue(){
            if !self.fixedDisplayedTitle {
                self.setTitle(value.object(forKey: self.titleKey) as? String, for: UIControlState())
            }
            else {
                self.setTitle(self.defaultTitle, for: UIControlState())
            }
        }
        else{
            self.setTitle(self.defaultTitle, for: UIControlState())
        }
    }
    
    open func txtKeywordValueChanged(_ sender: AnyObject) {
        self.filterData(self.txtKeyword.text!)
        self.selectorTableView.reloadData()
    }
    
    fileprivate func filterData(_ keyword: String){
        self.data?.removeAllObjects()
        self.tempSelectedIndex = -1
        var i: Int = 0
        if let oriData = self.originalData {
            for item in oriData {
                if let cellInfoArray = item as? NSMutableDictionary {
                    if keyword == "" || (cellInfoArray.object(forKey: self.titleKey) as! String).lowercased().range( of: keyword.lowercased() ) != nil {
                        cellInfoArray.setValue(NSNumber(value: i as Int), forKey: "bsd_index")
                        self.data?.add(cellInfoArray)
                    }
                }
                else if let dict = item as? NSDictionary {
                    let cellInfoArray = NSMutableDictionary(dictionary: dict)
                    if keyword == "" || (cellInfoArray.object(forKey: self.titleKey) as! String).lowercased().range( of: keyword.lowercased() ) != nil {
                        cellInfoArray.setValue(NSNumber(value: i as Int), forKey: "bsd_index")
                        self.data?.add(cellInfoArray)
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
    open func setDataSource(_ dataSource: NSMutableArray){
        self.originalData = dataSource
        self.data = NSMutableArray()
        self.filterData("")
    }
    
    open func setSelectedIndex(_ index: Int){
        self.selectedIndex = index
        self.setDisplayedTitle()
    }
    
    open func getSelectedIndex() -> Int {
        return self.selectedIndex
    }
    
    open func getSelectedValue() -> NSDictionary?{
        if let dataSource = self.originalData {
            if self.selectedIndex > -1 && self.selectedIndex < dataSource.count{
                return dataSource.object(at: self.selectedIndex) as? NSDictionary
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
