//
//  JSONStruct.swift
//  AvitoTechApp
//
//  Created by Koryun Marabyan on 21.10.2022.
//

import Foundation

struct AvitoTech: Decodable {
	public var company: CompanyDescription?
}

struct CompanyDescription: Decodable {
	public let name: String?
	public var employees: [EmployeesDescription]
}

extension CompanyDescription {
	public mutating func updateEmployees(_ newData: [EmployeesDescription]) {
		employees = newData
	}
}

struct EmployeesDescription: Decodable {
	public let name: String
	public let phoneNumber: String
	public let skills: [String?]
}
