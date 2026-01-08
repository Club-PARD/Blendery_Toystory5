//
//  NavigationPopToRoot.swift
//  Blendery
//
//  Created by 박성준 on 1/9/26.
//

import UIKit

extension UIViewController {
    func findNavigationController() -> UINavigationController? {
        if let nav = self as? UINavigationController { return nav }
        if let nav = navigationController { return nav }

        for child in children {
            if let nav = child.findNavigationController() { return nav }
        }

        if let presented = presentedViewController {
            if let nav = presented.findNavigationController() { return nav }
        }

        return nil
    }
}

extension UIApplication {
    func popToRoot(animated: Bool = true) {
        guard
            let scene = connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow }),
            let root = window.rootViewController,
            let nav = root.findNavigationController()
        else { return }

        nav.popToRootViewController(animated: animated)
    }
}
