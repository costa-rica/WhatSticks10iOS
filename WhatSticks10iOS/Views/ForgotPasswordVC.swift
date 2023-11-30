//
//  ForgotPasswordVC.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 30/11/2023.
//

import UIKit

class ForgotPasswordVC:UIViewController{
    let vwHeaderSpace = UIView()
    let vwHeaderLogo = UIView()
    let imgVwIcon = UIImageView()
    let safeAreaTopAdjustment = 40.0
    let cardInteriorPadding = Float(5.0)
    
    let vwHeaderScreenName = UIView()
    let lblScreenNameTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_vwLogin()
        setup_lblTitle()
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
        lblScreenNameTitle.text = "Forgot Password"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 40)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        vwHeaderLogo.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: imgVwIcon.bottomAnchor, constant: heightFromPct(percent: 2.5)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: vwHeaderLogo.leadingAnchor, constant: widthFromPct(percent: 2.5)).isActive=true
    }
}
