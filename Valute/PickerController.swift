//
//  PickerController.swift
//  Valute
//
//  Created by Aleksandar Vacić on 5.5.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

protocol PickerControllerDelegate: class {
	func pickerController(_ controller: PickerController, didSelect currencyCode: String)
}


final class PickerController: UIViewController {

	@IBOutlet fileprivate weak var tableView: UITableView!

	weak var delegate: PickerControllerDelegate?

	var currencies: [String] = [] {
		didSet {
			filteredCurrencies = currencies
		}
	}
	fileprivate var filteredCurrencies: [String] = [] {
		didSet {
			if !self.isViewLoaded { return }
			tableView.reloadData()
		}
	}

	fileprivate var searchString: String? {
		didSet {
			guard let ss = searchString, ss.characters.count > 0 else {
				filteredCurrencies = currencies
				return
			}

			filteredCurrencies = currencies.filter({ cc -> Bool in
				return cc.contains( ss.uppercased() )
			})
		}
	}

	fileprivate lazy var searchController: UISearchController = {
		let sc = UISearchController(searchResultsController: nil)
		sc.hidesNavigationBarDuringPresentation = false
		sc.dimsBackgroundDuringPresentation = false

		sc.searchResultsUpdater = self

		return sc
	}()
}

extension PickerController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchString = searchController.searchBar.text
	}
}


extension PickerController {
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background"))

		navigationItem.titleView = searchController.searchBar
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		presentedViewController?.dismiss(animated: animated)
	}
}

extension PickerController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredCurrencies.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cc = filteredCurrencies[indexPath.row]

		let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.reuseIdentifier, for: indexPath) as! CurrencyCell
		cell.configure(with: cc)
		return cell
	}
}

extension PickerController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cc = filteredCurrencies[indexPath.row]

		if presentedViewController != nil {
			dismiss(animated: true) {
				[unowned self] in
				self.delegate?.pickerController(self, didSelect: cc)
			}
			return
		}

		delegate?.pickerController(self, didSelect: cc)
	}
}

