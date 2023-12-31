//
//  MiscUtils.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 30/11/2023.
//

import Foundation
import HealthKit


import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    private var config: [String: Any]?

    private init() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            self.config = dict
        }
    }

    func getValue(forKey key: String) -> String? {
        return config?[key] as? String
    }
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for:Date())
    }
}

func authorizeHealthKit(healthStore: HKHealthStore) {
    // Specify the data types you want to read
    let healthKitTypesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]

    // Request authorization
    healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
        if success {
//                self.fetchStepsCount()
//                self.sendStepsDataToAPI()
            print("-- User allowed Read Health data")
        } else {
            // Handle the error here.
            print("Authorization failed with error: \(error?.localizedDescription ?? "unknown error")")
        }
    }
}

func formatDateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func formatDateTimeToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: date)
}

class HealthDataFetcher {
    let healthStore = HKHealthStore()

    private func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
//    private func formatDateToString(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return dateFormatter.string(from: date)
//    }
    func getDate30DaysAgo(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }

        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: date)
        return thirtyDaysAgo != nil ? dateFormatter.string(from: thirtyDaysAgo!) : nil
    }

        
    
    func fetchSteps(quantityTypeIdentifier: HKQuantityTypeIdentifier, completion: @escaping ([[String: String]]) -> Void) {
        var stepsEntries = [[String: String]]()
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            print("Invalid date or quantity type")
            completion([])
            return
        }
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil else {print("error making query"); return}

            samples?.forEach { sample in
                if let sample = sample as? HKQuantitySample {
                    var entry: [String: String] = [:]
                    entry["sampleType"] = sample.sampleType.identifier
                    entry["startDate"] = formatDateTimeToString(sample.startDate)
                    entry["endDate"] = formatDateTimeToString(sample.endDate)
                    entry["metadata"] = sample.metadata?.description ?? "No Metadata"
                    entry["sourceName"] = sample.sourceRevision.source.name
                    entry["sourceVersion"] = sample.sourceRevision.version
                    entry["sourceProductType"] = sample.sourceRevision.productType ?? "Unknown"
                    entry["device"] = sample.device?.name ?? "Unknown Device"
                    entry["UUID"] = sample.uuid.uuidString
                    entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
                    stepsEntries.append(entry)
                }
            }
            completion(stepsEntries)
        }
        healthStore.execute(query)
    }
    

    func fetchSteps(quantityTypeIdentifier: HKQuantityTypeIdentifier,endDateString: String,  completion: @escaping ([[String: String]]) -> Void) {
        print("- acccessed fetchSteps ")
        var stepsEntries = [[String: String]]()

        guard let startDate = convertStringToDate(dateString: getDate30DaysAgo(from:endDateString) ?? "2023-11-01"),
              let endDate = convertStringToDate(dateString: endDateString),
              let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            print("Invalid date or quantity type")
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
 
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil else {print("error making query"); return}

            samples?.forEach { sample in
                if let sample = sample as? HKQuantitySample {
                    var entry: [String: String] = [:]
                    entry["sampleType"] = sample.sampleType.identifier
                    entry["startDate"] = formatDateTimeToString(sample.startDate)
                    entry["endDate"] = formatDateTimeToString(sample.endDate)
                    entry["metadata"] = sample.metadata?.description ?? "No Metadata"
                    entry["sourceName"] = sample.sourceRevision.source.name
                    entry["sourceVersion"] = sample.sourceRevision.version
                    entry["sourceProductType"] = sample.sourceRevision.productType ?? "Unknown"
                    entry["device"] = sample.device?.name ?? "Unknown Device"
                    entry["UUID"] = sample.uuid.uuidString
                    entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
                    stepsEntries.append(entry)
                }
            }
            completion(stepsEntries)
            print("stepsEntries count: \(stepsEntries.count)")
        }
        healthStore.execute(query)
    }

    // ChatGPT to get accept an array of data types (HKQuantityTypeIdentifier) and place all into a dictonary to send back
    func fetchHealthData(for quantityTypeIdentifiers: [HKQuantityTypeIdentifier], completion: @escaping ([[String: String]]) -> Void) {
        var allHealthDataEntries = [[String: String]]()
        let dispatchGroup = DispatchGroup()

        for quantityTypeIdentifier in quantityTypeIdentifiers {
            dispatchGroup.enter()
            let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier)!

            let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                // Check for error and handle appropriately
                guard error == nil else {
                    print("Error fetching samples: \(error!.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                // Process each sample
                var healthDataEntries: [[String: String]] = []
                samples?.forEach { sample in
                    if let sample = sample as? HKQuantitySample {
                        var entry: [String: String] = [:]
                        
                        entry["source"] = sample.sourceRevision.source.name
                        entry["sourceVersion"] = sample.sourceRevision.version
                        entry["startDate"] = formatDateTimeToString(sample.startDate)
                        entry["endDate"] = formatDateTimeToString(sample.endDate)
                        entry["device"] = sample.device?.name ?? "Unknown Device"
                        entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
                        entry["metadata"] = sample.metadata?.description ?? "No Metadata"

                        healthDataEntries.append(entry)
                    }
                }
                
                allHealthDataEntries.append(contentsOf: healthDataEntries)
                dispatchGroup.leave()
            }

            healthStore.execute(query)
        }

        dispatchGroup.notify(queue: .main) {
            completion(allHealthDataEntries)
        }
    }
    
    
    // ChatGPT to get steps data only
    func fetchHealthData(startDateString: String, endDateString: String, quantityTypeIdentifier: HKQuantityTypeIdentifier, completion: @escaping ([[String: String]]) -> Void) {
        guard let startDate = convertStringToDate(dateString: startDateString),
              let endDate = convertStringToDate(dateString: endDateString),
              let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            print("Invalid date or quantity type")
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching health data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            var healthDataEntries: [[String: String]] = []
            for sample in samples {
                var entry: [String: String] = [:]
                entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
                entry["source"] = sample.sourceRevision.source.name
                entry["startDate"] = formatDateTimeToString(sample.startDate)
                entry["endDate"] = formatDateTimeToString(sample.endDate)
                entry["device"] = sample.device?.name ?? "Unknown Device"
                entry["metadata"] = sample.metadata?.description ?? "No Metadata"

                healthDataEntries.append(entry)
            }

            completion(healthDataEntries)
        }

        healthStore.execute(query)
    }
    
    
    
    
