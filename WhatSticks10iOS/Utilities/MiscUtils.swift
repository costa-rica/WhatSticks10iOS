//
//  MiscUtils.swift
//  WhatSticks10iOS
//
//  Created by Nick Rodriguez on 30/11/2023.
//

import Foundation
import HealthKit

func authorizeHealthKit(healthStore: HKHealthStore) {
    // Specify the data types you want to read
    let healthKitTypesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!
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


//import HealthKit

class HealthDataFetcher {
    let healthStore = HKHealthStore()

    
    
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
                entry["startDate"] = self.formatDateToString(sample.startDate)
                entry["endDate"] = self.formatDateToString(sample.endDate)
                entry["device"] = sample.device?.name ?? "Unknown Device"
                entry["metadata"] = sample.metadata?.description ?? "No Metadata"

                healthDataEntries.append(entry)
            }

            completion(healthDataEntries)
        }

        healthStore.execute(query)
    }
    
    // Does not work because of asynchronicity of health data
    func fetchHealthData(startDateString: String, endDateString: String, quantityTypeIdentifier: HKQuantityTypeIdentifier) -> [[String: String]] {
        var healthDataEntries: [[String: String]] = []

        guard let startDate = convertStringToDate(dateString: startDateString),
              let endDate = convertStringToDate(dateString: endDateString),
              let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            print("Invalid date or quantity type")
            return healthDataEntries
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching health data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for sample in samples {
                var entry: [String: String] = [:]
                entry["quantity"] = String(sample.quantity.doubleValue(for: HKUnit.count()))
                entry["source"] = sample.sourceRevision.source.name
                entry["startDate"] = self.formatDateToString(sample.startDate)
                entry["endDate"] = self.formatDateToString(sample.endDate)
                entry["device"] = sample.device?.name ?? "Unknown Device"
                entry["metadata"] = sample.metadata?.description ?? "No Metadata"

                healthDataEntries.append(entry)
            }
        }

        healthStore.execute(query)
        print("Number of health data entries: \(healthDataEntries.count)")

        return healthDataEntries
    }

    private func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }

    private func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    // Works, but no string output for
    func fetchStepsData(startDateString: String, endDateString: String) {
        guard let startDate = convertStringToDate(dateString: startDateString),
              let endDate = convertStringToDate(dateString: endDateString) else {
            print("Invalid date format")
            return
        }

        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
            guard let statistics = statistics, error == nil else {
                print("Error fetching steps data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let quantity = statistics.sumQuantity() {
                let steps = quantity.doubleValue(for: HKUnit.count())
                print("Steps from \(startDateString) to \(endDateString): \(steps)")
            }
        }

        healthStore.execute(query)
    }

    
    // Works but aggregates steps
    func fetchIndividualStepsData(startDateString: String, endDateString: String) {
        guard let startDate = convertStringToDate(dateString: startDateString),
              let endDate = convertStringToDate(dateString: endDateString) else {
            print("Invalid date format")
            return
        }

        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: stepsQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Error fetching steps data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for sample in samples {
                let steps = sample.quantity.doubleValue(for: HKUnit.count())
                let source = sample.sourceRevision.source.name
                let startDate = sample.startDate
                let endDate = sample.endDate
                let device = sample.device?.name ?? "Unknown Device"
                let metadata = sample.metadata?.description ?? "No Metadata"

                print("Steps: \(steps), Source: \(source), StartDate: \(startDate), EndDate: \(endDate), Device: \(device), Metadata: \(metadata)")
            }
        }

        healthStore.execute(query)
    }


    
    
}


