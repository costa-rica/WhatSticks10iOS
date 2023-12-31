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
    var btnToGetStepsLast30Days = UIButton()
    var btnGoToManageDataVC = UIButton()
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
        self.navigationItem.hidesBackButton = true
        setup_BasicScreenTemplate()
//        setup_btnToGetStepsFromAppleHealth()
//        setup_btnToGetStepsLast30Days()
        setup_btnGoToManageDataVC()
        print("- in DAshboardVC viewDidLoad -")
        print("healthDataStore structs:")
        print(healthDataStore.ouraData?.name)
    }
    func setup_BasicScreenTemplate(){
        
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
        imgVwIcon.trailingAnchor.constraint(equalTo: vwHeaderLogo.trailingAnchor, constant: widthFromPct(percent: -5) ).isActive = true
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
    
    func setup_btnGoToManageDataVC(){
        btnGoToManageDataVC.setTitle(" Manage Data ", for: .normal)
        btnGoToManageDataVC.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        btnGoToManageDataVC.backgroundColor = .systemOrange
        btnGoToManageDataVC.layer.cornerRadius = 10
        btnGoToManageDataVC.translatesAutoresizingMaskIntoConstraints=false
        vwFooter.addSubview(btnGoToManageDataVC)
        btnGoToManageDataVC.sizeToFit()

        btnGoToManageDataVC.topAnchor.constraint(equalTo: vwFooter.bottomAnchor,constant: heightFromPct(percent: -10)).isActive=true

        btnGoToManageDataVC.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor,constant: widthFromPct(percent: -5)).isActive=true
        btnGoToManageDataVC.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnGoToManageDataVC.addTarget(self, action: #selector(touchUpInside_goToManageDataVC(_:)), for: .touchUpInside)
    }
    @objc func touchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    @objc func touchUpInside_goToManageDataVC(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print("- in touchUpInside_goToManageDataVC")
        performSegue(withIdentifier: "goToManageDataVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToManageDataVC"){
            let manageDataVC = segue.destination as! ManageDataVC
            manageDataVC.userStore = self.userStore
            manageDataVC.urlStore = self.urlStore
            manageDataVC.healthDataFetcher = self.healthDataFetcher
            manageDataVC.healthDataStore = self.healthDataStore
            print("prepare(for goToManageDataVC --> accessed! ")
            print("healthDataStore structs:")
            print(self.healthDataStore.ouraData?.name)
            print(self.healthDataStore.ouraData?.recordCount)
            print(self.healthDataStore.appleHealthData?.name)
            print(self.healthDataStore.appleHealthData?.recordCount)
        }

    }
    
//    private func formattedDate(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.string(from: date)
//    }

//    func setup_btnToGetStepsFromAppleHealth(){
//        btnToGetStepsFromAppleHealth.setTitle(" Get Apple Health Data ", for: .normal)
//        btnToGetStepsFromAppleHealth.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
//        btnToGetStepsFromAppleHealth.backgroundColor = .systemBlue
//        btnToGetStepsFromAppleHealth.layer.cornerRadius = 10
//        btnToGetStepsFromAppleHealth.layer.borderColor = UIColor.systemBlue.cgColor
//        btnToGetStepsFromAppleHealth.layer.borderWidth = 3
//        btnToGetStepsFromAppleHealth.translatesAutoresizingMaskIntoConstraints=false
//        vwFooter.addSubview(btnToGetStepsFromAppleHealth)
//        btnToGetStepsFromAppleHealth.sizeToFit()
////        btnToGetStepsFromAppleHealth.heightAnchor.constraint(equalToConstant: vwFooter.frame.size.height - 30).isActive=true
//        btnToGetStepsFromAppleHealth.topAnchor.constraint(equalTo: vwFooter.bottomAnchor,constant: heightFromPct(percent: -10)).isActive=true
////        btnToGetStepsFromAppleHealth.leadingAnchor.constraint(equalTo: vwFooter.leadingAnchor,constant: widthFromPct(percent: 10)).isActive=true
//        btnToGetStepsFromAppleHealth.trailingAnchor.constraint(equalTo: vwFooter.trailingAnchor,constant: widthFromPct(percent: -5)).isActive=true
//        btnToGetStepsFromAppleHealth.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
//        btnToGetStepsFromAppleHealth.addTarget(self, action: #selector(touchUpInside_fetchSteps(_:)), for: .touchUpInside)
//
//    }
    


//    @objc func touchUpInside_fetchSteps(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
//            sender.transform = .identity
//        }, completion: nil)
//
//        healthDataFetcher.fetchSteps(quantityTypeIdentifier: .stepCount) { stepsDict in
//            self.appleHealthDataDict = stepsDict
//        }
//    }
    
    
//    func setup_btnToGetStepsLast30Days(){
//        btnToGetStepsLast30Days.setTitle(" Get 30 Days ", for: .normal)
//        btnToGetStepsLast30Days.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
//        btnToGetStepsLast30Days.backgroundColor = .systemOrange
//        btnToGetStepsLast30Days.layer.cornerRadius = 10
//        btnToGetStepsLast30Days.translatesAutoresizingMaskIntoConstraints=false
//        vwFooter.addSubview(btnToGetStepsLast30Days)
//        btnToGetStepsLast30Days.sizeToFit()
//
//        btnToGetStepsLast30Days.topAnchor.constraint(equalTo: vwFooter.bottomAnchor,constant: heightFromPct(percent: -10)).isActive=true
//
//        btnToGetStepsLast30Days.trailingAnchor.constraint(equalTo: btnToGetStepsFromAppleHealth.leadingAnchor,constant: widthFromPct(percent: -5)).isActive=true
//        btnToGetStepsLast30Days.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
//        btnToGetStepsLast30Days.addTarget(self, action: #selector(touchUpInside_fetchSteps30Days(_:)), for: .touchUpInside)
//    }
    
//    @objc func touchUpInside_fetchSteps30Days(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
//            sender.transform = .identity
//        }, completion: nil)
//        print("- in touchUpInside_fetchSteps30Days")
//        healthDataFetcher.fetchSteps(quantityTypeIdentifier: .stepCount, endDateString: "2023-12-02") { stepsDict in
//            self.appleHealthDataDict = stepsDict
//        }
//    }
    

    
//    func fetchStepsCount() {
//        if let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) {
//            let query = HKSampleQuery(sampleType: stepCountType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] (query, results, error) in
//                guard let samples = results as? [HKQuantitySample] else { return }
//
//                var tempStepsData = [String: Int]() // Temporary dictionary for aggregation
//
//                // Aggregate steps by date
//                for sample in samples {
//                    let steps = Int(sample.quantity.doubleValue(for: HKUnit.count()))
//                    let date = self?.formattedDate(sample.endDate)
//                    if let dateStr = date {
//                        tempStepsData[dateStr, default: 0] += steps
//                    }
//                }
//
//                // Convert the dictionary into the required array of dictionaries
//                self?.stepsDataByDate = tempStepsData.map { [$0.key: $0.value] }
//                
//                // After aggregation, you can proceed to send the data to API or handle it as required
//                print(self?.stepsDataByDate ?? "No steps data")
//            }
//            healthStore.execute(query)
//        }
//    }
    

    
}
