//
//  ExchangeError.swift
//  Valute
//
//  Created by Aleksandar Vacić on 22.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation


enum ExchangeError: Error {
	case networkError(originalError: Error)
	case invalidResponse
	case missingRate
	case invalidCurrencyCode(cc: String)

	var title: String? {
		switch self {
		case .networkError:
			return nil
		case .invalidResponse:
			return nil
		case .missingRate:
			return nil
		case .invalidCurrencyCode:
			return NSLocalizedString("Unknown currency", comment: "")
		}
	}

	var message: String? {
		switch self {
		case .networkError(let originalError):
			return originalError.localizedDescription
		case .invalidResponse:
			return NSLocalizedString("Invalid response", comment: "")
		case .missingRate:
			return NSLocalizedString("Missing rate for given currencies", comment: "")
		case .invalidCurrencyCode(let cc):
			return String(format: NSLocalizedString("Invalid currency code: %@", comment: "%@ is a marker for used currency code"),
			              cc)
		}
	}
}

