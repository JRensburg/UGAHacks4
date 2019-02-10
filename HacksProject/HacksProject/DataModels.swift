//
//  DataModels.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/9/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import Foundation
import Alamofire
/**
 Struct containing Vendor info. Is codable so can be driectly encoded/decoded from JSON
 */
struct Root : Codable {
    let records : [Records]
}
struct Records : Codable {
    let id : String
    let fields : Vendor
}
struct CustomerRoot : Codable { 
    let records : [CustomerRecords]
}
struct CustomerRecords : Codable {
    let id : String
    let fields : Customer
}
struct Vendor : Codable {
    let VendorName : String
    let TotalSales : Double
}
struct Customer : Codable {
    let QRid : String?
    let Phone: String
    let Name : String
    let photo : [Picture]?
    let customerid : String?
}
struct Picture :Codable {
    let url : String
}
extension JSONDecoder {
    func decodeResponse<T: Decodable>(from response: DataResponse<Data>) -> Result<T> {
        guard response.error == nil else {
            print(response.error!)
            return .failure(response.error!)
        }
        
        guard let responseData = response.data else {
            print("didn't get any data from API")
            return .failure(response.error!)
        }
        do {
            let item = try decode(T.self, from: responseData)
            return .success(item)
        } catch {
            print("error trying to decode response")
            print(error)
            return .failure(error)
        }
    }
}
protocol ControllerDelegate {
    func navigate(view : UIView)
    func addSaleView(customer: Customer)
    func alertSuccess()
    func alertError()
}
extension String {
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
