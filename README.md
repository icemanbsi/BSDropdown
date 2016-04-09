# BSDropdown

[![CI Status](http://img.shields.io/travis/Bobby Stenly/BSDropdown.svg?style=flat)](https://travis-ci.org/Bobby Stenly/BSDropdown)
[![Version](https://img.shields.io/cocoapods/v/BSDropdown.svg?style=flat)](http://cocoapods.org/pods/BSDropdown)
[![License](https://img.shields.io/cocoapods/l/BSDropdown.svg?style=flat)](http://cocoapods.org/pods/BSDropdown)
[![Platform](https://img.shields.io/cocoapods/p/BSDropdown.svg?style=flat)](http://cocoapods.org/pods/BSDropdown)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<!--## Requirements-->

## Installation

BSDropdown is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BSDropdown"
```

## How To Use

First thing first, you need to create the BSDropdown element. If you are using the storyboard or xib, create a UIButton then change the class name to BSDropdown and the module to BSDropdown. Please set the viewController attribute and run the setup function.

```swift
self.bsdFirst.viewController = self
self.bsdFirst.title = "First Dropdown"
self.bsdFirst.defaultTitle = "Default"
self.bsdFirst.setup()
```
You can add some data by calling the `setDataSource` function.

```swift
let firstOptions = NSMutableArray()
firstOptions.addObject(["title" : "Option 1", "value" : "opt 1"])
firstOptions.addObject(["title" : "Option 2", "value" : "opt 2"])
firstOptions.addObject(["title" : "Option 3", "value" : "opt 3"])
self.bsdFirst.setDataSource(firstOptions)
```

If you have a lot of options, you can add a search box too. 
```swift
self.bsdFirst.viewController = self
self.bsdFirst.title = "First Dropdown"
self.bsdFirst.defaultTitle = "Default"
self.bsdFirst.enableSearch = true
self.bsdFirst.setup()
```

## Author

Bobby Stenly, iceman.bsi@gmail.com

## License

BSDropdown is available under the MIT license. See the LICENSE file for more info.
