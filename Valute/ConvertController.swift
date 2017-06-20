//
//  ConvertController.swift
//  Valute
//
//  Created by Aleksandar Vacić on 26.4.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class ConvertController: UIViewController {

	@IBOutlet weak var sourceCurrencyBox: CurrencyBox!
	@IBOutlet weak var targetCurrencyBox: CurrencyBox!
	@IBOutlet weak var keypadView: KeypadView!

	//	Internal data model

	fileprivate enum Key: String {
		case sourceCC = "sourceCurrencyCode"
		case targetCC = "targetCurrencyCode"
	}

	fileprivate var sourceCurrencyCode: String = "" {
		didSet {
			UserDefaults.standard.set(sourceCurrencyCode, forKey: Key.sourceCC.rawValue)
			sourceCurrencyBox.currencyCode = sourceCurrencyCode
		}
	}
	fileprivate var targetCurrencyCode: String = "" {
		didSet {
			UserDefaults.standard.set(targetCurrencyCode, forKey: Key.targetCC.rawValue)
			targetCurrencyBox.currencyCode = targetCurrencyCode
		}
	}

	fileprivate var activeCurrencyBox: CurrencyBox?

	fileprivate var amount: Decimal? {
		didSet {
			//	perform conversion
			updateConversionPanel()
		}
	}
}

//	View lifecycle
extension ConvertController {
	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Currency Converter"

		configureCurrencyBoxes()
		configureKeypad()
		populateDataModel()
	}
}


extension ConvertController: CurrencyBoxDelegate {

	fileprivate func configureCurrencyBoxes() {
		sourceCurrencyBox.delegate = self
		targetCurrencyBox.delegate = self

		sourceCurrencyBox.amount = nil
		targetCurrencyBox.amount = nil
	}

	func currencyBoxRequestsCurrencyChange(_ box: CurrencyBox) {

		let storyboard = UIStoryboard(name: "Convert", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: PickerController.storyboardIdentifier) as! PickerController
		vc.delegate = self
		vc.currencies = ExchangeManager.shared.allowedCurrencies
		show(vc, sender: self)

		if box == sourceCurrencyBox {
			activeCurrencyBox = sourceCurrencyBox
		} else {
			activeCurrencyBox = targetCurrencyBox
		}
	}
}

extension ConvertController: PickerControllerDelegate {
	func pickerController(_ controller: PickerController, didSelect currencyCode: String) {
		self.navigationController?.popViewController(animated: true)

		guard let activeCurrencyBox = activeCurrencyBox else {
			return
		}
		//	update data model
		if activeCurrencyBox == sourceCurrencyBox {
			sourceCurrencyCode = currencyCode
		} else {
			targetCurrencyCode = currencyCode
		}

		self.activeCurrencyBox = nil
	}
}


extension ConvertController: KeypadViewDelegate {
	fileprivate func configureKeypad() {
		keypadView.delegate = self
	}

	func keypadView(_ keypad: KeypadView, didChangeAmount value: Decimal?) {
		amount = value
	}

	func keypadView(_ keypad: KeypadView, didChangeValue value: String?) {
		sourceCurrencyBox.amountString = value
	}
}



fileprivate extension ConvertController {
	func populateDataModel() {
		if let cc = UserDefaults.standard.value(forKey: Key.sourceCC.rawValue) as? String {
			sourceCurrencyCode = cc
		} else {
			sourceCurrencyCode = sourceCurrencyBox.currencyCode
		}

		if let cc = UserDefaults.standard.value(forKey: Key.targetCC.rawValue) as? String {
			targetCurrencyCode = cc
		} else {
			targetCurrencyCode = targetCurrencyBox.currencyCode
		}

		amount = sourceCurrencyBox.amount
	}


	func updateConversionPanel() {
		guard let amount = amount else { return }

		ExchangeManager.shared.conversionRate(from: sourceCurrencyCode, to: targetCurrencyCode) {
			[weak self] rate, error in
			guard let `self` = self else { return }

			if let error = error {
				DispatchQueue.main.async {
					let ac = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
					let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
					                       style: .default)
					ac.addAction(ok)
					self.present(ac, animated: true, completion: nil)
				}
				return
			}

			guard let rate = rate else { return }

			let result = amount * rate

			DispatchQueue.main.async {
				self.targetCurrencyBox.amount = result
			}
		}
	}
}
