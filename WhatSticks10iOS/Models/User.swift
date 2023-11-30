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
    var time_stamp_utc: String?
}

