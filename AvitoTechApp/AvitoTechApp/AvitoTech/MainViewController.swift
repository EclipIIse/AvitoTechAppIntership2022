//
//  MainViewController.swift
//  AvitoTechApp
//
//  Created by Koryun Marabyan on 21.10.2022.
//
import UIKit
import Foundation
import Network

class MainViewController: UIViewController {

	@IBOutlet weak var companyDataTableView: UITableView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var internetIndicatorImageView: UIImageView!
	@IBOutlet weak var connectionLossLable: UILabel!
	
	var tableViewData: AvitoTech?{
		didSet {
			self.companyDataTableView.reloadData()
		}
	}
	
	let companyDataLoader = CompanyDataLoader()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		monitorNetwork()
		
		companyDataLoader.loadCompanyData { tableViewData in
			self.tableViewData = tableViewData
		}
	}
	
	//Проверка подключения устройства к сети на симуляторях работает некорректно (баг xCode, наверное), на устройствах всё работает как положено :)
	
	func monitorNetwork() {
		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { path in
			if path.status == .satisfied {
				DispatchQueue.main.async {
//					print("Connected")
					self.companyDataTableView.alpha = 1
					self.connectionLossLable.alpha = 0
					self.internetIndicatorImageView.alpha = 0
					self.activityIndicator.hidesWhenStopped = true
					self.activityIndicator.stopAnimating()
				}
			} else {
				if self.tableViewData != nil {
					return
				}
				DispatchQueue.main.async {
//					print("Not Connected")
					self.companyDataTableView.alpha = 0
					self.connectionLossLable.text = "Please check your internet connection and try again later"
					self.connectionLossLable.alpha = 1
					self.internetIndicatorImageView.alpha = 1
					self.activityIndicator.startAnimating()
				}
			}
		}
		let queue = DispatchQueue(label: "Network")
		monitor.start(queue: queue)
	}
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let count = tableViewData?.company?.employees.count else {
			return 7
		}
		return count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return (tableViewData?.company?.name)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = .systemOrange
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath) as! CompanyDataCell
		let employee = tableViewData?.company?.employees[indexPath.row]

		cell.nameLabel.text = employee?.name
		cell.phoneNumberLabel.text = employee?.phoneNumber
		
		let arr = employee?.skills.map{ (skill) -> String in
			return String(skill!)
		}.joined(separator: ", ")
		cell.skillsLabel.text = arr

		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		companyDataTableView.deselectRow(at: indexPath, animated: true)
	}
}
