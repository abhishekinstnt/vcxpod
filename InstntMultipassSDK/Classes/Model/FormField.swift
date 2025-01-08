//
//  FormField.swift
//  InstntSDK
//
//  Created by Nate Eckerson on 5/25/21.
//

//import Foundation
//
//struct FormField {
//    enum InputType: String {
//        case planText       = "text"
//        case email          = "email"
//        case select         = "select"
//        case number         = "number"
//        case date           = "date"
//        case checkbox       = "checkbox"
//    }
//    
//    private (set) var id: Int
//    private (set) var inputType: InputType
//    private (set) var name: String
//    private (set) var label: String
//    private (set) var placeholder: String?
//    private (set) var value: String?
//    
//    private (set) var selectableValues: [String]? = nil
//    
//    private (set) var isRequired: Bool
//    private (set) var isImmutable: Bool
//    private (set) var isDroppable: Bool
//    
//    init?(JSON: [String: Any]) {
//        guard let columnJSON = (JSON["columns"] as? [[String: Any]])?.first,
//              let id = columnJSON["fieldId"] as? Int,
//              let fieldJSON = columnJSON["field"] as? [String: Any] else {
//            return nil
//        }
//        
//        guard let inputType = InputType(rawValue: fieldJSON["input_type"] as? String ?? ""),
//              let name = fieldJSON["name"] as? String,
//              let label = fieldJSON["label"] as? String else {
//            return nil
//        }
//        
//        self.id = id
//        self.inputType = inputType
//        self.name = name
//        self.label = label
//        self.placeholder = fieldJSON["place_holder"] as? String
//        if inputType == .select {
//            self.value = nil
//            
//            let components = (fieldJSON["value"] as? String)?.components(separatedBy: ",") ?? []
//            let trimmed: [String] = components.compactMap({
//                let string = $0.trimmingCharacters(in: .whitespacesAndNewlines)
//                return string.count > 0 ? string : nil
//            })
//            self.selectableValues = trimmed.count > 0 ? trimmed : nil
//        } else {
//            self.value = fieldJSON["value"] as? String
//            self.selectableValues = nil
//        }
//        
//        self.isRequired = fieldJSON["required"] as? Bool ?? true
//        self.isImmutable = fieldJSON["is_immutable"] as? Bool ?? true
//        self.isDroppable = columnJSON["droppable"] as? Bool ?? false
//    }
//}
