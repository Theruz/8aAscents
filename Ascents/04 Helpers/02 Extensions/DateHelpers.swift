//
//  DateHelpers.swift
//  Ascents
//
//  Created by Nguyen Truong Luu on 5/11/17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation

extension Date {

    var yearMonthDateTimeMilliSecond: String {
        return DateFormatter.string(from: self, format: .millisecond)
    }
    
    var yearMonthDateString: String {
        return DateFormatter.string(from: self, format: .dateOnly)
    }
    
    var dateTimeSecondString: String {
        return DateFormatter.string(from: self, format: .second)
    }
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    var year: Int {
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: self)
        return year
    }
    
    var minute: Int {
        let calendar = NSCalendar.current
        let minute = calendar.component(.minute, from: self)
        return minute
    }
    
    private static func componentFlags() -> Set<Calendar.Component> { return [.year, .month, .day, .weekOfYear, .hour, .minute, .second, .weekday, .weekdayOrdinal, .weekOfYear] }
    
    private static func components(_ fromDate: Date) -> DateComponents! {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }
    
    /**
     Creates a new date by adding minutes.
     
     - Parameter days: The number of minutes to add.
     - Returns A new date object.
     */
    func dateByAddingMinutes(_ minutes: Int) -> Date {
        var dateComp = DateComponents()
        dateComp.minute = minutes
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /**
     Returns true if dates are equal while ignoring time.
     
     - Parameter date: The Date to compare.
     */
    func isEqualToDateIgnoringTime(_ date: Date) -> Bool {
        let comp1 = Date.components(self)
        let comp2 = Date.components(date)
        return ((comp1!.year == comp2!.year) && (comp1!.month == comp2!.month) && (comp1!.day == comp2!.day))
    }
}
