//
//  ManageDataVC.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 02/12/2023.
//

import UIKit
//import HealthKit

class ManageDataVC: UIViewController, ManageDataVCDelegate{
    
    var userStore: UserStore!
    var urlStore: URLStore!
    var healthDataStore: HealthDataStore!
    var healthDataFetcher: HealthDataFetcher!
    
    // Screen Template
    let vwHeaderSpace = UIView()
    let vwHeaderLogo = UIView()
    let imgVwIcon = UIImageView()
    let logoSize = 25.0
    let safeAreaTopAdjustment = 60.0
    let cardInteriorPadding = Float(5.0)
    let vwHeaderScreenName = UIView()
    let lblScreenNameTitle = UILabel()
    let lblScreenNameTitleText = "Manage Data"
    var vwFooter = UIView()
    let vwFooterHeight = 100.0
    // End Screen Template
    
    //table
    var stckVwManageDataVC = UIStackView()
    var tblDataSources = UITableView()
    var arrayDataSources:[HealthDataStruct]!
//    var arrayDataSources:[[String:String]] = [["dataSource":"Oura", "records":"0"],
//                                              ["dataSource":"Apple Health", "records":"0"]]{
//        didSet{
//            if arrayDataSources[1]["records"] != "0"{
//                DispatchQueue.main.async {
//                    self.tblDataSources.reloadData()
//                    self.removeSpinner()
//                }
//            }
//        }
//    }
    
    // Fetched Health Data
    var appleHealthDataDict = [[String:String]](){
        didSet{
            print("- didSet appleHealthDataDict.count: \(appleHealthDataDict.count)")
            if appleHealthDataDict.count > 0 {
                print("sending apple health data to API")
                healthDataStore.sendAppleHealth(appleHealthDataDict: appleHealthDataDict) { responseResult in
                    switch responseResult{
                    case let .success(responseDict):
                        print("- didSet recieved response Dict")
                        print(responseDict)
//                        self.arrayDataSources[1]["records"] = responseDict["count_of_entries"]
//                        self.healthDataStore.appleHealthData.recordCount = responseDict["count_of_entries"]
//                        self.healthDataStore.updateHealthStruct(name: nil, recordCount: responseDict["count_of_entries"])
                        self.healthDataStore.updateHealthStruct(healthStruct: self.healthDataStore.appleHealthData, name: nil, recordCount: responseDict["count_of_entries"])
                    case let .failure(error):
                        print("- failed to get data, error: \(error)")
                        self.removeSpinner()
                        self.alertMessageCustom = "Failed to get data"
                        self.alertManageDataVC()
                    }

                }
            }
        }
    }
    var ouraDataDict = [[String:String]]()
    var todayDateString = String()
    // Alert and Spinner
    var spinnerView: UIView?
    var alertMessageCustom:String?
    var segueSource:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.hidesBackButton = true
        arrayDataSources = [HealthDataStruct]()
//        print("ManageDataVC viewDidLoad")
//        print("healthDataStore structs:")
//        
//        print(self.healthDataStore.ouraData?.name)
//        print(self.healthDataStore.ouraData?.recordCount)
//        print(self.healthDataStore.appleHealthData?.name)
//        print(self.healthDataStore.appleHealthData?.recordCount)
        
        arrayDataSources.append(self.healthDataStore.ouraData!)
        arrayDataSources.append(self.healthDataStore.appleHealthData!)
        setup_BasicScreenTemplate()
//        setup_btnToGetStepsFromAppleHealth()
//        setup_btnToGetStepsLast30Days()
        tblDataSources.delegate = self
        tblDataSources.dataSource = self
        
        tblDataSources.register(ManageDataTableCell.self, forCellReuseIdentifier: "ManageDataTableCell")
        tblDataSources.rowHeight = UITableView.automaticDimension
        tblDataSources.estimatedRowHeight = 100
        setup_tbl()
        todayDateString = formatDateToString(Date())
        print("- ManageDataVC, todayDateString: \(todayDateString)")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tblDataSources.refreshControl = refreshControl
        
