//
//  ExchangeManager.swift
//  Valute
//
//  Created by Aleksandar Vacić on 10.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation

final class ExchangeManager {
	static let shared = ExchangeManager()
	private init() {
		rates[baseCurrency] = 1
	}

	var allowedCurrencies: [String] {
		return Locale.commonISOCurrencyCodes
	}

	fileprivate var rates: [String: Decimal] = [:]
}


fileprivate extension ExchangeManager {
	func validateCurrency(_ cc: String) throws {
		if allowedCurrencies.contains(cc) { return }

		throw ExchangeError.invalidCurrencyCode(cc: cc)
	}

	var baseCurrency: String { return "USD" }
	var basePath: String { return "https://download.finance.yahoo.com/d/quotes.csv?f=sb&s=" }

	func ratesURL(for sourceCC: String, targetCC: String) -> URL {
		//	https://download.finance.yahoo.com/d/quotes.csv?f=sb&s=USDGBP=X,USDEUR=X

		var symbols = [String]()
		if  sourceCC != baseCurrency {
			symbols.append( "\( baseCurrency )\( sourceCC )=X" )
		}
		if targetCC != baseCurrency {
			symbols.append( "\( baseCurrency )\( targetCC )=X" )
		}

		return URL(string: "\( basePath )\( symbols.joined(separator: ",") )")!
	}


}


extension ExchangeManager {
	typealias Callback = (Decimal?, ExchangeError?) -> Void

	func conversionRate(from sourceCC: String,
	                    to targetCC: String,
	                    completion: @escaping Callback) {

		do {
			try validateCurrency(sourceCC)
			try validateCurrency(targetCC)
		} catch let error {
			completion(nil, error as? ExchangeError)
			return
		}

		if let sourceRate = rates[sourceCC], let targetRate = rates[targetCC] {
			completion( targetRate / sourceRate, nil)
			return
		}

		let url = ratesURL(for: sourceCC, targetCC: targetCC)

		let task = URLSession.shared.dataTask(with: url) {
			data, response, error in

			if let error = error {
				let myError = ExchangeError.networkError(originalError: error)
				completion(nil, myError)
				return
			}

			guard let httpResponse = response as? HTTPURLResponse else {
				let myError = ExchangeError.invalidResponse
				completion(nil, myError)
				return
			}

			if httpResponse.statusCode > 299 {
				let myError = ExchangeError.invalidResponse
				completion(nil, myError)
				return
			}

			guard let data = data else {
				let myError = ExchangeError.invalidResponse
				completion(nil, myError)
				return
			}

			guard let result = String(data: data, encoding: .utf8) else {
				let myError = ExchangeError.invalidResponse
				completion(nil, myError)
				return
			}


			let lines = result.components(separatedBy: "\n")
			for line in lines {
				let lineParts = line.components(separatedBy: ",")
				guard lineParts.count == 2 else { continue }

				guard let currencyCode = lineParts.first?.replacingOccurrences(of: self.baseCurrency, with: "").replacingOccurrences(of: "=X", with: "").replacingOccurrences(of: "\"", with: "") else { continue }
				guard
					let str = lineParts.last,
					let rate = NumberFormatter.decimalFormatter.number(from: str.replacingOccurrences(of: "\n", with: ""))?.decimalValue
					else { continue }

					self.rates[currencyCode] = rate
			}

			if let sourceRate = self.rates[sourceCC], let targetRate = self.rates[targetCC] {
				completion( targetRate / sourceRate, nil)
				return
			} else {
				completion(nil,  ExchangeError.missingRate )
			}
		}

		task.resume()
	}
}
