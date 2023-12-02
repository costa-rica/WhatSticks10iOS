//
//  ViewController.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 29/11/2023.
//
import Foundation
import UIKit
import HealthKit

class LoginVC: UIViewController {
    
    var userStore: UserStore!
    var urlStore: URLStore!
    var requestStore: RequestStore!
    var healthStore: HKHealthStore!
    var healthDataStore: HealthDataStore!
    
    let vwHeaderSpace = UIView()
    let vwHeaderLogo = UIView()
    let imgVwIcon = UIImageView()
    let safeAreaTopAdjustment = 40.0
    let cardInteriorPadding = Float(5.0)
    
    let vwHeaderScreenName = UIView()
    let lblScreenNameTitle = UILabel()
    
    // Login
    let stckVwLogin = UIStackView()
    let stckVwEmailRow = UIStackView()
    let stckVwPasswordRow = UIStackView()
    
    let lblEmail = UILabel()
    let txtEmail = UITextField()
    let lblPassword = UILabel()
    let txtPassword = UITextField()
    let btnShowPassword = UIButton()
    
    // Btn Login
    let btnLogin = UIButton()
    var alertFailedLoginMessage = ""
    
    var stckVwRememberMe: UIStackView!
    let swRememberMe = UISwitch()
//    var lblLoginStatusMessage = UILabel() {
//        didSet{
//            if lblLoginStatusMessage.text != ""{
//                setup_vwFailedToLogin()
//            }
//        }
//    }
    
    
    var token = "token" {
        didSet{
            if token != "token"{
                //                rinconStore.requestStore.token = userStore.user.token
                
                if swRememberMe.isOn{
                    self.userStore.writeUserJson()
                } else {
                    self.userStore.deleteUserJsonFile()
                    self.txtEmail.text = ""
                    self.txtPassword.text = ""
                }
                performSegue(withIdentifier: "goToDashboardVC", sender: self)

            }
        }
    }
    
    var signUpLabel:UILabel!
    var btnForgotPassword:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userStore = UserStore()
        urlStore = URLStore()
        userStore.urlStore = self.urlStore
        print("Device Name: \(UIDevice.current.name)")
        //Device Name: iPhone 15
        
        
        #if targetEnvironment(simulator)
            // Code to execute when running on the simulator
            print("Running on Simulator")
            urlStore.apiBase = APIBase.local
        #else
            // Code to execute when running on a real device
            print("Running on Real Device")
            print("Device Name: \(UIDevice.current.name)")
            urlStore.apiBase = APIBase.prod
        #endif
        
        
        healthStore = HKHealthStore()
        healthDataStore = HealthDataStore()
        requestStore = RequestStore()
        requestStore.urlStore = self.urlStore
        healthDataStore.requestStore = self.requestStore
        
        
        setup_vwLogin()
        setup_lblTitle()
        setup_stckVwLogin()
        setup_btnLogin()
        setup_stckVwRememberMe()
        setupSignUpLabel()
        setupForgotPasswordButton()
        authorizeHealthKit(healthStore: self.healthStore)
        //        for family in UIFont.familyNames.sorted() {
        //            let names = UIFont.fontNames(forFamilyName: family)
        //            print("Family: \(family) Font names: \(names)")
        //        }
        userStore.checkUserJson(completion: { result in
            switch result{
            case let .success(user):
                self.txtEmail.text = user.email
                self.txtPassword.text = user.password
                self.userStore.user = user
            case let .failure(error):
                print(error)
            }
        })
        
        // Set up tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setup_vwLogin(){
        
        view.addSubview(vwHeaderSpace)
        vwHeaderSpace.accessibilityIdentifier = "vwHeaderSpace"
        //        vwHeaderSpace.backgroundColor = .red
        vwHeaderSpace.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderSpace.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vwHeaderSpace.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        vwHeaderSpace.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        vwHeaderSpace.heightAnchor.constraint(equalToConstant: safeAreaTopAdjustment).isActive=true
        
