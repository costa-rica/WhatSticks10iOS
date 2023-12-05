//
//  User.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 29/11/2023.
//

import Foundation

class User:Codable {
    var id: String?
    var email: String?
    var password: String?
    var username: String?
    var token: String?
    var admin: Bool?
    var oura_token: String?
    var oura_token_verified: Bool?
    var time_stamp_utc: String?
    var dataDict:[String:String]?
    var ouraHealthStruct:HealthDataStruct?
    var appleHealthStruct:HealthDataStruct?
}

struct HealthDataStruct:Codable {
    var name:String?
    var recordCount:String?
    var dataDict:[String:String]?
}

//struct AppleHealthStruct{
//    var name:String?
//    var recordCount:String?
//}
