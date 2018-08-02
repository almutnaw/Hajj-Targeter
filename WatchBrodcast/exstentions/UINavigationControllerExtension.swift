//
//  UINavigationControllerExtension.swift
//  WatchBrodcast
//
//  Created by Nawwaf Almutairi on 8/2/18.
//  Copyright © 2018 Nawwaf. All rights reserved.
//

import UIKit

extension UINavigationController
{
    open override var childViewControllerForStatusBarHidden: UIViewController?
    {
        return self.topViewController
    }
    
    open override var childViewControllerForStatusBarStyle: UIViewController?
    {
        return self.topViewController
    }
}
