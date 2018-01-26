//
//  StepViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 17/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import RNActivityView
import EasyToast


class StepViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var selectedZone : Zone!
    var pageViewController: UIPageViewController?
    var allPageCovered: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        initialise()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StepViewController.modalValueChangedLocalNotification), name: NSNotification.Name(rawValue: "modalValueChangedLocalNotificationIdentifier"), object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblTitle?.text = selectedZone.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func modalValueChangedLocalNotification() {
        checkForCompletion()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ComponentsViewController)
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ComponentsViewController)
        index += 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            
            self.pageViewController!.isDoubleSided = false
            return .min
        }
        
        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! ComponentsViewController
        var viewControllers: [UIViewController]
        
        let indexOfCurrentViewController = self.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
        
        return .mid
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            let currentViewController = self.pageViewController!.viewControllers![0] as! ComponentsViewController
            let index = self.indexOfViewController(currentViewController)
            self.pageIndicator.currentPage = index
            enableBtn(btn: btnBack, enable: index > 0)
            enableBtn(btn: btnNext, enable: index < self.selectedZone.steps.count-1 )
            if index == self.selectedZone.steps.count - 1 {
                allPageCovered = true
                checkForCompletion()
            }
        }
    }

    
    // MARK: - Actions

    @IBAction func btnBackTapped(_ sender: Any) {
        
        let currentViewController = self.pageViewController!.viewControllers![0] as! ComponentsViewController
        
        var index = self.indexOfViewController(currentViewController)
        index -= 1

        if let startingViewController = self.viewControllerAtIndex(index, storyboard: currentViewController.storyboard!) {
            let viewControllers : [UIViewController] = [startingViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .reverse, animated: true, completion: {done in })
            self.pageIndicator.currentPage = index
        }
        enableBtn(btn: btnBack, enable: index > 0)
        enableBtn(btn: btnNext, enable: index < self.selectedZone.steps.count-1 )
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
        selectedZone.updated = 1
    }
    
    @IBAction func btnNextTapped(_ sender: Any) {
        
        let currentViewController = self.pageViewController!.viewControllers![0] as! ComponentsViewController
        
        var index = self.indexOfViewController(currentViewController)
        index += 1
        
        if let startingViewController = self.viewControllerAtIndex(index, storyboard: currentViewController.storyboard!) {
            let viewControllers : [UIViewController] = [startingViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            self.pageIndicator.currentPage = index
        }
        enableBtn(btn: btnBack, enable: index > 0)
        enableBtn(btn: btnNext, enable: index < self.selectedZone.steps.count-1 )
        if index == self.selectedZone.steps.count - 1 {
            allPageCovered = true
            checkForCompletion()
        }
    }
    
    
    // MARK: - Utils

    func initialise() {
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        let startingViewController: ComponentsViewController = self.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self
        
        self.addChildViewController(self.pageViewController!)
        self.containerView.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.containerView.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParentViewController: self)
        
        self.pageIndicator.numberOfPages = self.selectedZone.steps.count
        enableBtn(btn: btnBack, enable: false)
        if selectedZone.steps.count < 1 {
            enableBtn(btn: btnNext, enable: false)
         //   enableBtn(btn: btnDone, enable: true)
        }
        if selectedZone.steps.count == 6 {
            enableBtn(btn: btnDone, enable: false)
        }
      
      //  enableBtn(btn: btnDone, enable: false)
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> ComponentsViewController? {
        // Return the data view controller for the given index.
        if (self.selectedZone.steps.count == 0) || (index >= self.selectedZone.steps.count || index < 0) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "ComponentsViewController") as! ComponentsViewController
        dataViewController.step = self.selectedZone.steps[index]
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: ComponentsViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return selectedZone.steps.index{$0 === viewController.step} ?? NSNotFound
    }
    
    func checkForCompletion() {
        for step in self.selectedZone.steps {
            if step.isAllowtoSkip.intValue > 0 {
                continue
            }
            for type in step.componentTypes {
                if type.getModelType() != .none {
                    if !type.modelValueRecorded {
                        return
                    }
                }
            }
        }
        if allPageCovered {
            enableBtn(btn: btnDone, enable: true)
        }
    }
    
    func enableBtn(btn: UIButton, enable: Bool) {
        btn.setTitleColor((enable ? UIColor.white : UIColor.gray), for: .normal)
        btn.isUserInteractionEnabled = enable
    }

}
