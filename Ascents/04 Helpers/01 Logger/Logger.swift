//
//  Logger.swift
//  Ascents
//
//  Created by Theophile on 25.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

// localization check:disable

import Foundation

import XCGLogger

/// Basic logger for Swift files.
public let Log: XCGLogger = {
	
	// Create a logger object with no destinations
	let log = XCGLogger(identifier: "logger", includeDefaultDestinations: false)
	
	// No logger in production
	guard Environment.server != .production else { return log }
	
	//    log.xcodeColorsEnabled = true
	//    log.xcodeColors = [
	//        .Verbose: .lightGrey,
	//        .Debug: .darkGrey,
	//        .Info: .darkGreen,
	//        .Warning: .orange,
	//        .Error: .red,
	//        .Severe: XCGLogger.XcodeColor(fg: UIColor.whiteColor, bg: UIColor.redColor) // Optionally use RGB values directly
	//    ]
	
	let logFormatter = DateFormatter()
	logFormatter.dateFormat = "HH:mm:ss.SSS"
	log.dateFormatter = logFormatter
	
	// Create a destination for the system console log
	let consoleDestination = log.setupConsoleLogger()
	
	// Add Banner at top of console
    if let bannerPath = Bundle.main.path(forResource: "banner", ofType:"txt"),
        let bannerText = try? String(contentsOf: URL(fileURLWithPath: bannerPath)) {
        
        let logDetail = LogDetails(level: .verbose, date: Date(), message: "", functionName: "", fileName: "", lineNumber: 0)
        consoleDestination.output(logDetails: logDetail, message: bannerText + "\n\n")
    }
    
    // Log basic info in the top of the logfile
    log.logAppDetails()
    
    // Create a file log destination
    log.setupFileLogger()
	
	return log
}()

public let LogRequest: XCGLogger = {
	
	// Create a logger object with no destinations
	let log = XCGLogger(identifier: "requestLogger", includeDefaultDestinations: false)
	
	// No logger in production
	guard Environment.server != .production else { return log }
	
	//    log.xcodeColorsEnabled = true
	//    let backgroundColor = (20, 50, 80)
	//    log.xcodeColors = [
	//        .Verbose: XCGLogger.XcodeColor(fg: (211, 211, 211), bg: backgroundColor),
	//        .Debug: XCGLogger.XcodeColor(fg: (169, 169, 169), bg: backgroundColor),
	//        .Info: XCGLogger.XcodeColor(fg: (0, 128, 0), bg: backgroundColor),
	//        .Warning: XCGLogger.XcodeColor(fg: (255, 165, 0), bg: backgroundColor),
	//        .Error: XCGLogger.XcodeColor(fg: (255, 0, 0), bg: backgroundColor),
	//        .Severe: XCGLogger.XcodeColor(fg:(128, 0, 0), bg: backgroundColor) // Optionally use RGB values directly
	//    ]
	
	let logFormatter = DateFormatter()
	logFormatter.dateFormat = "HH:mm:ss.SSS"
	log.dateFormatter = logFormatter
	
	// Create a destination for the system console log
	_ = log.setupConsoleLogger()
	
	// Create a file log destination
	log.setupFileLogger(.none, identifier:"requestLogger.fileLogDestination")
	
	return log
}()

extension XCGLogger {
	
	fileprivate func setupConsoleLogger(_ logLevel: Level = .verbose, identifier: String = "logger.systemLogDestination") -> ConsoleDestination {
		
		let systemLogDestination = ConsoleDestination(owner: self, identifier: identifier)
		
		systemLogDestination.outputLevel = logLevel
		systemLogDestination.showLogIdentifier = false
		systemLogDestination.showFunctionName = false
		systemLogDestination.showThreadName = false
		systemLogDestination.showLevel = true
		systemLogDestination.showFileName = true
		systemLogDestination.showLineNumber = true
		systemLogDestination.showDate = false
		
		// Add the destination to the logger
        self.add(destination : systemLogDestination)
        
        return systemLogDestination
	}
	
	fileprivate func setupFileLogger(_ logLevel: Level = .verbose, identifier: String = "logger.fileLogDestination") {
		
		let fileFormatter = DateFormatter()
		fileFormatter.dateFormat = "dd.MM.yy-HH.mm"
		let logfilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] +
			"/" + identifier + "_" + fileFormatter.string(from: NSDate() as Date) + ".log"
		
		let fileLogDestination = FileDestination(owner: self, writeToFile: logfilePath, identifier: identifier)
		
		fileLogDestination.outputLevel = logLevel
		fileLogDestination.showLogIdentifier = false
		fileLogDestination.showFunctionName = true
		fileLogDestination.showThreadName = false
		fileLogDestination.showLevel = true
		fileLogDestination.showFileName = true
		fileLogDestination.showLineNumber = true
		fileLogDestination.showDate = true
		
		let ansiColorLogFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
		ansiColorLogFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
		ansiColorLogFormatter.colorize(level: .debug, with: .white)
		ansiColorLogFormatter.colorize(level: .info, with: .blue, options: [.underline])
		ansiColorLogFormatter.colorize(level: .warning, with: .red, options: [.faint])
		ansiColorLogFormatter.colorize(level: .error, with: .red, options: [.bold])
		ansiColorLogFormatter.colorize(level: .severe, with: .white, on: .red)
		fileLogDestination.formatters = [ansiColorLogFormatter]
		
		// Process this destination in the background
		fileLogDestination.logQueue = XCGLogger.logQueue
		
		// Add the destination to the logger
		self.add(destination : fileLogDestination)
		
		// Log basic info in the top of the logfile
		let logDetail = LogDetails(level: .verbose, date: Date(), message: "", functionName: "", fileName: "", lineNumber: 0)
		
		let bannerPath = Bundle.main.path(forResource: "banner", ofType:"txt")
		
		if let bannerPath = bannerPath {
			
			if let bannerText = try? String(contentsOf: URL(fileURLWithPath: bannerPath)) {
				
				fileLogDestination.output(logDetails: logDetail, message: bannerText + "\n\n")
			}
		}
		fileLogDestination.output(logDetails: logDetail, message: UIApplication.shared.userAgent + "\n")
	}
}
