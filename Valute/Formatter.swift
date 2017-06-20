//
//  Formatter.swift
//  Valute
//
//  Created by Aleksandar Vacić on 3.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation


extension NumberFormatter {

	static let moneyFormatter: NumberFormatter = {
		var nf = NumberFormatter()
		nf.generatesDecimalNumbers = true
		nf.minimumFractionDigits = 2
		nf.maximumFractionDigits = 2
		return nf
	}()

	static let decimalFormatter: NumberFormatter = {
		var nf = NumberFormatter()
		nf.generatesDecimalNumbers = true
		nf.numberStyle = .decimal
		return nf
	}()
}
