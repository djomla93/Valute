//
//  CurrencyCell.swift
//  Valute
//
//  Created by Aleksandar Vacić on 8.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class CurrencyCell: UITableViewCell {

	@IBOutlet fileprivate weak var label: UILabel!
	@IBOutlet fileprivate weak var flagImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

	}


	func configure(with currencyCode: String) {
		label.text = currencyCode
		let cc = Locale.countryCode(for: currencyCode)
		let img = UIImage(named: cc) ?? #imageLiteral(resourceName: "empty")
		flagImageView.image = img
	}
}
