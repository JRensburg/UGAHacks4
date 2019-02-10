//
//  Constants.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/9/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import Foundation
import UIKit

public struct airtableAPI {
    static let baseURL = "https://api.airtable.com/v0/appqYJalnUjUgXQfy/"
    static let apiKey = "keyGahK21OkwKGoI8"
}
public struct fiservAPI {
    static let headers = ["apiKey":"prod-b43dbcb90ef2c1c27419794db88841ece591c40cbcde9379d0c3bdea38af5b16f0a671e4a4aa2f2060e42e4de5bc3230e893e201fe5b2d310289a0818906c940","businessID":"BUSN-acec287bef5f4c40fd62ebcc43b269d8b7b33ba2e358e16a874724bc90f8311f","Accept":"application/json","Content-Type":"application/json"]
    static let baseURL = "https://certwebservices.ft.cashedge.com/sdk/Payments/Customers?"
    static let paymentURL = "https://certwebservices.ft.cashedge.com/sdk/Payments/OneTimePayment"
}




extension UIView {
    func addSubviews(_ views : UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
