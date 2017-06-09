# Pods Source
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.2'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Pods for Medgate
target 'Ascents' do

    pod 'Localize-Swift'        # Swift friendly localization and i18n with in-app language switching

    pod 'XCGLogger'             # A debug log framework for use in Swift projects.

    pod 'SwiftLint'             # A tool to enforce Swift style and conventions.

    pod 'Alamofire'             # An HTTP networking library written in Swift.
    pod 'ObjectMapper'          # Simple JSON Object mapping written in Swift
    pod 'AlamofireObjectMapper' # An Alamofire extension which converts JSON response data into swift objects using ObjectMapper

    pod 'Realm'                 # Realm is a mobile database that runs directly inside phones, tablets or wearables.

    pod 'KeychainAccess'        # Simple Swift wrapper for Keychain that works on iOS and OS X

    pod 'RandomKit'             # Swift framework that makes random data generation simple and easy.
    pod 'String+Extensions'     # A comprehensive, lightweight string extension for Swift 3

    pod 'IQKeyboardManagerSwift'# Auto scroll up input form when kayboard appear

    pod 'HTTPStatusCodes'       # Swift enum wrapper for easier handling of HTTP status codes.

    pod 'DZNEmptyDataSet'       # Empty data for tableview
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # Removing warning for external libraries
            config.build_settings['WARNING_CFLAGS'] = "-w"
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
