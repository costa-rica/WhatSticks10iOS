//
//  HealthDataStore.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 30/11/2023.
//

import UIKit

enum HealthDataStoreError: Error {
    case noServerResponse
    case unknownServerResponse
    case failedToDeleteUser
    
    var localizedDescription: String {
        switch self {
        case .noServerResponse: return "What Sticks API main server is not responding."
        case .unknownServerResponse: return "Server responded but What Sticks iOS has no way of handling response."

        default: return "What Sticks main server is not responding."
            
        }
    }
}

class HealthDataStore {
    var token: String!
    var requestStore:RequestStore!
    
    
    func sendAppleHealth(appleHealthDataDict:[[String:String]], completion:@escaping([String:String])->Void){
        
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .receive_steps, body: appleHealthDataDict)
        
        let task = requestStore.session.dataTask(with: request) { data, response, error in
            do {
                if let unwrapped_data = data  {
                    
                    if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: .mutableContainers) as? [String: String] {
                        OperationQueue.main.addOperation {
                            completion(jsonResult)
                            print("getLastPostId result: \(jsonResult)")
                        }
                    }
                }

            } catch {
                print("Error receiving response: most likely Post did not decode well")
            }
            guard let unwrapped_resp = response as? HTTPURLResponse else{
                print("no response (getLastPostId)")
                return
            }
            print("getLastPostId response status: \(unwrapped_resp.statusCode)")
            return
        }
        task.resume()
        
        
    }
}