        healthDataStore.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tblDataSources.reloadData()
                self?.removeSpinner()
            }
        }
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
        imgVwIcon.trailingAnchor.constraint(equalTo: vwHeaderLogo.trailingAnchor, constant: widthFromPct(percent: -15) ).isActive = true
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
    
    func setup_tbl(){
        stckVwManageDataVC.accessibilityIdentifier = "stckVwManageDataVC"
        stckVwManageDataVC.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(stckVwManageDataVC)
        stckVwManageDataVC.topAnchor.constraint(equalTo: lblScreenNameTitle.bottomAnchor, constant: heightFromPct(percent: 5)).isActive=true
        stckVwManageDataVC.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        stckVwManageDataVC.bottomAnchor.constraint(equalTo: vwFooter.topAnchor).isActive=true
        stckVwManageDataVC.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        tblDataSources.translatesAutoresizingMaskIntoConstraints=false
        stckVwManageDataVC.addArrangedSubview(tblDataSources)
        
    }
    
    func showHistoryOptions(forSource source: String) {
        let alertController = UIAlertController(title: "\(source) Referesh History Options", message: "Select length of refresh", preferredStyle: .actionSheet)

        let thirtyDaysAction = UIAlertAction(title: "Last 30 Days", style: .default) { action in
            // Handle the action for 30 days history
            print("Fetch 30 days for \(source)")
            
            if source == "Apple Health"{
                self.showSpinner()
                self.healthDataFetcher.fetchSteps(quantityTypeIdentifier: .stepCount, endDateString: self.todayDateString) { stepsDict in
                    self.appleHealthDataDict = stepsDict
                    print("- in ManageDataVC completed fetchSteps")
                }
            }
        }
        alertController.addAction(thirtyDaysAction)

        let entireHistoryAction = UIAlertAction(title: "Entire History", style: .default) { action in
            // Handle the action for entire history
            if source == "Apple Health"{
                self.showSpinner()
                self.healthDataFetcher.fetchSteps(quantityTypeIdentifier: .stepCount) { stepsDict in
                    self.appleHealthDataDict = stepsDict
                }
            }
        }
        alertController.addAction(entireHistoryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    func showSpinner() {
        spinnerView = UIView(frame: self.view.bounds)
        spinnerView?.backgroundColor = UIColor(white: 0, alpha: 0.5)

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = spinnerView!.center
        activityIndicator.startAnimating()
        spinnerView?.addSubview(activityIndicator)

        let messageLabel = UILabel()
        messageLabel.text = "This is a lot of data so it may take more than a minute"
        messageLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.frame = CGRect(x: 0, y: activityIndicator.frame.maxY + 20, width: spinnerView!.bounds.width, height: 50)
        messageLabel.isHidden = true
        spinnerView?.addSubview(messageLabel)

        self.view.addSubview(spinnerView!)

        // Timer to show the label after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            messageLabel.isHidden = false
        }
    }
    func removeSpinner() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
    func alertManageDataVC() {
        // Create an alert
        let alert = UIAlertController(title: nil, message: alertMessageCustom, preferredStyle: .alert)
        // Create an OK button
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Dismiss the alert when the OK button is tapped
            alert.dismiss(animated: true, completion: nil)
        }
        // Add the OK button to the alert
        alert.addAction(okAction)
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        
        if let refresh_control = self.tblDataSources.refreshControl{
            refresh_control.endRefreshing()
        }
        self.tblDataSources.reloadData()
        print("oura data: ")
        print(self.healthDataStore.ouraData?.recordCount)
//        DispatchQueue.main.async {
//            self.refreshControl.endRefreshing()
//            self.tableView.reloadData()
//        }
    }
    
    func segueToManageDataSourceDetailsVC(source:String){
        self.segueSource = source
        self.performSegue(withIdentifier: "goToManageDataSourceDetailsVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToManageDataSourceDetailsVC"){
            let manageDataSourceDetailsVC = segue.destination as! ManageDataSourceDetailsVC
            manageDataSourceDetailsVC.userStore = self.userStore
            manageDataSourceDetailsVC.urlStore = self.urlStore
            manageDataSourceDetailsVC.healthDataStore = self.healthDataStore
            manageDataSourceDetailsVC.healthDataFetcher = self.healthDataFetcher
            manageDataSourceDetailsVC.source = self.segueSource
        }

    }
}

