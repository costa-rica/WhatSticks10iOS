//
//  URLBuilder.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 29/11/2023.
//

import UIKit

enum APIBase:String, CaseIterable {
    case local = "localhost"
    case dev = "dev"
    case prod = "prod"
    var urlString:String {
        switch self{
        case .local: return "http://127.0.0.1:5001/"
        case .dev: return "https://api10.what-sticks.com/"
        case .prod: return "https://api10.what-sticks.com/"
        }
    }
}

enum EndPoint: String {
    case are_we_running = "are_we_running"
    case user = "user"
    case register = "register"
    case test_response = "test_response"
    case login = "login"
    case receive_steps = "receive_steps"
    case add_oura_token = "add_oura_token"
    case add_oura_sleep_sessions = "add_oura_sleep_sessions"
}

class URLStore {
    

    var apiBase:APIBase!

    func callEndpoint(endPoint: EndPoint) -> URL{
        let baseURLString = apiBase.urlString + endPoint.rawValue
        let components = URLComponents(string:baseURLString)!
        return components.url!
    }
    func callRinconEndpoint(endPoint: EndPoint, rincon_id: String) -> URL{
        let baseURLString = apiBase.urlString + endPoint.rawValue + "/\(rincon_id)"
        let components = URLComponents(string:baseURLString)!
        return components.url!
    }
    func callRinconFileEndpoint(endPoint:EndPoint, file_name:String) -> URL{
        let baseURLString = apiBase.urlString + endPoint.rawValue + "/\(file_name)"
        let components = URLComponents(string:baseURLString)!
        return components.url!
    }
    func callApiQueryStrings(endPoint:EndPoint, queryStringArray:[String]) -> URL {
        var urlString = apiBase.urlString + endPoint.rawValue
        for queryString in queryStringArray {
            urlString = urlString + "/\(queryString)"
        }
        let components = URLComponents(string:urlString)!
        return components.url!
    }
}

class RequestStore {
    
    var urlStore:URLStore!
    
    var token: String!
    let wsApiPassword = ConfigManager.shared.getValue(forKey: "WS_API_PASSWORD")
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    //MARK: for json writing/reading only
    let fileManager:FileManager
    private let documentsURL:URL
    init() {
        self.fileManager = FileManager.default
        self.documentsURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func createRequestWithToken(endpoint:EndPoint) ->URLRequest{
        let url = urlStore.callEndpoint(endPoint: endpoint)
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
        // Add WS_API_PASSWORD header
//        let wsApiPassword = ConfigManager.shared.getValue(forKey: "WS_API_PASSWORD")
//        request.setValue(self.wsApiPassword, forHTTPHeaderField: "WS_API_PASSWORD")
        return request
    }
    
    // This was an old function but because json encoding can handle [String:String] and [[String:String]] the same, we modified the code to this
    // old function: createRequestWithTokenAndBody(endPoint: EndPoint, dict_body:[String:String])->URLRequest
    func createRequestWithTokenAndBody<T: Encodable>(endPoint: EndPoint, body: T) -> URLRequest {
        print("- createRequestWithTokenAndBody")
        let url = urlStore.callEndpoint(endPoint: endPoint)
        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.setValue(self.token, forHTTPHeaderField: "x-access-token")

        // Add WS_API_PASSWORD header
//        var body_obj = body as! [String:String]
//        body_obj["WS_API_PASSWORD"]=self.wsApiPassword
//        let wsApiPassword = ConfigManager.shared.getValue(forKey: "WS_API_PASSWORD")
//        request.setValue(wsApiPassword, forHTTPHeaderField: "WS_API_PASSWORD")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode body: \(error)")
        }
        print("built request: \(request)")
        return request
    }

//        func createRequestWithTokenAndBody<T: Encodable>(endPoint: EndPoint, body: T) -> URLRequest {
//            print("- createRequestWithTokenAndBody")
//            let url = urlStore.callEndpoint(endPoint: endPoint)
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue(self.token, forHTTPHeaderField: "x-access-token")
//
//            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
//            do {
//                let jsonData = try encoder.encode(body)
//                request.httpBody = jsonData
//            } catch {
//                print("Failed to encode body: \(error)")
//            }
//            print("built request: \(request)")
//            return request
//        }
    
