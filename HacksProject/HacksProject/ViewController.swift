//
//  ViewController.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/9/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import UIKit
import SwiftHash
import Alamofire
import SnapKit
import AudioToolbox

class LoginViewController: UIViewController,UITextFieldDelegate {
    let titleView = UILabel()
    let username = UITextField()
    let password = UITextField()
    let loginButton = UIButton()
    //let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setUpConstrains()
        username.delegate = self
        password.delegate = self
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   @objc func login(){
        let parameters : Parameters = [
            "api_key" : airtableAPI.apiKey,
            "maxRecords" : "1",
            "filterByFormula" : "AND({Email} = '\(username.text ?? "")',{Password} = '\(MD5(password.text ?? "").lowercased())')"
        ]

            Alamofire.request(airtableAPI.baseURL+"Vendors?", method: .get, parameters: parameters).responseData{ response in
            if let vendor: Records = (JSONDecoder().decodeResponse(from: response) as Result<Root>).value?.records.first {
                let vendorController = VendorViewController(collectionViewLayout: UICollectionViewFlowLayout())

                vendorController.vendor = vendor
                let navController = UINavigationController(rootViewController: vendorController)
                self.present(navController, animated: true, completion: nil)
            }
            else {
                self.password.text = ""
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        username.resignFirstResponder()
        password.resignFirstResponder()
    }

    func configureViews(){
        let backdrop = UIImageView(image:#imageLiteral(resourceName: "gradient3.jpg") )
        let tfColor = UIColor(displayP3Red: 181/255, green: 181/255, blue: 181/255, alpha: 0.7)
        //add Subviews
        view.addSubviews(backdrop,username,password,loginButton,titleView)
        backdrop.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        //configure views
        titleView.text = "Payment Senpai"
        titleView.font = UIFont(name: "Copperplate", size: 36.0)
        titleView.textAlignment = .center
        titleView.textColor = .white
        username.backgroundColor = tfColor
        username.placeholder = "Username"
        username.layer.cornerRadius = 10
        username.keyboardType = .emailAddress
        password.placeholder = "Password"
        password.layer.cornerRadius = 10
        password.backgroundColor = tfColor
        password.isSecureTextEntry = true
        loginButton.backgroundColor = .clear
        loginButton.layer.cornerRadius = 15
        loginButton.setTitle("Login", for: .normal)
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1.5
        
        view.sendSubviewToBack(backdrop)
    }
    func setUpConstrains(){
        titleView.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview()
            $0.top.equalToSuperview().offset(70)
            $0.centerX.equalToSuperview()
        }
        username.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview().dividedBy(1.5)
            $0.top.equalTo(titleView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        password.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview().dividedBy(1.5)
            $0.top.equalTo(username.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        loginButton.snp.makeConstraints{
            $0.height.equalTo(60)
            $0.width.equalToSuperview().dividedBy(2)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(password.snp.bottom).offset(40)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }

}

