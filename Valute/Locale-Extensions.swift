//
//  Locale-Extensions.swift
//  Valute
//
//  Created by Aleksandar Vacić on 8.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation



extension Locale {

	static func countryCode(for currencyCode: String) -> String {

		switch currencyCode.uppercased() {
		case "EUR":
			return "eu"
		case "USD":
			return "us"
		case "GBP":
			return "gb"
		case "AUD":
			return "au"
		default:
			break
		}

		for regionCode in Locale.isoRegionCodes {
			let comps = [NSLocale.Key.countryCode.rawValue: regionCode]
			let localeIdentifier = identifier(fromComponents: comps)
			let locale = Locale(identifier: localeIdentifier)

			guard let cc = locale.currencyCode else { continue }
			if cc == currencyCode {
				return regionCode.lowercased()
			}
		}

		return "empty"
	}
}
