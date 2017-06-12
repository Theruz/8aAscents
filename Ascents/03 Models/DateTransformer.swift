//
//  DateTransformer.swift
//  Ascents
//
//  Created by Theophile on 06.02.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import ObjectMapper
import Localize_Swift

// localization check:disable

enum DateFormat: String {
    case millisecond = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case second = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    case dateOnly = "yyyy-MM-dd"
    case hourMin = "HH:mm"
    case hourMinSymbol = "h:mm a"
    case hourOnlySymbol = "h a"
    case monthDay = "MMM dd"
    case dayInWeek = "eeee MMM dd, hh:mm a"
    case dateTimeMinuteSymbol = "yyyy-MM-dd, h:mm a"
    case dateTimeHourOnlySymbol = "yyyy-MM-dd, h a"
}

extension  DateFormatter: TransformType {
    
    private static func formatter(with format: DateFormat, localeIdentifier: String?, timeZone: TimeZone) -> DateFormatter {
        
        let formatter = DateFormatter()
        var format = format.rawValue
        var local: Locale
        
        if let localeIdentifier = localeIdentifier {
            local = Locale(identifier: localeIdentifier)
            format = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: local) ?? format
            formatter.locale = local
        }
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        
        return formatter
    }
		
    static func date(from string: String, format: DateFormat, localeIdentifier: String? = Localize.currentLanguage(), timeZone: TimeZone? = TimeZone.current) -> Date? {
        
        let formatter = DateFormatter.formatter(with: format, localeIdentifier: localeIdentifier,
                                                timeZone: timeZone ?? TimeZone.current)
        
        return formatter.date(from: string)
    }
    
    static func string(from date: Date, format: DateFormat, localeIdentifier: String? = Localize.currentLanguage()) -> String {
        
        let formatter = DateFormatter.formatter(with: format, localeIdentifier: localeIdentifier,
                                                timeZone: TimeZone.current)
        
        return formatter.string(from: date)
    }
	
	open func transformFromJSON(_ value: Any?) -> Date? {
		
		if let dateString = value as? String {
			
            if let date = DateFormatter.date(from: dateString, format: .millisecond, localeIdentifier: nil,
                                             timeZone: TimeZone(abbreviation: "UTC")) {
				return date
			} else if let date = DateFormatter.date(from: dateString, format: .second, localeIdentifier: nil,
			                                        timeZone: TimeZone(abbreviation: "UTC")) {
				return date
			} else if let date = DateFormatter.date(from: dateString, format: .dateOnly, localeIdentifier: nil,
			                                        timeZone: TimeZone(abbreviation: "UTC")) {
				return date
			}
			
			return nil
		}
		return nil
	}
	
	open func transformToJSON(_ value: Date?) -> String? {
		
		if let date = value {
			
			// ???: Which format we transform the date
            return  DateFormatter.string(from: date, format: .millisecond)
			//            else if let dateString = DateTransformer.secondFormatter.stringFromDate(date) {return dateString}
			//            else if let dateString = DateTransformer.standartFormatter.stringFromDate(date) {return dateString}
			//            else if let dateString = DateTransformer.dateOnlyFormatter.stringFromDate(date) {return dateString}
			
			//            return nil
		}
		return nil
	}
}
