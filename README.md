# Interactive
InteractiveViewController for iOS, written in swift

[Demo on Appetize.io](https://appetize.io/app/yu2cecz67qvvxcrwagrnfq229m?device=iphone7&scale=75&orientation=portrait&osVersion=10.0)

![Preview](interactive.gif)


## usage

- Just inherit your UIViewController from InteractiveViewController

```swift
class ExampleViewController: InteractiveViewController {
        }
```

- Use showInteractive() method to show

```swift
if let vc = storyboard?.instantiateViewController(withIdentifier: "ExampleViewController") as? InteractiveViewController {
            
            vc.allowedDismissDirection = dismissDirection(rawValue: dismissDirectionControll.selectedSegmentIndex)!
            vc.directionLock = diractioLockSwitch.isOn
            vc.maskType = InteractiveMaskType(rawValue: UInt(maskTypeSegmentedControl.selectedSegmentIndex))!
            
            vc.showInteractive()
        }
```

That's it, enjoy.