//    // Does not work because of asynchronicity of health data
//    func fetchHealthData(startDateString: String, endDateString: String, quantityTypeIdentifier: HKQuantityTypeIdentifier) -> [[String: String]] {
//        var healthDataEntries: [[String: String]] = []
//
//        guard let startDate = convertStringToDate(dateString: startDateString),
//              let endDate = convertStringToDate(dateString: endDateString),
//              let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
//            print("Invalid date or quantity type")
//            return healthDataEntries
//        }
//
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//
//        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
//            guard let samples = samples as? [HKQuantitySample], error == nil else {
//                print("Error fetching health data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            for sample in samples {
//                var entry: [String: String] = [:]
//                entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
//                entry["source"] = sample.sourceRevision.source.name
//                entry["startDate"] = self.formatDateToString(sample.startDate)
//                entry["endDate"] = self.formatDateToString(sample.endDate)
//                entry["device"] = sample.device?.name ?? "Unknown Device"
//                entry["metadata"] = sample.metadata?.description ?? "No Metadata"
//
//                healthDataEntries.append(entry)
//            }
//        }
//
//        healthStore.execute(query)
//        print("Number of health data entries: \(healthDataEntries.count)")
//
//        return healthDataEntries
//    }


    
//    // Works, but no string output for
//    func fetchStepsData(startDateString: String, endDateString: String) {
//        guard let startDate = convertStringToDate(dateString: startDateString),
//              let endDate = convertStringToDate(dateString: endDateString) else {
//            print("Invalid date format")
//            return
//        }
//
//        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//
//        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
//            guard let statistics = statistics, error == nil else {
//                print("Error fetching steps data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            if let quantity = statistics.sumQuantity() {
//                let steps = quantity.doubleValue(for: HKUnit.count())
//                print("Steps from \(startDateString) to \(endDateString): \(steps)")
//            }
//        }
//
//        healthStore.execute(query)
//    }

    
//    // Works but aggregates steps
//    func fetchIndividualStepsData(startDateString: String, endDateString: String) {
//        guard let startDate = convertStringToDate(dateString: startDateString),
//              let endDate = convertStringToDate(dateString: endDateString) else {
//            print("Invalid date format")
//            return
//        }
//
//        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//
//        let query = HKSampleQuery(sampleType: stepsQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
//            guard let samples = samples as? [HKQuantitySample], error == nil else {
//                print("Error fetching steps data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            for sample in samples {
//                let steps = sample.quantity.doubleValue(for: HKUnit.count())
//                let source = sample.sourceRevision.source.name
//                let startDate = sample.startDate
//                let endDate = sample.endDate
//                let device = sample.device?.name ?? "Unknown Device"
//                let metadata = sample.metadata?.description ?? "No Metadata"
//
//                print("Steps: \(steps), Source: \(source), StartDate: \(startDate), EndDate: \(endDate), Device: \(device), Metadata: \(metadata)")
//            }
//        }
//
//        healthStore.execute(query)
//    }


    
//    // Tutorial: https://www.youtube.com/watch?v=7vOF1kGnsmo
//    func fetchTodaySteps(){
//        let steps = HKQuantityType(.stepCount)
//        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
//        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
//            guard
//                let result = result,
//                let quantity = result.sumQuantity(),
//                error == nil else {
//                print("error fetching fetchTodaySteps data ")
//                return
//            }
//            let stepCount = quantity.doubleValue(for: .count())
//            print(stepCount)
//        }
//        healthStore.execute(query)
//    }
    
}


