// 
// Copyright (c) 2018年, 玉越敬典.
// All rights reserved.
//


import UIKit

final class Router {
    enum Locate {
        case main
        case camera
        case setting
    }
    let rootViewController = RootViewController()
    
    func route(to locate: Locate, from viewController: UIViewController) {
        switch locate {
        case .main:
            rootViewController.showMain()
        case .camera:
            rootViewController.showCameraScreen()
        case .setting:
            rootViewController.showSettingScreen()
        }
    }
}
