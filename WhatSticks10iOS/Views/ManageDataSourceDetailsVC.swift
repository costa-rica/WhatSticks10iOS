//
//  ManageDataSourceDetailsVC.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 03/12/2023.
//

import UIKit
//import HealthKit

class ManageDataSourceDetailsVC: UIViewController{
    
    var userStore: UserStore!
    var urlStore: URLStore!
    //    var healthStore: HKHealthStore!
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
    var vwFooter = UIView()
    let vwFooterHeight = 100.0
    var source: String!
    // End Screen Template
    
    let stckVwMain = UIStackView()
    let stckVwToken = UIStackView()
    var lblToken = UILabel()
    var txtToken = UITextField()
    var btnRefresh30 = UIButton()
    var btnRefrenshAll = UIButton()
    var recordCount:String?
    
    // Alert and Spinner
    var spinnerView: UIView?
    var alertMessageCustom:String?
    
    var firstApiRequest:String = ""{
        didSet{
            if firstApiRequest == "successfully added oura token"{
                print("- go to second api call in sequence")
                self.healthDataStore.requestOuraData { responseResultOuraData in
                    switch responseResultOuraData{
                    case let .success(responseDictOuraData):
                        print("succesfully got oura data")
//                        self.recordCount = responseDictOuraData["record_count"]
//                        self.healthDataStore.ouraData.recordCount = responseDictOuraData["record_count"]
                        self.healthDataStore.updateHealthStruct(healthStruct: self.healthDataStore.ouraData, name: nil, recordCount: responseDictOuraData["record_count"])
                        self.alertMessageCustom = "Successfully added data"
                        self.removeSpinner()
                        self.alertManageDataVC()
                        
                    case let .failure(error):
                        print("failed to get oura data, error: \(error)")
                        self.alertMessageCustom = "Failed to add data"
                        self.removeSpinner()
                        self.alertManageDataVC()
                    }
                }
            }
        }
    }
    
    // Configure swtchToken
    let lblTokenSwitch = UILabel()
    let swtchToken = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.hidesBackButton = true
        setup_BasicScreenTemplate()
        setupMainStackView()
        btnRefresh30.tag = 1
        btnRefrenshAll.tag = 2
        // Set up tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        if self.userStore.user.oura_token != nil{
            self.txtToken.text = self.userStore.user.oura_token
            txtToken.isEnabled = false // Lock the text field initially
            txtToken.textColor = .gray // Set text color to gray to indicate it's locked
            swtchToken.isOn = false // Set the switch to off initially
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
        
        
        lblScreenNameTitle.text = "Manage Data \(source ?? "*Error Loading Source*") Details"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 30)
        lblScreenNameTitle.numberOfLines=0
        lblScreenNameTitle.lineBreakMode = .byWordWrapping
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        vwHeaderLogo.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: imgVwIcon.bottomAnchor, constant: heightFromPct(percent: 2.5)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 2.5)).isActive=true
        lblScreenNameTitle.trailingAnchor.constraint(equalTo: vwHeaderLogo.trailingAnchor, constant: widthFromPct(percent: -2.5)).isActive = true

        view.addSubview(vwFooter)
        vwFooter.translatesAutoresizingMaskIntoConstraints=false
        vwFooter.backgroundColor = UIColor(named: "gray02")
        vwFooter.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vwFooter.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        vwFooter.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        vwFooter.heightAnchor.constraint(equalToConstant: vwFooterHeight).isActive=true
        
    }
    
    func setupMainStackView() {
        stckVwToken.axis = .vertical
        stckVwToken.distribution = .fill
        stckVwToken.alignment = .fill
        stckVwToken.spacing = 8
        stckVwToken.translatesAutoresizingMaskIntoConstraints = false

        // Add components to the token stack view
        stckVwToken.addArrangedSubview(lblToken)
        stckVwToken.addArrangedSubview(txtToken)
        
        // Configure the stack view
        stckVwMain.axis = .vertical
        stckVwMain.distribution = .fill
        stckVwMain.alignment = .fill
        stckVwMain.spacing = 15 // Adjust the spacing as needed
        stckVwMain.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the token stack view to the main stack view
        stckVwMain.addArrangedSubview(stckVwToken)

        // Add components to the stack view
        stckVwMain.addArrangedSubview(btnRefresh30)
        stckVwMain.addArrangedSubview(btnRefrenshAll)

        // Configure and add subviews
        lblToken.text = "Token:" // Set the label text
        txtToken.placeholder = "Enter Token Here" // Set the placeholder for the text field
        
        // Configure text field
        txtToken.layer.borderColor = UIColor.gray.cgColor
        txtToken.layer.borderWidth = 1.0
        txtToken.layer.cornerRadius = 5.0 // Optional, for rounded corners
        txtToken.heightAnchor.constraint(equalToConstant: 40).isActive = true // Adjust the constant as needed
        // Create padding effect
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40)) // Adjust frame as needed
        txtToken.leftView = paddingView
        txtToken.leftViewMode = .always
        
        btnRefresh30.setTitle("Refresh Last 30 Days", for: .normal) // Set button title
        btnRefrenshAll.setTitle("Refresh All", for: .normal) // Set button title

        // Configure buttons
        [btnRefresh30, btnRefrenshAll].forEach { button in
            button.backgroundColor = .systemOrange
            button.layer.cornerRadius = 5.0 // Optional, for rounded corners
        }
        
        btnRefresh30.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnRefrenshAll.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnRefresh30.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        btnRefrenshAll.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        // Add the stack view to the view
        view.addSubview(stckVwMain)

        // Set constraints for the stack view
        NSLayoutConstraint.activate([
            stckVwMain.topAnchor.constraint(equalTo: lblScreenNameTitle.bottomAnchor, constant: 16), // Adjust the constant as needed
            stckVwMain.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Adjust the constant as needed
            stckVwMain.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16), // Adjust the constant as needed
            stckVwMain.bottomAnchor.constraint(lessThanOrEqualTo: vwFooter.topAnchor, constant: -16) // Adjust the constant as needed
        ])
        

        // Configure lblTokenSwitch
        lblTokenSwitch.text = "Unlock Token:" // Set the label text as needed