extension ManageDataVC: UITableViewDelegate{

}

extension ManageDataVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageDataTableCell", for: indexPath) as! ManageDataTableCell
        let dataSourceText = arrayDataSources[indexPath.row].name!
        let recordCountText = arrayDataSources[indexPath.row].recordCount!
        cell.config(dataSource: dataSourceText,recordCount:recordCountText )
        cell.manageDataTableVCDelegate = self
        return cell
    }
    

}

protocol ManageDataVCDelegate{
//    func showHistoryOptions(source:String)
    func showHistoryOptions(forSource:String)
    func showSpinner()
    func removeSpinner()
    func segueToManageDataSourceDetailsVC(source:String)
}


class ManageDataTableCell: UITableViewCell{
    var manageDataTableVCDelegate : ManageDataVCDelegate!
    var stckVwMain = UIStackView()
    var stckVwLabels = UIStackView()
    var lblSourceName = UILabel()
    var lblRecordCount = UILabel()
    var btnRefresh = UIButton()
    var dataSource = ""
    var vwSpacerTop = UIView()
    var vwSpacer = UIView()

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(dataSource:String, recordCount:String) {
        self.dataSource = dataSource
        lblSourceName.text = self.dataSource
        lblSourceName.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblSourceName.translatesAutoresizingMaskIntoConstraints = false
        
        lblRecordCount.text = "Record Count: \(recordCount)"
        lblRecordCount.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        lblRecordCount.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwMain.axis = .horizontal
        stckVwLabels.axis = .vertical
        stckVwMain.accessibilityIdentifier = "stckVwMain"
        stckVwMain.translatesAutoresizingMaskIntoConstraints = false
        stckVwLabels.accessibilityIdentifier = "stckVwLabels"
        stckVwLabels.translatesAutoresizingMaskIntoConstraints = false
        
        vwSpacerTop.translatesAutoresizingMaskIntoConstraints = false
        vwSpacer.translatesAutoresizingMaskIntoConstraints = false


        // First add the stack view to the contentView
        contentView.addSubview(vwSpacerTop)
        contentView.addSubview(stckVwMain)
        contentView.addSubview(vwSpacer)

        // Then activate the constraints
        // Set constraints for vwSpacerTop
        vwSpacerTop.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 2.5)).isActive = true
        vwSpacerTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        vwSpacerTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        vwSpacerTop.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true



        vwSpacer.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 2.5)).isActive=true
        vwSpacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive=true
        vwSpacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive=true
        vwSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true  // This line was missing

        
        // Modify the stckVwMain top anchor constraint to attach to vwSpacerTop
        stckVwMain.topAnchor.constraint(equalTo: vwSpacerTop.bottomAnchor).isActive = true
        stckVwMain.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        stckVwMain.bottomAnchor.constraint(equalTo: vwSpacer.topAnchor).isActive = true
        stckVwMain.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true

        stckVwMain.addArrangedSubview(stckVwLabels)
        stckVwLabels.addArrangedSubview(lblSourceName)
        stckVwLabels.addArrangedSubview(lblRecordCount)

        // Button configuration
        btnRefresh.setTitle(" Refresh ", for: .normal)
        btnRefresh.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 12)
        btnRefresh.backgroundColor = .systemOrange
        btnRefresh.layer.cornerRadius = 10
        btnRefresh.translatesAutoresizingMaskIntoConstraints = false
        stckVwMain.addArrangedSubview(btnRefresh)
        btnRefresh.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnRefresh.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        btnRefresh.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 25)).isActive=true
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
        print("- in touchUpInside for \(dataSource)")
        if dataSource == "Oura" {
            print("Go to ManageDataSourceDetailsVC \(dataSource)")
            manageDataTableVCDelegate.segueToManageDataSourceDetailsVC(source: dataSource)
        } else{
            manageDataTableVCDelegate.showHistoryOptions(forSource: dataSource)
        }

    }
}
