# GTConstants

A Constant and Localizable strings manager that allow for easy production & beta developemnt with the additional capability of overriding values from your server

## Installation

[![Version](http://cocoapod-badges.herokuapp.com/v/GTConstants/badge.png)](http://cocoadocs.org/docsets/GTConstants)
[![Platform](http://cocoapod-badges.herokuapp.com/p/GTConstants/badge.png)](http://cocoadocs.org/docsets/GTConstants)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Cocoapods
GTConstants is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "GTConstants"

### Carthage

    github "gametimesf/GTConstants" == 0.2.1

## Building

GTConstants 0.2.1 requires Swift 3.0.1

## Usage
In Your AppDelegate.swift configure the constants manager with a production plist and staging plist. Based on your current environment pass an override config or not.

We use the `overrideConfigFile` in our local development environments to
allow easily customization of your production constants. For things like
Braintree, hitting a development server, or using a custom Mixpanel
account is all done through redefining the constant in the
`overrideConfigFile`

See the following example below for how we override our production
values based on the `DEBUG` flag Xcode gives you


#### Set up
```swift
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    #if DEBUG
        GTConstantsManager.sharedInstance.config = alphaConfig()
    #else
        GTConstantsManager.sharedInstance.config = prodConfig()
    #endif

        return true
    }

    // Where Constants is a .plist file in your /Resources directory
    private class func prodConfig() -> GTConstantsManagerConfig {
        return GTConstantsManagerConfig(defaultConfigFile: "Constants",
                                        overrideConfigFile: []
        )
    }

    // Where Constants_testing is a .plist file in your /Resources directory
    private class func alphaConfig() -> GTConstantsManagerConfig {
        return GTConstantsManagerConfig(defaultConfigFile: "Constants",
                                        overrideConfigFile: ["Constants_testing"]
        )
    }
}
```
### In Use
#### Constants
```swift
import GTConstants
class MyTableViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        GMSServices.provideAPIKey(GTConstantsManager.sharedInstance.string(key: "google_maps_api_key))
    }
}
```

#### Strings

Add a file titled: `Resources/Localizable.strings` file inside of /Resources where you might have the following keys
```
"MyTableViewController.TITLE" = "My first Table View Controller";
"MyTableViewController.WelcomeBack.User" = "Welcome back, %@";
```
And then you can simply call:
```swift
import GTConstants
class MyTableViewController : UITableViewController {
    @IBOutlet private weak var userWelcomeBackLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MyTableViewController.TITLE".localized()
        userWelcomeBackLabel?.text = "MyTableViewController.TITLE".localized(args: "Mike")
    }
}
```

#### Interceptions

Now the real power of  `GTConstants` comes into play. The ability to on the fly override constants and strings. Simply add an `interceptions_url` string value pointing to your server in your Constants.plist file returning the following structure:
```
"hotfixes": {
    "google_maps_api_key": "abc123",
    "MyTableViewController.WelcomeBack.User": "Hi, %@",
}
```

Now with this on applaunch, the constants manager will automatically make an api call to the `interceptions_url` you configured above and allow easy override of values you have configured in either your `Resources/Localizable.strings` file and `Resources/Constants.plist` file

So now if we take the above example:
```swift
import GTConstants
class MyTableViewController : UITableViewController {
    @IBOutlet private weak var userWelcomeBackLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MyTableViewController.TITLE".localized()
        userWelcomeBackLabel?.text = "MyTableViewController.TITLE".localizedWithArgs("Mike")
    }
}
```

The `userWelcomeBacklabel` will now output => `Hi, Mike` instead of the `Welcome back, Mike` as defined in our Localization file.

### Usage inside of Storyboards
Here at Gametime we love Storyboards and xibs. And with the advent of `@IBInspectable` it is now easier then ever to localize `UILabels`, `UIButtons`, `UIBarButtonItems`, and `UIViewController` titles. If you installed the framework with `Cocoapods` your work here is done. Simply open any Storyboard file and click on a `UILabel` and you will now see the new fields rendered automatically. If You used `Carthage` you will need to copy and paste [extension-GTConstantsInspectable](https://github.com/gametimesf/GTConstants/blob/master/Source/extension-GTInspectable.swift) into your repo due to the [framework not living inside your application](http://stackoverflow.com/a/29977368)

<img src="https://raw.githubusercontent.com/gametimesf/GTConstants/master/Resources/localizable-helper.png" alt="" />

### App Updates

`GTConstants` also gives your app the ability to check whether it's compatible with your mimimum app and iOS version requirements. The `interceptions_url` string pointing to your server should return the following structure:

```
"update": {
        "ios": [
            {   
                "restriction": 0,
                "active": 1,
                "min_app_version": {
                    "version": "8.2.1",
                    "message": {
                        "en": "App version 8.2.1 update message"
                    }
                },
                "min_os_version": {
                    "version": "9",
                    "message": {
                        "en": "iOS version 9 update message"
                    }
                }
            },
            {   
                "restriction": 2,
                "active": 1,
                "min_app_version": {
                    "version": "5.1",
                    "message": {
                        "en": "App version 5.1 update message"
                    }
                },
                "min_os_version": {
                    "version": "7.2",
                    "message": {
                        "en": "iOS version 7.2 update message"
                    }
                }
            }
        ]
    }
```

The configuration above allows you to add update rules by specifying the restriction level as well as the minimum app and OS version you'd like to support for your app. You can also add multiple update rules to the `ios` array if app and OS versions should have separate restriction levels (i.e. 0,1,2 -> low, medium, high).

After the constants manager makes an api call to the `interceptions_url`, the interceptions manager will automatically check whether your app is in violation of the rules and provide the update data.

#### Usage

To check whether the user needs to update their app, simply call `GTInterceptionsManager.sharedInstance.updateNeeded`. To check the update rule the user is in violation of, simply call `GTInterceptionsManager.sharedInstance.updateRule`. You may also want to use the `GTInterceptionsManager.sharedInstance.dataSyncCompletion` handler to determine whether update data from your server was received successfully.

#### Example

Say you want to show an update warning to users of app version 8.2.1 and iOS 9 and limit the functionality of your app to users of app version 5.1 and iOS 7.2, you can specify a low restriction for the former and a high restriction for the latter as shown in the configuration above.

If the user has app version 4.2, the returned update rule will be of restriction 2 (high). If the user has app version 6.5, the returned update rule will be of restriction 0 (low). If the user's app version is 9.6, no update rule will be returned and `updateNeeded` will be false. The returned update rule is always the one the user is in violation of with the highest restriction.

For this scenario, we can do

`````
GTInterceptionManager.sharedInstance.dataSyncCompletion { status in
    guard status != .error else {
        // show error
        return
    }

    guard status == .complete else { return }

    let rule = GTInterceptionManager.sharedInstance.updateRule

    if rule.restriction == .high {
        // limit functionality
    } else if rule.restriction == .low {
        // show warning
    }
}
````

## Updates

- 0.1.21 Added ability to toggle maintance mode
- 0.1.20 Added ability to check for app updates
- 0.1.17 Updated Syntax & Ability to specify an array of override
  configs
- 0.1.16 XCode 8.2 project issue fix
- 0.1.15 Migrating to GT naming
- 0.1.14 Updating for Swift 3
- 0.1.9: Updating for Swift 2.3
- 0.1.8: Initial release for use with both Carthage and Cocoapods

## Requirements

- Xcode 7
- iOS 9

## Authors

- Mike Silvis, https://github.com/mikesilvis
- Rich Lowenberg, https://github.com/richlowenberg

## License

GTConstants is available under the MIT license. See the LICENSE file for more info.
