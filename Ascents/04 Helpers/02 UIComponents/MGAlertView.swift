//
//  MGAlertView.swift
//  Ascents
//
//  Created by Theophile on 22.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import UIKit


/// MGAlerView is the main interface to handle the display of popup messages
struct MGAlertView {
    
    /// A structure that hold the options to display a popup with a textfield. Posesses a validation button and a cancel button
    struct TextFieldOptions {
        /// The placeholder in the textfiled
        var placeholder: String
        /// Boolean to indicate if the textfield should display as a secure text entry. Default false
        var isSecure: Bool
        /// The title of the button that confirm the submision
        var validationButtonTitle: String
        /// An optional closure that takes the input text as input and returns a Bool to enable/disable the validation button
        var validationTextRule: ((String) -> Bool)?
        /// An closure that will be called when the validation button is pressed. Has the textfield text as input
        var buttonAction: ((String) -> Void)
        /// An optional closure that will be called if the user press the cancel button
        var cancelAction: (() -> Void)?
        
        /// Create a fully initialize TextFieldOptions
        ///
        /// - Parameters:
        ///   - placeholder: The placeholder in the textfiled
        ///   - validationButtonTitle: The title of the button that confirm the submision
        ///   - validationTextRule: An optional closure that takes the input text as input and returns a Bool to enable/disable the validation button
        ///   - buttonAction: An closure that will be called when the validation button is pressed. Has the textfield text as input
        ///   - cancelAction: An optional closure that will be called if the user press the cancel button
        init(placeholder: String, isSecure: Bool = false, validationButtonTitle: String = "ok", validationTextRule: ((String) -> Bool)? = nil,
             buttonAction: @escaping ((String) -> Void), cancelAction: (() -> Void)? = nil) {
            self.placeholder = placeholder
            self.isSecure = isSecure
            self.validationButtonTitle = validationButtonTitle
            self.validationTextRule = validationTextRule
            self.buttonAction = buttonAction
            self.cancelAction = cancelAction
        }
    }
    
    /// A structure that holds the required information to create a button in the popup
    struct Button {
        /// The button title
        var title: String
        /// An optional closure that will be called when the user presses the button
        var action : (() -> Void)?
        
        
        /// Create a fully initialize Button
        ///
        /// - Parameter title: The button title
        init(_ title: String) {
            self.title = title
        }
        
        ///  Create a fully initialize Button
        ///
        /// - Parameters:
        ///   - title: The button title
        ///   - action: An optional closure that will be called when the user presses the button
        init(_ title: String, action : @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }
    
    
    /// Display a popup with a chosen message and a single OK Button
    ///
    /// - Parameters:
    ///   - message: An AppMessage object that hold the message to display
    ///   - completion: An optional closure completion containing the action to execute when the user press the button
    static func show(_ message: AppMessage, completion:(() -> Void)? = nil) {
        
        let alert = UIAlertController(title: message.info.title, message: message.info.description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .destructive) { _ in completion?() }
        alert.addAction(okAction)
        
        UIApplication.topViewController()?.present(alert, animated: true)
    }
    
    
    /// Display a popup with a chosen message and a chosen amount of buttons.
    ///
    /// - Parameters:
    ///   - message: An AppMessage object that hold the message to display
    ///   - buttons: An array of Button to display. The first button in the array will have the bold title
    static func show(_ message: AppMessage, buttons: [Button]) {
        
        let alert = UIAlertController(title: message.info.title, message: message.info.description, preferredStyle: .alert)
        
        let firstAction = UIAlertAction(title: buttons[0].title, style: .destructive) { _ in buttons[0].action?() }
        alert.addAction(firstAction)
        
        buttons[1..<buttons.count].forEach { button in
            let action = UIAlertAction(title: button.title, style: .cancel) { _ in button.action?() }
            alert.addAction(action)
        }
        
        UIApplication.topViewController()?.present(alert, animated: true)
    }
    
    
    /// Display a popup with a chosen message and containing a textfield.
    ///
    /// - Parameters:
    ///   - message: An AppMessage object that hold the message to display
    ///   - textFieldInfo: A TextFieldOptions object to parameter the popup
    static func show(_ message: AppMessage, with options: TextFieldOptions) {
        
        let alert = UIAlertController(title: message.info.title,
                                      message: message.info.description,
                                      preferredStyle: .alert)
        
        let validationAlertAction = UIAlertAction(title: options.validationButtonTitle, style: .default) { _ in
            options.buttonAction(alert.textFields?.first?.text ?? "")
        }
        validationAlertAction.isEnabled = false
        
        alert.addTextField { (textField) in
            textField.placeholder = options.placeholder
            textField.isSecureTextEntry = options.isSecure
            textField.addAction(for: .editingChanged) {
                validationAlertAction.isEnabled = options.validationTextRule?(textField.text ?? "") ?? true
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            options.cancelAction?()
        })
        alert.addAction(validationAlertAction)
        
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
