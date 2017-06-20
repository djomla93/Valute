//
//  StoryboardLoadable.swift
//  Valute
//
//  Created by Aleksandar Vacić on 8.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

protocol StoryboardLoadable {
	static var storyboardIdentifier: String { get }
}

extension UIViewController: StoryboardLoadable {
	static var storyboardIdentifier: String {
		return String(describing: self)
	}
}

