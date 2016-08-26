# GAMConstants

A Constant and Localizable strings manager that allow for easy production & beta developemnt with the additional capability of overriding values from your server

## Installation


[![Version](http://cocoapod-badges.herokuapp.com/v/GAMConstants/badge.png)](http://cocoadocs.org/docsets/GAMConstants)
[![Platform](http://cocoapod-badges.herokuapp.com/p/GAMConstants/badge.png)](http://cocoadocs.org/docsets/GAMConstants)

### Cocoapods
CSStickyHeaderFlowLayout is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "GAMConstants"

### Carthage

    github "gametimesf/GAMConstants" == 0.1.8

## Usage
In Your AppDelegate.swift configure the constants manager with a production plist and staging plist. Based on your current environment pass an override config or not.

#### Set up
```
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    #if DEBUG
        GAMConstantsManager.sharedInstance.config = alphaConfig()
    #else
        GAMConstantsManager.sharedInstance.config = prodConfig()
    #endif


        return true
    }

    // Where Constants is a .plist file in your /Resources directory
    private class func prodConfig() -> GAMConstantsManagerConfig {
        return GAMConstantsManagerConfig(defaultConfigFile: "Constants",
                                        overrideConfigFile: nil
        )
    }

    // Where Constants_testing is a .plist file in your /Resources directory
    private class func alphaConfig() -> GAMConstantsManagerConfig {
        return GAMConstantsManagerConfig(defaultConfigFile: "Constants",
                                        overrideConfigFile: "Constants_testing"
        )
    }
}
```
### In Use
#### Constants
```
import GAMConstants
class MyTableViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        GMSServices.provideAPIKey(GAMConstantsManager.sharedInstance.stringForID("google_maps_api_key))
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
```
import GAMConstants
class MyTableViewController : UITableViewController {
    @IBOutlet private weak var userWelcomeBackLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "MyTableViewController.TITLE".localized()
        userWelcomeBackLabel?.text = "MyTableViewController.TITLE".localizedWithArgs("Mike")
    }
}
```

#### Interceptions

Now the real power of  `GAMConstants` comes into play. The ability to on the fly override constants and strings. Simply add an `interceptions_url` string value pointing to your server in your Constants.plist file returning the following structure:
```
"hotfixes": {
    "google_maps_api_key": "abc123",
    "MyTableViewController.WelcomeBack.User": "Hi, %@",
}
```

Now with this on applaunch, the constants manager will automatically make an api call to the `interceptions_url` you configured above and allow easy override of values you have configured in either your `Resources/Localizable.strings` file and `Resources/Constants.plist` file

So now if we take the above example:
```
import GAMConstants
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
Here at Gametime we love Storyboards and nibs. And with the advent of `@IBInspectable` it is now easier then ever to localize `UILabels`, `UIButtons`, `UIBarButtonItems`, and `UIViewController` titles. If you installed the framework with `Cocoapods` your work here is done. Simply open any Storyboard file and click on a `UILabel` and you will now see the new fields rendered automatically. If You used `Carthage` since it is a compiled framework you will need to copy and paste [extension-GAMConstantsInspectable](https://www.google.com) into your repo :(

<img src="https://raw.githubusercontent.com/gametimesf/GAMConstants/master/Resources/localizable-helper.png" alt="" />

## Updates

- 0.1.18: Initial release for use with both Carthage and Cocoapods

## Requirements

- Xcode 7
- iOS 9

## Author

Mike Silvis, mike@gametime.co

## License

GAMConstants is available under the MIT license. See the LICENSE file for more info.
