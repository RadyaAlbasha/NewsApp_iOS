//
//  Utils.swift
//  News
//
//  Created by Radya Albasha on 11/12/2021.
//

import Foundation
class Utils{
    // to make the date with format for example (1 june 19)
    static func formatTheDate(theComingDate : String) -> String
    {
        var newDate = "0-0-0"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let dateFromString  = dateFormatter.date(from: theComingDate)
        {dateFormatter.dateFormat = "d-MMM-yy"
            let datenew = dateFormatter.string(from: dateFromString)
            newDate = datenew
        }else{
            let allDateArr = theComingDate.components(separatedBy: "T")
            newDate = allDateArr[0]
        }
        return newDate
    }
}
