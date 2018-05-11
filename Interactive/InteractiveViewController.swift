//
//  Interactive.swift
//  Interactive
//
//  Created by Shoaib Sarwar Cheema on 14/11/2016.
//  Copyright © 2016 The Soft Studio. All rights reserved.
//

import UIKit

enum dismissDirection: Int {
    case bottom
    case top
    case both
    case none
}
enum InteractiveMaskType : UInt {
    case black
    case clear
    case darkBlur
}

class InteractiveViewController: UIViewController {

    var allowedDismissDirection: dismissDirection = .both
    var directionLock = false
    var maskType: InteractiveMaskType = .black
    
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
            self.window?.backgroundColor = UIColor.clear
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
        window.layoutIfNeeded()
        topConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            if self.maskType == .black {
                window.backgroundColor = UIColor.black
            } else if self.maskType == .darkBlur {
                window.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.7)
            }
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
        if self.maskType == .black && window != nil{
            let alpha = abs(self.view.bounds.height/2 - self.view.center.y)/(self.view.bounds.height/2)
//            let alpha: Float = Float(self.window!.bounds.height/y)
//            self.window?.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: Float(1 - alpha))
            self.window?.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1 - alpha)
        }
    }
    
    func resetWindow() {
        topConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            if self.maskType == .black {
                self.window?.backgroundColor = UIColor.black
            } else if self.maskType == .darkBlur {
                self.window?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            }
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
                
                if velocity.y < -100 && (allowedDismissDirection == .top || allowedDismissDirection == .both)  {
                    dismissWindow(.top)
                }
                else if velocity.y > 100  && (allowedDismissDirection == .bottom || allowedDismissDirection == .both){
                    dismissWindow(.bottom)
                } else {
                    resetWindow()
                }
            }
        }
    }
}
