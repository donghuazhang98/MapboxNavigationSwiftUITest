//
//  SearchBarView.swift
//  MapboxSwiftUIDemo
//
//  Created by Donghua Zhang on 3/25/21.
//  Copyright © 2021 Mapbox. All rights reserved.
//

import SwiftUI
import Mapbox

struct SearchBarViewController: UIViewRepresentable {
    let textField = LeftPaddedTextField(frame: .zero)
    
    func makeUIView(context: UIViewRepresentableContext<SearchBarViewController>) -> UITextField {
        textField.textColor = UIColor.gray
        textField.placeholder = "Where are you going?"
        textField.layer.cornerRadius = 20
        textField.layer.borderColor = UIColor.tertiaryLabel.cgColor
        textField.backgroundColor = UIColor.systemGray6
        textField.borderStyle = .none
        textField.returnKeyType = .done
        
        textField.delegate = context.coordinator
        
        return textField
    }
    
    func updateUIView(_ uiViewController: UITextField, context: UIViewRepresentableContext<SearchBarViewController>)
    {
    }
    
    func makeCoordinator() -> SearchBarViewController.Coordinator {
        Coordinator(self)
    }

    
    final class Coordinator: NSObject, UITextFieldDelegate {
        var control: SearchBarViewController
        
        init(_ control: SearchBarViewController) {
            self.control = control
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            textField.resignFirstResponder()
            return true
        }
    }
}

// MARK: - CustomUITextField

class LeftPaddedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
}
