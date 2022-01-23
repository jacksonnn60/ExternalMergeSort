//
//  UIViewController.swift
//  ExternalSortApp
//
//  Created by Jackson  on 12.12.2021.
//

import UIKit

// MARK: - Storyboard default setup
extension UIViewController {
    static func loadFromStoryboard() throws -> Self {
        try loadFromStoryboard(identifier: String(describing: Self.self))
    }

    static func loadFromStoryboard(identifier: String) throws -> Self {
        guard let viewController = UIStoryboard(name: String(describing: Self.self), bundle: nil)
                .instantiateViewController(withIdentifier: identifier) as? Self else {
                    throw "Can't load view controller by " + identifier
                }

        return viewController
    }
}

extension String: Error {}
