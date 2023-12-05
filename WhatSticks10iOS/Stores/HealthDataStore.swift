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
    var ouraData:HealthDataStruct?
    var appleHealthData:HealthDataStruct?
    
//    init() {
//        // Initialize with default values or fetch from saved state
//        ouraData = HealthDataStruct()
//        appleHealthData = HealthDataStruct()
//    }
    // Callback to be called when data changes
    var onDataChanged: (() -> Void)?

    // Method to update data
    func updateHealthStruct(healthStruct:HealthDataStruct?, name:String?, recordCount:String?){
        guard var health_struct = healthStruct else {return}
        health_struct.name = name
        health_struct.recordCount = recordCount
        onDataChanged?()
    }
    
//    func updateOuraData(name: String?, recordCount: String?) {
//        guard var oura_data = self.ouraData else {return}
//        oura_data.name = name
//        oura_data.recordCount = recordCount
//        onDataChanged?()
//    }
//
//    func updateAppleHealthData(name: String?, recordCount: String?) {
//        guard var apple_health_data = self.ouraData else {return}
//        apple_health_data.name = name
//        apple_health_data.recordCount = recordCount
//        onDataChanged?()
//    }

    
    func sendOuraToken(ouraToken:String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .add_oura_token, body: ["oura_token":ouraToken])
        let task = requestStore.session.dataTask(with: request){ data, response, error
            in
            // Handle potential error from the data task
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                        DispatchQueue.main.async {
                            completion(.success(jsonResult))
                        }

                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    func requestOuraData(completion: @escaping (Result<[String: String], Error>) -> Void) {
        let request = requestStore.createRequestWithToken(endpoint: .add_oura_sleep_sessions)
        print("---- request: ")
        print(request)

        let task = requestStore.session.dataTask(with: request) { data, response, error in
            // Handle potential error from the data task
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // Check HTTP response status code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400 {
                    // Handle 400 Bad Request
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.badServerResponse)))
                    }
                    return
                }
            }

            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                    DispatchQueue.main.async {
                        completion(.success(jsonResult))
                    }
                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    
    
    
    
    
    
    
//    func requestOuraData(completion: @escaping (Result<[String: String], Error>) -> Void) {
//        let request = requestStore.createRequestWithToken(endpoint: .add_oura_sleep_sessions)
//        
//        let task = requestStore.session.dataTask(with: request){ data, response, error
//            in
//            // Handle potential error from the data task
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//
//            guard let unwrapped_data = data else {
//                // No data scenario
//                DispatchQueue.main.async {
//                    completion(.failure(URLError(.badServerResponse)))
//                }
//                return
//            }
//
//            do {
//                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
//                    DispatchQueue.main.async {
//                        completion(.success(jsonResult))
//                    }
//                } else {
//                    // Data is not in the expected format
//                    DispatchQueue.main.async {
//                        completion(.failure(URLError(.cannotParseResponse)))
//                    }
//                }
//            } catch {
//                // Data parsing error
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
//        task.resume()
//    }
//    
    func sendAppleHealth(appleHealthDataDict: [[String: String]], completion: @escaping (Result<[String: String], Error>) -> Void) {

        let request = requestStore.createRequestWithTokenAndBody(endPoint: .receive_steps, body: appleHealthDataDict)

        let task = requestStore.session.dataTask(with: request) { data, response, error in
            // Handle potential error from the data task
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                    DispatchQueue.main.async {
                        completion(.success(jsonResult))
                    }
                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    
    
//    func sendAppleHealth(appleHealthDataDict:[[String:String]], completion:@escaping([String:String])->Void){
//        
//        let request = requestStore.createRequestWithTokenAndBody(endPoint: .receive_steps, body: appleHealthDataDict)
//        
//        let task = requestStore.session.dataTask(with: request) { data, response, error in
//            do {
//                if let unwrapped_data = data  {
//                    
//                    if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: .mutableContainers) as? [String: String] {
//                        OperationQueue.main.addOperation {
//                            completion(jsonResult)
//                            print("getLastPostId result: \(jsonResult)")
//                        }
//                    }
//                }
//            } catch {
//                print("Error receiving response: most likely Post did not decode well")
//            }
//            guard let unwrapped_resp = response as? HTTPURLResponse else{
//                print("no response (getLastPostId)")
//                return
//            }
//            print("getLastPostId response status: \(unwrapped_resp.statusCode)")
//            return
//        }
//        task.resume()
//    }
}


