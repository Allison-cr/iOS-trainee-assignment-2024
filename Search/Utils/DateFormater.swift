//
//  DateFormater.swift
//  Search
//
//  Created by Alexander Suprun on 12.04.2024.
//
import Foundation

func formatDateString(_ dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    if let date = dateFormatter.date(from: dateString) {
        let dateFormatterOutput = DateFormatter()
        dateFormatterOutput.dateFormat = "yyyy"
        let formattedDate = dateFormatterOutput.string(from: date)
        return formattedDate
    } else {
        return nil
    }
}
