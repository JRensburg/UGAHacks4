//
//  VendorViewController.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/9/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import RxSwift
import RxCocoa

enum Modules {
    case scanner
    case link
    /*
     //Icon made by simpleIcon from www.flaticon.com 
     */
}

class VendorViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ControllerDelegate{
    
    let disposeBag = DisposeBag()
    //var vendorName: String?
    var vendor : Records?
    let cellFactory :[(String,UIImage,Modules)] = [("Scan Code",#imageLiteral(resourceName: "qrIcon.png"),.scanner),("Link Code",#imageLiteral(resourceName: "link-symbol.png"),.link)]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = vendor?.fields.VendorName ?? ""
        //collectionView.backgroundColor = .cyan
        collectionView.backgroundView = UIImageView(image:#imageLiteral(resourceName: "gradient3.jpg"))
        collectionView.register(VendorCell.self, forCellWithReuseIdentifier: "myCell")
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        // Do any additional setup after loading the view.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! VendorCell
        cell.title.text = cellFactory[indexPath.row].0
        cell.icon.image = cellFactory[indexPath.row].1
        cell.module = cellFactory[indexPath.row].2
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 250)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showViewController(module: (collectionView.cellForItem(at: indexPath) as! VendorCell).module)
    }
    
    func showViewController(module: Modules?){
        switch module {
        case .scanner? :
            let scanner = ScannerViewController()
            self.navigationController?.pushViewController(scanner, animated: true)
            scanner.callback = {
                self.validateCustomer(qrid: $0)
            }
        case .link? :
            self.navigationController?.pushViewController(LinkViewController(), animated: true)
        default :
            print("No value")
        }
    }
    
    func validateCustomer(qrid : String){
        let parameters : Parameters = [
            "api_key" : airtableAPI.apiKey,
            "maxRecords" : "1",
            "filterByFormula" : "({QRid}='\(qrid)')"
        ]
        Alamofire.request(airtableAPI.baseURL+"Customers?", method: .get, parameters: parameters).responseData{ response in
            if let customer : Customer = (JSONDecoder().decodeResponse(from: response) as Result<CustomerRoot>).value?.records.first?.fields{
                let customerView = CustomerView(customer: customer)
                customerView.controllerDelegate = self
                self.navigate(view: customerView)
                //customerVC.data = customer
                
            }
        }
    }
    
    @objc func flipSubViews(){
        for subs in self.view.subviews {
            if subs is CustomerView{
                subs.isUserInteractionEnabled = true
            }
            else {
                subs.isUserInteractionEnabled = !subs.isUserInteractionEnabled
            }
        }
    }
    
    func navigate(view: UIView) {
        self.view.addSubview(view)
        self.flipSubViews()
        view.center = (self.view.center)
        view.rx.deallocated.subscribe{self.flipSubViews()}.disposed(by: self.disposeBag)
    }

    func addSaleView(customer: Customer){
        let view = SaleView(customer: customer, vendor: vendor!)
        view.controllerDelegate = self
        navigate(view: view)
    }
    
    func alertSuccess(){
        let alert = UIAlertController(title: "Success", message: "Payment Successful", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //Add imageview to alert
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imgViewTitle.image = #imageLiteral(resourceName: "clipart624281.png")
        alert.view.addSubview(imgViewTitle)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    func alertError(){
        let alert = UIAlertController(title: "Error", message: "There was a problem proccessing error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //Add imageview to alert
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imgViewTitle.image = #imageLiteral(resourceName: "iconfinder_Error_381599 (1).png")
        alert.view.addSubview(imgViewTitle)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

class VendorCell : UICollectionViewCell {
    var title : UILabel!
    var icon : UIImageView!
    var module : Modules?

    override init(frame: CGRect) {
        super.init(frame: frame)
        title = UILabel()
        icon = UIImageView()
        self.contentView.addSubview(title)
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints{
            $0.width.height.equalToSuperview().dividedBy(2)
            $0.center.equalToSuperview()
        }
        title.snp.makeConstraints{
            $0.width.equalToSuperview()
            $0.top.equalTo(icon.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        title.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fatalError("Interface Builder is not supported!")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.title.text = nil
        self.icon.image = nil
    }
}
