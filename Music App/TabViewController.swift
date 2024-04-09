//
//  ForYouViewController.swift
//  Music App
//
//  Created by Simran on 03/04/24.
//

import UIKit
import SJSegmentedScrollView

class TabViewController: UIViewController {
    
   // var segmentedViewController: SJSegmentedViewController!
    
    @IBOutlet weak var segmentedViewController: UISegmentedControl!
    
    @IBOutlet weak var ViewForDisplay: UIView!
    
    var firstViewController: ViewController!
    var secondViewController: TopTrackViewController!
    
    // Define the font style and font color
    let font = UIFont.systemFont(ofSize: 17, weight: .bold)
    let FontStyle = UIFont.fontNames(forFamilyName: "SF Pro Display")
    let fontColor = UIColor.gray
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create view controllers for each segment
 
        // Load child view controllers
                firstViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
                secondViewController = storyboard?.instantiateViewController(withIdentifier: "TopTrackViewController") as? TopTrackViewController
        
        // Function For Title Font
        setFontForTitle()
        
        
        // Add first view controller as default
                addChild(firstViewController)
                ViewForDisplay.addSubview(firstViewController.view)
                firstViewController.didMove(toParent: self)
    }
    
    @IBAction func SegmentActionBtn(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
                case 0:
                    switchToViewController(viewController: firstViewController)
                case 1:
                    switchToViewController(viewController: secondViewController)
                default:
                    break
                }
    }
    
   
    
    func switchToViewController(viewController: UIViewController) {
           // Remove currently displayed view controller
           for childVC in children {
               childVC.removeFromParent()
               childVC.view.removeFromSuperview()
           }
           
           // Add new view controller
           addChild(viewController)
            ViewForDisplay.addSubview(viewController.view)
           viewController.view.frame = ViewForDisplay.bounds
           viewController.didMove(toParent: self)
       }
    
    func setFontForTitle(){
        // Set the text attributes for normal state
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: fontColor
        ]
        
        // Apply the text attributes to the segmented control
        segmentedViewController.tintColor = .gray
        segmentedViewController.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedViewController.setTitleTextAttributes(normalTextAttributes, for: .normal)
    }
    
}
