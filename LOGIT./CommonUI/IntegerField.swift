//
//  CustomTextField.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.01.23.
//

import SwiftUI

struct IntegerField: View {
    
    // MARK: - Parameters
    
    let placeholder: Int64
    let value: Int64
    let setValue: (_ newValue: Int64) -> Void
    let maxDigits: Int?
    @State var index: Index
    @Binding var focusedIntegerFieldIndex: Index?
    
    // MARK: - State
    
    @FocusState private var isFocused: Bool

    // MARK: - Body
    
    var body: some View {
        TextField(String(placeholder), text: valueAsStringBinding)
            .focused($isFocused)
            .keyboardType(.numberPad)
            .font(.system(.body, design: .rounded, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(10)
            .background(
                ZStack {
                    Color.background
                    Color.fill
                }
            )
            .cornerRadius(5)
            .onChange(of: focusedIntegerFieldIndex) { newValue in
                isFocused = newValue == index
            }
            .onChange(of: isFocused) { newValue in
                if newValue {
                    focusedIntegerFieldIndex = index
                }
            }
    }
    
    // MARK: - Computed Properties
    
    var valueAsStringBinding: Binding<String> {
        Binding<String>(
            get: { value == 0 ? "" : String(String(value).prefix(maxDigits ?? .max)) },
            set: {
                if let integerValue = Int64($0.prefix(maxDigits ?? .max)) {
                    setValue(integerValue)
                } else if $0 == "" {
                    setValue(0)
                }
            }
        )
    }
    
    struct Index: Equatable {
        let primary: Int
        var secondary: Int = 0
        var tertiary: Int = 0
        
        static func ==(lhs: Index, rhs: Index) -> Bool {
            lhs.primary == rhs.primary && lhs.secondary == rhs.secondary && lhs.tertiary == rhs.tertiary
        }
        
    }
    
}


struct IntegerField_Previews: PreviewProvider {
    static var previews: some View {
        IntegerField(
            placeholder: 0,
            value: 12,
            setValue: { _ in },
            maxDigits: 4,
            index: .init(primary: 0),
            focusedIntegerFieldIndex: .constant(.init(primary: 0))
        )
    }
}
