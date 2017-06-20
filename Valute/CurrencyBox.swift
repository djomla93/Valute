//
//  CurrencyBox.swift
//  Valute
//
//  Created by Aleksandar Vacić on 3.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit


protocol CurrencyBoxDelegate: class {
	func currencyBoxRequestsCurrencyChange(_ box: CurrencyBox)
}




final class CurrencyBox: UIView {

	weak var delegate: CurrencyBoxDelegate?
//	var converController: ConvertController!

	@IBOutlet fileprivate weak var currencyCodeLabel: UILabel!
	@IBOutlet fileprivate weak var flagImageView: UIImageView!
	@IBOutlet fileprivate weak var textField: UITextField!
}


fileprivate extension CurrencyBox {

	@IBAction func didTapButton(_ sender: UIButton) {
		delegate?.currencyBoxRequestsCurrencyChange(self)
	}
}

extension CurrencyBox {

	var currencyCode: String {
		get {
			return currencyCodeLabel.text!
		}
		set {
			currencyCodeLabel.text = newValue

			let cc = Locale.countryCode(for: newValue)
			let img = UIImage(named: cc) ?? #imageLiteral(resourceName: "empty")
			flagImageView.image = img
		}
	}

	var amount: Decimal? {
		get {
			if let str = textField.text {
				return NumberFormatter.moneyFormatter.number(from: str)?.decimalValue
			}
			return nil
		}
		set {
			textField.text = NumberFormatter.moneyFormatter.string(for: newValue)
		}
	}

	var amountString: String? {
		get {
			return textField.text
		}
		set {
			textField.text = newValue
		}
	}
}

extension CurrencyBox: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return false
	}
}