        if let unwrapped_image = UIImage(named: "wsLogo192") {
            imgVwIcon.image = unwrapped_image.scaleImage(toSize: CGSize(width: 45, height: 45))
            
//            vwHeaderLogo.heightAnchor.constraint(equalToConstant: imgVwIcon.image!.size.height + 10).isActive=true
        }
        imgVwIcon.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderLogo.addSubview(imgVwIcon)
        imgVwIcon.accessibilityIdentifier = "imgVwIcon"
        imgVwIcon.topAnchor.constraint(equalTo: vwHeaderLogo.topAnchor).isActive=true
        imgVwIcon.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 10) ).isActive = true
        
        view.addSubview(vwHeaderLogo)
//        vwHeaderLogo.backgroundColor = .gray
        vwHeaderLogo.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderLogo.topAnchor.constraint(equalTo: vwHeaderSpace.bottomAnchor, constant: heightFromPct(percent: 5)).isActive=true
        vwHeaderLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive=true
        vwHeaderLogo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive=true
        
        
    }
    
    func setup_lblTitle(){
        lblScreenNameTitle.text = "Login"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 40)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        vwHeaderLogo.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: imgVwIcon.bottomAnchor, constant: heightFromPct(percent: 2.5)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 2.5)).isActive=true
    }
    
    func setup_stckVwLogin(){
        lblEmail.text = "Email"
        lblPassword.text = "Password"
        
        stckVwLogin.translatesAutoresizingMaskIntoConstraints = false
        stckVwEmailRow.translatesAutoresizingMaskIntoConstraints = false
        stckVwPasswordRow.translatesAutoresizingMaskIntoConstraints = false
        txtEmail.translatesAutoresizingMaskIntoConstraints = false
        txtPassword.translatesAutoresizingMaskIntoConstraints = false
        lblEmail.translatesAutoresizingMaskIntoConstraints = false
        lblPassword.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwLogin.accessibilityIdentifier="stckVwLogin"
        stckVwEmailRow.accessibilityIdentifier="stckVwEmailRow"
        stckVwPasswordRow.accessibilityIdentifier = "stckVwPasswordRow"
        txtEmail.accessibilityIdentifier = "txtEmail"
        txtPassword.accessibilityIdentifier = "txtPassword"
        lblEmail.accessibilityIdentifier = "lblEmail"
        lblPassword.accessibilityIdentifier = "lblPassword"
        
        txtPassword.isSecureTextEntry = true
        btnShowPassword.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btnShowPassword.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        stckVwEmailRow.addArrangedSubview(lblEmail)
        stckVwEmailRow.addArrangedSubview(txtEmail)
        
        stckVwPasswordRow.addArrangedSubview(lblPassword)
        stckVwPasswordRow.addArrangedSubview(txtPassword)
        stckVwPasswordRow.addArrangedSubview(btnShowPassword)
        
        stckVwLogin.addArrangedSubview(stckVwEmailRow)
        stckVwLogin.addArrangedSubview(stckVwPasswordRow)
        
        stckVwLogin.axis = .vertical
        stckVwEmailRow.axis = .horizontal
        stckVwPasswordRow.axis = .horizontal
        
        stckVwLogin.spacing = 5
        stckVwEmailRow.spacing = 2
        stckVwPasswordRow.spacing = 2
        
        txtEmail.borderStyle = .roundedRect
        txtPassword.borderStyle = .roundedRect
        
        view.addSubview(stckVwLogin)
        
        NSLayoutConstraint.activate([
            stckVwLogin.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: cardInteriorPadding)),
            stckVwLogin.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: cardInteriorPadding * -1)),
            stckVwLogin.topAnchor.constraint(equalTo: lblScreenNameTitle.bottomAnchor, constant: heightFromPct(percent: cardInteriorPadding)),
            
            lblEmail.widthAnchor.constraint(equalTo: lblPassword.widthAnchor),
        ])
        
        view.layoutIfNeeded()// <-- Realizes size of lblPassword and stckVwLogin
        
        // This code makes the widths of lblPassword and btnShowPassword take lower precedence than txtPassword.
        lblPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btnShowPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    @objc func togglePasswordVisibility() {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        let imageName = txtPassword.isSecureTextEntry ? "eye.slash" : "eye"
        btnShowPassword.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func setup_btnLogin(){
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.layer.borderColor = UIColor.systemBlue.cgColor
        btnLogin.layer.borderWidth = 2
//        btnLogin.setTitleColor(.black, for: .normal)
        btnLogin.backgroundColor = .systemBlue
        btnLogin.layer.cornerRadius = 10
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
        stckVwLogin.addArrangedSubview(btnLogin)
        
        btnLogin.addTarget(self, action: #selector(touchDownLogin(_:)), for: .touchDown)
        btnLogin.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        
    }
    
    @objc func touchDownLogin(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
        //        goToAdminFlag = false
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        requestLogin()
    }
    
    func requestLogin(){
        
//        if let unwrapped_email = txtEmail.text, let unwrapped_pw = txtPassword.text {
        if let unwrapped_email = txtEmail.text, !unwrapped_email.isEmpty,
           let unwrapped_pw = txtPassword.text, !unwrapped_pw.isEmpty {
            
            // send api request
            userStore.requestLoginUser(email: unwrapped_email, password: unwrapped_pw) { responseResultLogin in
                switch responseResultLogin{
                case let .success(user_obj):
                    //                    print("user_response: \(user_obj)")
                    self.userStore.user.id = user_obj.id
                    self.userStore.user.token = user_obj.token
                    self.userStore.user.email = self.txtEmail.text
                    self.userStore.user.password = self.txtPassword.text
                    //                    self.userStore.user.user_rincons = user_obj.user_rincons
                    self.userStore.user.username = user_obj.username
//                    self.lblLoginStatusMessage.text = ""
                    self.token = user_obj.token!
                    self.requestStore.token = user_obj.token!
//                    print("self.token: \(self.token)")
                    
                    
                case let .failure(error):
                    print("Login error: \(error)")
                    OperationQueue.main.addOperation {
//                        self.lblLoginStatusMessage = UILabel()
                        
                        if error as! UserStoreError == UserStoreError.failedToRecieveServerResponse{
                            self.alertFailedLoginMessage = "Server down ... probably :/"
                        } else {
                            self.alertFailedLoginMessage = "Failed to login. \n Are you registered?"
                        }

                        self.alertFailedLogin()
                    }
                }
            }
        } else {
            print("No email or password provided")
            self.alertFailedLoginMessage = "No email or password provided"
            self.alertFailedLogin()
            
//            setup_vwFailedToLogin()
//            OperationQueue.main.addOperation {
//                self.lblLoginStatusMessage = UILabel()
//                let tempLabel = UILabel()
//                tempLabel.text = "No email and password provided!"
////                if error as! UserStoreError == UserStoreError.failedToRecieveServerResponse{
////                    tempLabel.text = "Server down ... probably :/"
////                } else {
////                    tempLabel.text = "Failed To Login"
////                }
//                self.lblLoginStatusMessage = tempLabel
//            }
        }
        
    }
    
    
    func setup_stckVwRememberMe() {
        stckVwRememberMe = UIStackView()
        let lblRememberMe = UILabel()
        
        lblRememberMe.text = "Remember Me"
        stckVwRememberMe.spacing = 10
        stckVwRememberMe.addArrangedSubview(lblRememberMe)
        stckVwRememberMe.addArrangedSubview(swRememberMe)
        stckVwLogin.addArrangedSubview(stckVwRememberMe)
        stckVwRememberMe.translatesAutoresizingMaskIntoConstraints = false
        lblRememberMe.translatesAutoresizingMaskIntoConstraints = false
        swRememberMe.translatesAutoresizingMaskIntoConstraints = false
        stckVwRememberMe.accessibilityIdentifier = "stckVwRememberMe"
        lblRememberMe.accessibilityIdentifier = "lblRememberMe"
        swRememberMe.accessibilityIdentifier = "swRememberMe"
        
        
        swRememberMe.isOn = true
    }
    
//    func setup_vwFailedToLogin(){
//        let vwFailedToLogin = UIView()
//        //        vwFailedToLogin.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1.0)
//        vwFailedToLogin.backgroundColor = UIColor(named: "gray-500")
//        vwFailedToLogin.translatesAutoresizingMaskIntoConstraints=false
//        view.addSubview(vwFailedToLogin)
//        lblLoginStatusMessage.translatesAutoresizingMaskIntoConstraints=false
//        vwFailedToLogin.addSubview(lblLoginStatusMessage)
//        
//        vwFailedToLogin.topAnchor.constraint(equalTo: vwHeaderSpace.bottomAnchor, constant: heightFromPct(percent: 1)).isActive=true
//        vwFailedToLogin.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: 5)).isActive=true
//        vwFailedToLogin.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -5)).isActive=true
//        
//        vwFailedToLogin.layer.cornerRadius = 10
//        
//        view.layoutIfNeeded()
//        vwFailedToLogin.heightAnchor.constraint(equalToConstant: lblLoginStatusMessage.frame.size.height).isActive=true
//        
//        
//        lblLoginStatusMessage.topAnchor.constraint(equalTo: vwFailedToLogin.topAnchor).isActive=true
//        lblLoginStatusMessage.leadingAnchor.constraint(equalTo: vwFailedToLogin.leadingAnchor, constant: widthFromPct(percent: 5)).isActive=true
//
//    }
    
    private func setupForgotPasswordButton() {
        btnForgotPassword = UIButton(type: .system)
        btnForgotPassword.setTitle("Forgot Password?", for: .normal)
        btnForgotPassword.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)

        // Layout the button as needed
        btnForgotPassword.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(btnForgotPassword)
        stckVwLogin.addArrangedSubview(btnForgotPassword)
//        NSLayoutConstraint.activate([
//            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            forgotPasswordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor) // Adjust position as needed
//        ])
    }
    
    @objc private func forgotPasswordTapped() {
//        let resetPasswordVC = ResetPasswordVC() // Assuming ResetPasswordVC is your reset password ViewController
//        self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        
        performSegue(withIdentifier: "goToForgotPasswordVC", sender: self)
    }
    
    private func setupSignUpLabel() {
        let fullText = "Don’t have an account? Sign up"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "Sign up")
        
        // Add underlining or color to 'Sign up'
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        signUpLabel = UILabel()
        view.addSubview(signUpLabel)
        signUpLabel.translatesAutoresizingMaskIntoConstraints=false
        signUpLabel.attributedText = attributedString
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signUpTapped)))
        
        signUpLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: heightFromPct(percent: -20)).isActive=true
        signUpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: 5)).isActive=true
        signUpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -5)).isActive=true
    }
    
    func alertFailedLogin() {
        // Create an alert
        let alert = UIAlertController(title: nil, message: alertFailedLoginMessage, preferredStyle: .alert)
        
        // Create an OK button
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Dismiss the alert when the OK button is tapped
            alert.dismiss(animated: true, completion: nil)
            // Go back to HomeVC
//            self.navigationController?.popViewController(animated: true)
        }
        
        // Add the OK button to the alert
        alert.addAction(okAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func viewTapped() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    
    @objc func signUpTapped() {
        performSegue(withIdentifier: "goToRegisterVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToRegisterVC"){
            let RegisterVC = segue.destination as! RegisterVC
            RegisterVC.userStore = self.userStore
            RegisterVC.urlStore = self.urlStore
            print("prepare(for goToRegisterVC --> accessed! ")
        }
        else if (segue.identifier == "goToDashboardVC"){
            let DashboardVC = segue.destination as! DashboardVC
            DashboardVC.userStore = self.userStore
            DashboardVC.urlStore = self.urlStore
            DashboardVC.healthStore = self.healthStore
            DashboardVC.healthDataStore = self.healthDataStore
        }
    }
    
}

