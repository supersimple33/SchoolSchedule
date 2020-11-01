//
//  PageViewController.swift
//  SchoolSchedule
//
//  Created by Addison Hanrattie on 2/1/18.
//  Copyright © 2018 Addison Hanrattie. All rights reserved.
//

import UIKit
import CoreData

class PageViewController: UIPageViewController, UIGestureRecognizerDelegate {
    
    var context: NSManagedObjectContext!
    
    fileprivate lazy var pages: [UIViewController] = {
        var returner: [UIViewController] = []
        returner.append(self.getViewController(withIdentifier: "OpeningView"))
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ClassResources")
        var classes: [NSManagedObject] = []
        do {
            classes = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        if classes != [] {
            returner.append(self.getViewController(withIdentifier: "WeeklyView"))
            for classroom in classes {
                let id = classroom.value(forKey: "classnumber") as! Int
                let vic = self.getViewController(withIdentifier: "ClassesView")
                vic.restorationIdentifier = "\(id)"
                print(vic.restorationIdentifier!)
                returner.append(vic)
            }
        } else {
            returner.append(self.getViewController(withIdentifier: "TutorialView")) // recall set views after setting
            returner.append(self.getViewController(withIdentifier: "WeeklyView"))
        }
        returner.append(self.getViewController(withIdentifier: "ScheduleView"))
        
        return returner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataStack.managedObjectContext
        self.dataSource = self
        self.delegate = self
        if let firstVc = pages.first {
            setViewControllers([firstVc], direction: .forward, animated: true, completion: nil)
        } else {
            print("problem")
        }
        // Do any additional setup after loading the view.
        print(viewControllers!)
        for gr in self.view.gestureRecognizers! {
            gr.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = gestureRecognizer as? UIPanGestureRecognizer {
            let touchPoint = touch.location(in: self.view)
            let vw = touch.view
            if touchPoint.x < (vw!.frame.width / 4) || touchPoint.x > (vw!.frame.width / 4 * 3) {
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        print(pendingViewControllers.first?.restorationIdentifier!)
        //send data to next view controller
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //reload data if not swiped
    }
}
