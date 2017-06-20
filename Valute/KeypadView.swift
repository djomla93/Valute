//
//  KeypadView.swift
//  Valute
//
//  Created by Aleksandar Vacić on 28.4.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

protocol KeypadViewDelegate: class {
	func keypadView(_ keypad: KeypadView, didChangeAmount value: Decimal?)
	func keypadView(_ keypad: KeypadView, didChangeValue value: String?)
}


final class KeypadView: UIView {

	weak var delegate: KeypadViewDelegate?

	//	Outlets

	@IBOutlet weak var decimalButton: UIButton!
	@IBOutlet weak var deleteButton: UIButton!
	//	= button
	@IBOutlet weak var equalsButton: UIButton!
	//	+, -, *, / operatori
	@IBOutlet var operatorButtons: [UIButton]!
	//	numbers
	@IBOutlet var digitButtons: [UIButton]!

	var allButtons: [UIButton] {
		return digitButtons + operatorButtons + [decimalButton, deleteButton, equalsButton]
	}

	//	Internal data types

	fileprivate enum ArithmeticOperation {
		case add
		case subtract
		case multiply
		case divide

		case equals
	}

	//	Internal model

	fileprivate var originalBackgroundColor: UIColor?

	fileprivate var firstOperand: Decimal?
	fileprivate var operation: ArithmeticOperation?

	//	External model

	fileprivate(set) var stringAmount: String? {
		didSet {
			delegate?.keypadView(self, didChangeValue: stringAmount)

			delegate?.keypadView(self, didChangeAmount: amount)
		}
	}

	var amount: Decimal? {
		guard let str = stringAmount else { return nil }
		return NumberFormatter.decimalFormatter.number(from: str)?.decimalValue
	}
}

//	MARK: - View lifecycle
extension KeypadView {
	override func awakeFromNib() {
		super.awakeFromNib()

		//	do the post-load setup here
		//	stuff not done in Interface Builder
		setupButtonsTouch()
		setupButtonsUntouch()
		setupButtonsTap()
		configureDecimalButton()
		prepareDisplay()
	}
}



//	MARK: - UI setup
fileprivate extension KeypadView {
	///	Sets up target-action pattern for the TouchDown event on all the buttons
	func setupButtonsTouch() {
		for btn in allButtons {
			btn.addTarget(self, action: #selector(KeypadView.didTouchButton), for: .touchDown)
		}
	}

	///	Sets up target-action pattern for the TouchCancel, TouchUpOutside event on all the buttons.
	///	It's also called at the end of TouchUpInside handler
	func setupButtonsUntouch() {
		for btn in allButtons {
			btn.addTarget(self, action: #selector(KeypadView.didUntouchButton), for: .touchCancel)
			btn.addTarget(self, action: #selector(KeypadView.didUntouchButton), for: .touchUpOutside)
		}
	}

	///	Displays proper decimalSeparator, based on current Locale
	func configureDecimalButton() {
		decimalButton.setTitle(Locale.current.decimalSeparator, for: .normal)
	}

	///	Sets up target-action pattern for the TouchUpInside event
	func setupButtonsTap() {
		for btn in digitButtons {
			btn.addTarget(self, action: #selector(KeypadView.didTapDigit), for: .touchUpInside)
		}

		let operators = operatorButtons + [equalsButton]
		for btn in operators {
			btn.addTarget(self, action: #selector(KeypadView.didTapOperator), for: .touchUpInside)
		}

	}

	func prepareDisplay() {
		equalsButton.alpha = 0
	}
}


//	MARK: - Actions
extension KeypadView {
	func didTouchButton(_ sender: UIButton) {
		originalBackgroundColor = sender.backgroundColor

		//	since buttons already have transparent background and 
		//	some of them have transparent background, 
		//	we need to be careful when altering the background

		//	first, if there is no bg color, then use very transparent black
		guard let _ = sender.backgroundColor else {
			sender.backgroundColor = UIColor.black.withAlphaComponent(0.2)
			return
		}

		//	Since buttons backgrounds are already partially transparent,
		//	we need to increase the alpha components, in order to visualize tapping
		//	(larger alpha == less transparent, more opacity)

		//	here's a way to extract RGBA components from the UIColor
		//	setup default (black)
		var r : CGFloat = 0
		var g : CGFloat = 0
		var b : CGFloat = 0
		//	and use 20% opacity
		var a : CGFloat = 0.2
		//	this method will populate the components above using given UIColor value
		guard let _ = sender.backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a) else {
			//	if extraction fails, then fall back to black, as above
			sender.backgroundColor = UIColor.black.withAlphaComponent(0.2)
			return
		}
		//	if it worked, then setup using double alpha
		sender.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a*2)
	}

	func didUntouchButton(_ sender: UIButton) {
		sender.backgroundColor = originalBackgroundColor
		originalBackgroundColor = nil
	}

	func didTapDigit(_ sender: UIButton) {
		defer {
			didUntouchButton(sender)
		}

		guard let numString = sender.title(for: .normal) else { return }

		var value = stringAmount ?? ""
		value += numString
		stringAmount = value
	}

	func didTapOperator(_ sender: UIButton) {
		defer {
			didUntouchButton(sender)
		}

		var isEquals = false

		//	dohvati šta piše na buttonu
		guard let caption = sender.title(for: .normal) else {
			fatalError("Received operator button tap from button with no caption on it")
		}

		//	pa podesi vrednost prema tome
		switch caption {
		case "+":
			operation = .add
		case "-":
			operation = .subtract
		case "×":
			operation = .multiply
		case "÷":
			operation = .divide
		case "=":
			isEquals = true
		default:
			operation = nil
		}

		if (isEquals) {
			guard let str = stringAmount, let num = NumberFormatter.decimalFormatter.number(from: str)?.decimalValue else { return }

			//	note: this should never fail
			guard var result = firstOperand else {
				fatalError("Missing first operand!")
			}

			switch operation! {
			case .add:
				result += num
			case .subtract:
				result -= num
			case .multiply:
				result = result * num
			case .divide:
				result = result / num
			default:
				return
			}

			stringAmount = NumberFormatter.decimalFormatter.string(for: result)
			operation = nil

			UIView.animate(withDuration: 0.3, animations: {
				[unowned self] in
				for btn in self.operatorButtons {
					btn.alpha = 1
				}
				self.equalsButton.alpha = 0
			})

		} else if let _ = operation {
			//	pritisnut je neki od aritm. operatora
			//	to znači da je unet prvi operand
			guard let str = stringAmount, let num = NumberFormatter.decimalFormatter.number(from: str)?.decimalValue else { return }
			firstOperand = num

			stringAmount = nil

			UIView.animate(withDuration: 0.3, animations: {
				[unowned self] in
				for btn in self.operatorButtons {
					btn.alpha = 0
				}
				self.equalsButton.alpha = 1
			})
		}
	}

	@IBAction func decimalButtonTapped(_ sender: UIButton) {
		defer {
			didUntouchButton(sender)
		}

		guard let dot = sender.title(for: .normal) else { return }

		var value = stringAmount ?? ""
		if !value.contains(dot) {
			value += dot
			stringAmount = value
		}
	}

	@IBAction func deleteButtonTapped(_ sender: UIButton) {
		defer {
			didUntouchButton(sender)
		}

		guard let str = stringAmount, str.characters.count > 0 else { return }
		let s = str.substring(to: str.index(before: str.endIndex))

		stringAmount = s
	}
}
