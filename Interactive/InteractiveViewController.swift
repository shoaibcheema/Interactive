//
//  Interactive.swift
//  Interactive
//
//  Created by Shoaib Sarwar Cheema on 14/11/2016.
//  Copyright © 2016 The Soft Studio. All rights reserved.
//

import UIKit


enum dismissDirection: Int {
    case top = 0
    case bottom = 1
    case both = 2
}

class InteractiveViewController: UIViewController {

    var allowedDismissDirection: dismissDirection = .both
    var directionLock = false
    
    var window: UIWindow?
    var topConstraint: NSLayoutConstraint?
    var intractiveGesture: UIPanGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if window != nil {
            dismissWindow(animated: flag, completion: completion)
        }
        else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
    
    private func dismissWindow(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if flag {
            dismissWindow(.bottom, completion: completion)
        }
        else {
            self.window?.rootViewController = nil
            self.window = nil
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            completion?()
        }
    }
    
    internal func dismissWindow(_ direction: dismissDirection, completion: (() -> Void)? = nil) {
        
        switch direction {
        case .top:
            self.topConstraint?.constant = -self.view.bounds.height
        default:
            self.topConstraint?.constant = self.view.bounds.height
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.window?.layoutIfNeeded()
        }, completion: { finished in
            self.window?.rootViewController = nil
            self.window = nil
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            completion?()
        })
    }
}

extension InteractiveViewController: UIGestureRecognizerDelegate {
    
    func showInteractive() {
        
        window = UIWindow()
        
        guard let window = window else {
            return
        }
        
        intractiveGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        
        self.view.addGestureRecognizer(intractiveGesture!)
        
        window.rootViewController = self
        window.backgroundColor = UIColor.clear
        window.makeKeyAndVisible()
        addViewControllerToWindowConstraints(self)
        
        topConstraint?.constant = UIScreen.main.bounds.height
        self.window?.layoutIfNeeded()
        topConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.window?.layoutIfNeeded()
        })
    }
    
    private func addViewControllerToWindowConstraints(_ vc: UIViewController) {
        
        guard let window = window else {
            return
        }
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = vc.view.topAnchor.constraint(equalTo: window.topAnchor)
        let heightAnchor = vc.view.heightAnchor.constraint(equalToConstant: window.bounds.height)
        let leftAnchor = vc.view.leadingAnchor.constraint(equalTo: window.leadingAnchor)
        let rightAnchor = vc.view.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        
        window.addConstraints([topConstraint!, heightAnchor, leftAnchor, rightAnchor])
    }
    
    private func didPan(_ y: CGFloat) {
        topConstraint?.constant = y
    }
    
    func resetWindow() {
        topConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.window?.layoutIfNeeded()
        })
    }
    
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        
        if sender == intractiveGesture {
            let yMovement = sender.translation(in: self.view).y
            
            if !directionLock{
                didPan(yMovement)
            }
            else if allowedDismissDirection == .top && yMovement < 0{
                didPan(yMovement)
            }
            else if allowedDismissDirection == .bottom && yMovement > 0 {
                didPan(yMovement)
            }
            
            if sender.state == UIGestureRecognizerState.ended {
                let velocity = sender.velocity(in: self.view)
                
                if velocity.y < -100 && allowedDismissDirection != .bottom {
                    dismissWindow(.top)
                }
                else if velocity.y > 100  && allowedDismissDirection != .top{
                    dismissWindow(.bottom)
                } else {
                    resetWindow()
                }
            }
        }
    }
}


