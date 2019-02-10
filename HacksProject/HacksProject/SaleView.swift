//
//  SaleView.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/9/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class SaleView: UIView,UITextFieldDelegate {
    var data : Customer
    var vendor : Records
    let label = UILabel()
    let input = UITextField()
    var accept = UIButton()
    var cancel = UIButton()
    var dateFormatter = DateFormatter()
    var controllerDelegate : ControllerDelegate?
    init(customer: Customer, vendor: Records) {
        let screen = UIScreen.main.bounds
        data = customer
        self.vendor = vendor
        super.init(frame: CGRect(x: 0, y: 0, width: screen.width / 1.25, height: screen.height / 1.5))
        addViews()
        configureTextField()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        addGestureRecognizer(tap)
        input.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        input.textAlignment = .center
        dateFormatter.dateFormat = "MM/dd/YYYY"
        input.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addViews(){
        let backdrop = UIImageView(image: #imageLiteral(resourceName: "gradient1.jpg"))
        addSubviews(input,backdrop)
        backdrop.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        sendSubviewToBack(backdrop)
        addSubviews(label,accept,cancel)
        label.text = "Enter value to charge"
        label.font = UIFont(name: "Copperplate", size: 18.0)
        label.textColor = .white
        label.textAlignment = .center
        accept.setTitleColor(.darkGray, for: .normal)
        cancel.setTitleColor(.darkGray, for: .normal)
        cancel.setTitle("Cancel", for: .normal)
        accept.setTitle("Accept", for: .normal)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        accept.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        cancel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().inset(15)
            $0.width.equalToSuperview().dividedBy(2.2)
        }
        accept.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().inset(15)
            $0.width.equalToSuperview().dividedBy(2.2)
        }
    }
    func configureTextField(){
        input.keyboardType = .numberPad
        input.backgroundColor = .clear
        input.textColor = .white
        input.layer.borderColor = UIColor.white.cgColor
        input.layer.borderWidth = 1
        input.layer.cornerRadius = 15
        label.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(30)
            $0.width.equalToSuperview()
            $0.height.equalTo(40)
        }
        input.snp.makeConstraints{
            $0.height.equalToSuperview().dividedBy(6)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(30)
            $0.width.equalToSuperview().multipliedBy(0.7)
        }
    }

    func verifyCustomer(customerID:String){
        let parameters = ["requestID":"verify\(customerID)","pageNumber":"1","pageSize":"1","customerID":"\(customerID)"
        ]
        Alamofire.request(fiservAPI.baseURL, method: .get, parameters: parameters, headers: fiservAPI.headers).responseJSON{response in
            do {
                let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
    
                if let accountID =  (((json["customerList"] as! [[String:AnyObject]]).first)!["fundingAccount"]! as! [[String:AnyObject]]).first?["accountID"] {
                self.processPayment(accountID: accountID as! String)
                }
            }
            catch {
                self.removeFromSuperview()
                self.controllerDelegate!.alertError()
            }
        }
    }
    
    func processPayment(accountID: String) {
        var amount = input.text
        amount?.removeFirst()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let parameters = [
            "accountID":accountID,
            "amount":amount ?? "",
            "customerID":data.customerid!,
            "mode":"initiate",
            "description":"This is a description",
            "requestID":"ThisIsRequestID",
            "sendOnDate":dateFormatter.string(from: tomorrow),
            "speed":"Next Day"
        ]
        Alamofire.request(fiservAPI.paymentURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: fiservAPI.headers).validate().responseJSON{
            //To show that fiserv api is used
            print($0)
            switch $0.result {
            case .failure:
                print("~~~ Failure while trying to process payment ~~~")
                debugPrint($0)
                self.removeFromSuperview()
                self.controllerDelegate!.alertError()
            case .success:
                self.updateSales(amount: Double(amount ?? "0") ?? 0)
                self.removeFromSuperview()
                self.controllerDelegate!.alertSuccess()
            }
        }
    }
    func updateSales(amount: Double){
        let params : Parameters = ["fields":["TotalSales":vendor.fields.TotalSales+amount]]
        Alamofire.request(airtableAPI.baseURL+"Vendors/"+vendor.id+"?api_key="+airtableAPI.apiKey, method: .patch, parameters: params, encoding: JSONEncoding.default)
    }
    @objc func cancelTapped() -> Void {
        self.removeFromSuperview()
    }
    @objc func acceptTapped() -> Void {
        verifyCustomer(customerID: data.customerid ?? "")
    }
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        input.resignFirstResponder()
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
}