//        swtchToken.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)

        // Create stckVwTokenSwitch
        let stckVwTokenSwitch = UIStackView(arrangedSubviews: [lblTokenSwitch, swtchToken])
        stckVwTokenSwitch.axis = .horizontal
        stckVwTokenSwitch.distribution = .fill
        stckVwTokenSwitch.alignment = .center
        stckVwTokenSwitch.spacing = 8
        stckVwTokenSwitch.translatesAutoresizingMaskIntoConstraints = false

        // Add the new stack view to stckVwToken
        stckVwToken.addArrangedSubview(stckVwTokenSwitch)

        // Add action for the switch
        swtchToken.addTarget(self, action: #selector(toggleTokenLock(_:)), for: .valueChanged)
        
    }
    
//    func setupLockToken(){
//        // Configure lblTokenSwitch
//        let lblTokenSwitch = UILabel()
//        lblTokenSwitch.text = "Lock Token:" // Set the label text as needed
//
//        // Configure swtchToken
//        let swtchToken = UISwitch()
//        swtchToken.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
//
//        // Create stckVwTokenSwitch
//        let stckVwTokenSwitch = UIStackView(arrangedSubviews: [lblTokenSwitch, swtchToken])
//        stckVwTokenSwitch.axis = .horizontal
//        stckVwTokenSwitch.distribution = .fill
//        stckVwTokenSwitch.alignment = .center
//        stckVwTokenSwitch.spacing = 8
//        stckVwTokenSwitch.translatesAutoresizingMaskIntoConstraints = false
//
//        // Add the new stack view to stckVwToken
//        stckVwToken.addArrangedSubview(stckVwTokenSwitch)
//
//        // ... remaining existing code ...
//
//        // Add action for the switch
//        swtchToken.addTarget(self, action: #selector(toggleTokenLock(_:)), for: .valueChanged)
//    }
    
    // Function to handle switch value change
    @objc func toggleTokenLock(_ sender: UISwitch) {
//        txtToken.isEnabled = !sender.isOn // Lock or unlock the txtToken based on the switch state
        txtToken.isEnabled = sender.isOn
        txtToken.textColor = sender.isOn ? .label : .gray // .label adapts to light or dark mode
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
        print("- in touchUpInside for ...")
        
        if txtToken.text != nil{
            showSpinner()
            switch sender.tag {
            case 1:
                self.removeSpinner()
                //            buttonIdentifier = "Button 30 Days"
                print("Update \(source ?? "no source") for last 30 days")
                self.alertMessageCustom = "Not yet working. Use All data."
                self.alertManageDataVC()
            case 2:
                //            buttonIdentifier = "Button All"
                print("Update \(source ?? "no source") for history")
                
                healthDataStore.sendOuraToken(ouraToken: self.txtToken.text ?? "no_token") { responseResultOuraToken in
                    switch responseResultOuraToken{
                    case .success(_):
                        self.firstApiRequest = "successfully added oura token"
                    case let .failure(error):
                        print("failed to add oura token, error: \(error)")
                        self.alertMessageCustom = "Failed to add data"
                        self.removeSpinner()
                        self.alertManageDataVC()
                    }
                }
            default:
                //            buttonIdentifier = "Unknown Button"
                print("No update ??? \(source ?? "no source") for history")
            }
        }
        else if userStore.user.oura_token_verified ?? false{
            showSpinner()
            self.firstApiRequest = "token already verified"
        }
        else {
            self.alertMessageCustom = "Must have token"
            alertManageDataVC()
        }


    }
    @objc func viewTapped() {
        // Dismiss the keyboard
        view.endEditing(true)
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
    
}
