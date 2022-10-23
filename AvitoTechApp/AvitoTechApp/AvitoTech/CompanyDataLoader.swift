//
//  DataLoader.swift
//  AvitoTechApp
//
//  Created by Koryun Marabyan on 21.10.2022.
//

import Foundation

class CompanyDataLoader {
	
	private let cache = NSCache<NSString, DataStructHolder>()
	
	func loadCompanyData(completion: @escaping (AvitoTech) -> Void) {
		
		if let data = (cache.object(forKey: "Avito"))?.holder {
//			print("Using cash")
			completion(data)
			return
		}
		
		let jsonURL = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c/response-headers?Cache-Control=max-age=30"
		guard let url = URL(string: jsonURL) else { return }
		
//		print("Fetching cash")
		
		URLSession.shared.dataTask(with: url) { (data, response, err) in
			DispatchQueue.main.async {
				if let err = err {
					print("Failed to get data from url:", err)
				}
				
				guard let data = data else { return }
				
				do {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					var avitoTech = try decoder.decode(AvitoTech.self, from: data)
					if let sorted = avitoTech.company?.employees.sorted(by: { $0.name < $1.name }) {
						avitoTech.company?.updateEmployees(sorted)
					}
					self.cache.setObject(DataStructHolder(holder: avitoTech), forKey: "Avito")
					completion(avitoTech)
					
					print(self.cache.hashValue)
					} catch let jsonErr {
					print("Failed to decode:", jsonErr)
				}
			}
		}.resume()
		let seconds = 60.0 * 60.0
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
			self.cache.removeObject(forKey: "Avito")
		}
	}
}
