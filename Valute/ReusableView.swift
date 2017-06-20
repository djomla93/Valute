//
//  Cells.swift
//  Valute
//
//  Created by Aleksandar Vacić on 8.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

protocol ReusableView {
	static var reuseIdentifier: String { get }
}

extension UIView: ReusableView {
	static var reuseIdentifier: String {
		return String(describing: self)
	}
}

