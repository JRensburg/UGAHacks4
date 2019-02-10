//
//  CustomerViewController.swift
//  HacksProject
//
//  Created by Jaco Van Rensburg on 2/9/19.
//  Copyright © 2019 UGAHacks. All rights reserved.
//

import UIKit

class CustomerView: UIView {

    var data : Customer?
    var imageView = UIImageView()
    var name = UILabel()
    var accept = UIButton()
    var cancel = UIButton()
    var controllerDelegate : ControllerDelegate?
    init(customer: Customer){
        let screen = UIScreen.main.bounds
        data = customer
        
        super.init(frame: CGRect(x: 0, y: 0, width: screen.width / 1.25, height: screen.height / 1.5))
        do {
            let image = try UIImage(data: Data(contentsOf: URL(string: self.data?.photo?.first?.url ?? "") ?? URL(fileURLWithPath: "")))
                self.imageView.image = image
        } catch {
            print("Image could not be loaded")
        }
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        setUpViews()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        //Configure Views
        let backdrop = UIImageView(image: #imageLiteral(resourceName: "gradient2.jpg"))
        addSubview(backdrop)
        backdrop.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
       backgroundColor = UIColor(displayP3Red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        name.text = (data?.Name ?? "") + "\n" + (data?.Phone ?? "")
        name.textColor = .white
        name.numberOfLines = 2
        name.textAlignment = .center
        name.font = UIFont.systemFont(ofSize: 28.0)
        imageView.contentMode = .scaleAspectFit
        cancel.setTitle("Cancel", for: .normal)
        accept.setTitle("Accept", for: .normal)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        accept.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        //add views
        addSubviews(imageView,name,accept,cancel)
        sendSubviewToBack(backdrop)
        //setup constraints
        imageView.snp.makeConstraints{
            $0.height.equalToSuperview().dividedBy(2)
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }
        name.snp.makeConstraints{
            $0.centerX.width.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(1.5)
            $0.height.equalTo(120)
        }
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func cancelTapped() -> Void {
        self.removeFromSuperview()
    }

    @objc func acceptTapped() -> Void {
        //let view = SaleView(customer: data!)
        controllerDelegate?.addSaleView(customer: data!)
         self.removeFromSuperview()
    }
    
}