    func printCallBackToTerminal(){
        let url = urlStore.callEndpoint(endPoint: .are_we_running)
        let task = self.session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    print(jsonResult)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func createRequestWithTokenAndQueryString(endpoint: EndPoint, queryString:[String]) -> URLRequest{
        print("- createRequestWithTokenAndQueryString")

        let url = urlStore.callApiQueryStrings(endPoint: endpoint, queryStringArray: queryString)
        print("url: \(url)")
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
        
        return request
    }
    
//    func createRequestWithTokenAndRinconAndBody(endpoint: EndPoint, rincon_id:String, bodyParamDict:[String:String]?, file_name:String?) -> URLRequest{
//        print("- createRequestWithTokenAndRinconAndBody")
//        var jsonData = Data()
//        var url = urlStore.callRinconEndpoint(endPoint: .rincon_posts, rincon_id: rincon_id)
//        if let unwrapped_file_name = file_name{
//            url = urlStore.callRinconFileEndpoint(endPoint: .rincon_post_file, file_name: unwrapped_file_name)
//        }
//        var request = URLRequest(url:url)
//        request.httpMethod = "POST"
//        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json",forHTTPHeaderField: "Accept")
//        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
//
////        print("reques.header: \(request.allHTTPHeaderFields!)")
//        if var unwrapped_bodyParamsDict = bodyParamDict{
//            unwrapped_bodyParamsDict["ios_flag"] = "true"
//            do {
//                let jsonEncoder = JSONEncoder()
//                jsonData = try jsonEncoder.encode(unwrapped_bodyParamsDict)
//            } catch {
//                print("- Failed to encode rincon_id ")
//            }
//            request.httpBody = jsonData
//            return request
//        }
//        return request
//    }
    
//    func createRequestWithTokenAndRinconAndBodyTwo(endpoint:EndPoint,rincon:Rincon,dictBody:[String:String]?, filename:String?)->URLRequest{
//        print("- createRequestWithTokenAndRinconAndBodyTwo")
//
//        let url = urlStore.callEndpoint(endPoint: endpoint)
//        var request = URLRequest(url:url)
//        request.httpMethod = "POST"
//        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json",forHTTPHeaderField: "Accept")
//        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
//
//        var combinedDict: [String: Any] = [:]
//        if let dictBody = dictBody {
//            for (key, value) in dictBody {
//                combinedDict[key] = value
//            }
//        }
//        // Encode the Rincon instance and add it to combinedDict
//        do {
//            let jsonData = try JSONEncoder().encode(rincon)
//            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                for (key, value) in jsonDict {
//                    combinedDict[key] = value
//                }
//            }
//        } catch {
//            print("Failed to encode Rincon:", error)
//        }
//        // Convert combinedDict to JSON and assign it as the httpBody
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: combinedDict, options: [])
//            request.httpBody = jsonData
//        } catch {
//            print("Failed to convert combinedDict to JSON:", error)
//        }
//
//        return request
//
//
//
//    }
    
//    func createRequestSendTokenAndPost(post:Post) -> URLRequest{
//        print("- createRequestSendPost")
//        var jsonData = Data()
//        let url = urlStore.callEndpoint(endPoint: .receive_rincon_post)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        // Set Content-Type header to application/json.
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
//        // Convert the Post object into JSON.
//        let encoder = JSONEncoder()
//        do {
//            jsonData = try encoder.encode(post)
//            print("- post encoded succesfully")
//        } catch {
//            print("- Problem encoding post for sending rincon post")
//        }
//        // Set the JSON data as the HTTP body.
//        request.httpBody = jsonData
//        print("request: \(request)")
//        return request
//    }
    
//    /* send image 3: stackoverflow version */
//    func createRequestSendImageAndTokenThree(dictNewImages:[String:UIImage]) -> (URLRequest, Data){
//        print("- createRequestSendImageAndTokenThree")
//        let url = urlStore.callEndpoint(endPoint: .receive_image)
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.setValue( self.token, forHTTPHeaderField: "x-access-token")
//
//        let boundary = UUID().uuidString
//        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var data = Data()
//        for (filename, uiimage) in dictNewImages{
//            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
//            data.append("Content-Disposition: form-data; name=\"\(filename)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            data.append(uiimage.jpegData(compressionQuality: 1)!)
//        }
//
//        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//        urlRequest.httpBody = data
//        return (urlRequest, data)
//    }
    

    
//    func createRequestWithTokenAndRinconAndQueryStringAndBody(endpoint: EndPoint, rincon_id:String, queryString:[String], bodyParamDict:[String:String]?) -> URLRequest{
//        print("- createRequestWithTokenAndRinconAndQueryStringAndBody")
//        var jsonData = Data()
////        var url = urlStore.callRinconEndpoint(endPoint: .rincon_posts, rincon_id: rincon_id)
//        let url = urlStore.callApiQueryStrings(endPoint: endpoint, queryStringArray: queryString)
//
//        print("url: \(url)")
//        var request = URLRequest(url:url)
//        request.httpMethod = "POST"
//        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json",forHTTPHeaderField: "Accept")
////        print("** RinconStore token \(self.token!)")
//        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
//        
////        print("reques.header: \(request.allHTTPHeaderFields!)")
//        if var unwrapped_bodyParamsDict = bodyParamDict{
//            unwrapped_bodyParamsDict["ios_flag"] = "true"
//            do {
//                let jsonEncoder = JSONEncoder()
//                jsonData = try jsonEncoder.encode(unwrapped_bodyParamsDict)
//            } catch {
//                print("- Failed to encode rincon_id ")
//            }
//            request.httpBody = jsonData
//            return request
//        }
//        return request
//    }
    

    
//    func createRequestWithTokenAndBody(endPoint: EndPoint, dict_body:[String:String])->URLRequest {
//        print("- createRequestWithTokenAndBody")
//        let url = urlStore.callEndpoint(endPoint: endPoint)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
//
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        do {
//            let jsonData = try encoder.encode(dict_body)
//            request.httpBody = jsonData
//        } catch {
//            print("Failed to encode dict_body: \(error)")
//
//        }
//        print("built request: \(request)")
//        return request
//    }
    


//    func createRequestWithTokenAndRincon(endpoint:EndPoint, rincon:Rincon)->URLRequest {
//        let url = urlStore.callEndpoint(endPoint: endpoint)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue( self.token, forHTTPHeaderField: "x-access-token")
//
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        do {
//            let jsonData = try encoder.encode(rincon)
//            request.httpBody = jsonData
//        } catch {
//            print("Failed to encode Rincon: \(error)")
//        }
//
//        return request
//    }
    
//    func createRequestWithBody(endpoint:EndPoint,bodyDict:[String:String]->URLRequest){
//
//    }
//    func createRequestSendVideoAndToken(videoName:String, videoURL:URL)->(URLRequest,Data){
//        let url = urlStore.callEndpoint(endPoint: .receive_video)
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.setValue( self.token, forHTTPHeaderField: "x-access-token")
//
//        let boundary = UUID().uuidString
//        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var bodyData = Data()
//        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
//        bodyData.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(videoName)\"\r\n".data(using: .utf8)!)
//        bodyData.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
//
//        do {
//            let videoData = try Data(contentsOf: videoURL)
//            bodyData.append(videoData)
//        } catch {
//            print("failed to convert video url to data")
//        }
//
//        bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//        urlRequest.httpBody = bodyData
//        return (urlRequest, bodyData)
//    }
}
