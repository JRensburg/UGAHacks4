//
//  LinkViewController.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/10/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import UIKit
import Alamofire

class LinkViewController: UIViewController,UITextFieldDelegate {

    let name = UITextField()
    let phone = UITextField()
    let loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setUpConstrains()
        name.delegate = self
        phone.delegate = self
        loginButton.addTarget(self, action: #selector(validate), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func validate(){
        let parameters : Parameters = [
            "api_key" : airtableAPI.apiKey,
            "maxRecords" : "1",
            "filterByFormula" : "AND({Name} = '\(name.text ?? "")',{Phone} = '\(phone.text ?? "")',NOT({customerid}=''))"
        ]
        Alamofire.request(airtableAPI.baseURL+"Customers?", method: .get, parameters: parameters).responseData{ response in
            if let customer: CustomerRecords = (JSONDecoder().decodeResponse(from: response) as Result<CustomerRoot>).value?.records.first {
                let scanner = ScannerViewController()
                self.navigationController?.pushViewController(scanner, animated: true)
                scanner.callback = {
                    self.updateEntry(qrid: $0, record: customer)
                }
                //Present QR reader
            }
        }
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        name.resignFirstResponder()
        phone.resignFirstResponder()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        name.resignFirstResponder()
        phone.resignFirstResponder()
    }
    func configureViews(){
        let backdrop = UIImageView(image:#imageLiteral(resourceName: "gradient3.jpg") )
        let tfColor = UIColor(displayP3Red: 181/255, green: 181/255, blue: 181/255, alpha: 0.7)
        //add Subviews
        view.addSubviews(backdrop,name,phone,loginButton)
        backdrop.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        //configure views
        name.backgroundColor = tfColor
        name.layer.cornerRadius = 10
        name.placeholder = "First and last name"
        phone.layer.cornerRadius = 10
        phone.backgroundColor = tfColor
        phone.placeholder = "Phone Number"
        phone.keyboardType = .phonePad
        loginButton.backgroundColor = .clear
        loginButton.layer.cornerRadius = 15
        loginButton.setTitle("Scan Code", for: .normal)
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1.5
        
        view.sendSubviewToBack(backdrop)
    }
    func setUpConstrains(){
        name.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview().dividedBy(1.5)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            $0.centerX.equalToSuperview()
        }
        phone.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview().dividedBy(1.5)
            $0.top.equalTo(name.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        loginButton.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview().dividedBy(2)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(phone.snp.bottom).offset(40)
        }
    }
    
    func updateEntry(qrid:String, record: CustomerRecords){
        let params : Parameters = ["fields":["QRid":qrid]]
        Alamofire.request(airtableAPI.baseURL+"Customers/"+record.id+"?api_key="+airtableAPI.apiKey, method: .patch, parameters: params, encoding: JSONEncoding.default).validate().responseJSON{
            switch $0.result {
            case .failure:
                print("failure whilee trying to update entry")
            case .success:
                self.alertSuccess()
                }
            }
        }
    func alertSuccess(){
        let alert = UIAlertController(title: "Success", message: "QR code registered", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //Add imageview to alert
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imgViewTitle.image = #imageLiteral(resourceName: "clipart624281.png")
        alert.view.addSubview(imgViewTitle)
    
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}
