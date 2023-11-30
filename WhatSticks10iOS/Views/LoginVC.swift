//
//  ViewController.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 29/11/2023.
//

import UIKit

class LoginVC: UIViewController {
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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup_vwLogin()
        setup_lblTitle()
        setup_stckVwLogin()
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
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
            imgVwIcon.image = unwrapped_image.scaleImage(toSize: CGSize(width: 35, height: 35))

            vwHeaderLogo.heightAnchor.constraint(equalToConstant: imgVwIcon.image!.size.height + 10).isActive=true
        }
        imgVwIcon.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderLogo.addSubview(imgVwIcon)
        imgVwIcon.accessibilityIdentifier = "imgVwIcon"
        imgVwIcon.topAnchor.constraint(equalTo: vwHeaderLogo.topAnchor).isActive=true
        imgVwIcon.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 5) ).isActive = true
        
        view.addSubview(vwHeaderLogo)
        vwHeaderLogo.backgroundColor = .black
        vwHeaderLogo.translatesAutoresizingMaskIntoConstraints = false
        vwHeaderLogo.topAnchor.constraint(equalTo: vwHeaderSpace.bottomAnchor, constant: 60.0).isActive=true
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
    
    
}

