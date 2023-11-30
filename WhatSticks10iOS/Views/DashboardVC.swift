//
//  DashboardVC.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 29/11/2023.
//

import UIKit
import HealthKit

class DashboardVC: UIViewController{
    
    var userStore: UserStore!
    var urlStore: URLStore!
    var healthStore: HKHealthStore!
    var healthDataStore: HealthDataStore!
    
    // Screen Template
    let vwHeaderSpace = UIView()
    let vwHeaderLogo = UIView()
    let imgVwIcon = UIImageView()
    let logoSize = 25.0
    let safeAreaTopAdjustment = 60.0
    let cardInteriorPadding = Float(5.0)
    let vwHeaderScreenName = UIView()
    let lblScreenNameTitle = UILabel()
    let lblScreenNameTitleText = "Dashboard"
    var vwFooter = UIView()
    let vwFooterHeight = 100.0
    // End Screen Template
    
    var btnToGetStepsFromAppleHealth = UIButton()
    // Array of dictionaries to store aggregated steps data
    var stepsDataByDate = [[String: Int]]()
    let healthDataFetcher = HealthDataFetcher()
    var appleHealthDataDict = [[String:String]](){
        didSet{
            if appleHealthDataDict.count > 0 {
                healthDataStore.sendAppleHealth(appleHealthDataDict: appleHealthDataDict) { responseDict in
                    print(responseDict)
                }
            }
        }
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_vwLogin()
        setup_btnToGetStepsFromAppleHealth()
        self.navigationItem.hidesBackButton = true


    }
    func setup_vwLogin(){
        
        view.addSubview(vwHeaderSpace)
        vwHeaderSpace.accessibilityIdentifier = "vwHeaderSpace"
                vwHeaderSpace.backgroundColor = UIColor(named: "gray02")
        vwHeaderSpace.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderSpace.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vwHeaderSpace.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        vwHeaderSpace.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        vwHeaderSpace.heightAnchor.constraint(equalToConstant: safeAreaTopAdjustment).isActive=true
        
        if let unwrapped_image = UIImage(named: "wsLogo192") {
            imgVwIcon.image = unwrapped_image.scaleImage(toSize: CGSize(width: logoSize, height: logoSize))
            vwHeaderLogo.heightAnchor.constraint(equalToConstant: imgVwIcon.image!.size.height + 10).isActive=true
        }
        imgVwIcon.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderLogo.addSubview(imgVwIcon)
        imgVwIcon.accessibilityIdentifier = "imgVwIcon"
        imgVwIcon.topAnchor.constraint(equalTo: vwHeaderLogo.topAnchor).isActive=true
        imgVwIcon.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 5) ).isActive = true
        view.addSubview(vwHeaderLogo)
        vwHeaderLogo.backgroundColor = UIColor(named: "gray02")
        vwHeaderLogo.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderLogo.topAnchor.constraint(equalTo: vwHeaderSpace.bottomAnchor).isActive=true
        vwHeaderLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        vwHeaderLogo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        
        
        lblScreenNameTitle.text = lblScreenNameTitleText
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 40)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        vwHeaderLogo.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: imgVwIcon.bottomAnchor, constant: heightFromPct(percent: 2.5)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 2.5)).isActive=true
        
        view.addSubview(vwFooter)
        vwFooter.translatesAutoresizingMaskIntoConstraints=false
        vwFooter.backgroundColor = UIColor(named: "gray02")
        vwFooter.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vwFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        vwFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        vwFooter.heightAnchor.constraint(equalToConstant: vwFooterHeight).isActive=true
        
    }
    
//    func setup_lblTitle(){
//        lblScreenNameTitle.text = "Dashboard"
//        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 40)
//        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
//        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
//        vwHeaderLogo.addSubview(lblScreenNameTitle)
//        lblScreenNameTitle.topAnchor.constraint(equalTo: imgVwIcon.bottomAnchor, constant: heightFromPct(percent: 2.5)).isActive=true
//        lblScreenNameTitle.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 2.5)).isActive=true
//    }
    
//    func setup_vwFooter(){
//        
//    }
    

    func setup_btnToGetStepsFromAppleHealth(){
        btnToGetStepsFromAppleHealth.setTitle("Get Apple Health Data", for: .normal)
        btnToGetStepsFromAppleHealth.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        btnToGetStepsFromAppleHealth.backgroundColor = .systemBlue
        btnToGetStepsFromAppleHealth.layer.cornerRadius = 10
        btnToGetStepsFromAppleHealth.translatesAutoresizingMaskIntoConstraints=false
        vwFooter.addSubview(btnToGetStepsFromAppleHealth)
        btnToGetStepsFromAppleHealth.sizeToFit()
//        btnToGetStepsFromAppleHealth.heightAnchor.constraint(equalToConstant: vwFooter.frame.size.height - 30).isActive=true
        btnToGetStepsFromAppleHealth.topAnchor.constraint(equalTo: vwFooter.bottomAnchor,constant: heightFromPct(percent: -10)).isActive=true
//        btnToGetStepsFromAppleHealth.leadingAnchor.constraint(equalTo: vwFooter.leadingAnchor,constant: widthFromPct(percent: 10)).isActive=true
        btnToGetStepsFromAppleHealth.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor,constant: widthFromPct(percent: -5)).isActive=true
        btnToGetStepsFromAppleHealth.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnToGetStepsFromAppleHealth.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)

    }
    
    @objc func touchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)

    }

    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print("Get apple health")
        healthDataFetcher.fetchHealthData(startDateString: "2023-11-28", endDateString: "2023-11-30", quantityTypeIdentifier: .stepCount) { stepsDict in
            self.appleHealthDataDict = stepsDict
            print("Finished gettign steps")
        }
    }
    
    func fetchStepsCount() {
        if let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            let query = HKSampleQuery(sampleType: stepCountType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] (query, results, error) in
                guard let samples = results as? [HKQuantitySample] else { return }

                var tempStepsData = [String: Int]() // Temporary dictionary for aggregation

                // Aggregate steps by date
                for sample in samples {
                    let steps = Int(sample.quantity.doubleValue(for: HKUnit.count()))
                    let date = self?.formattedDate(sample.endDate)
                    if let dateStr = date {
                        tempStepsData[dateStr, default: 0] += steps
                    }
                }

                // Convert the dictionary into the required array of dictionaries
                self?.stepsDataByDate = tempStepsData.map { [$0.key: $0.value] }
                
                // After aggregation, you can proceed to send the data to API or handle it as required
                print(self?.stepsDataByDate ?? "No steps data")
            }
            healthStore.execute(query)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
}
