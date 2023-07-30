//
//  CustomTextField.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 16.01.23.
//

import SwiftUI

struct IntegerField: View {
    
    // MARK: - Environment
    
    @Environment(\.canEdit) var canEdit: Bool
    
    // MARK: - Parameters
    
    let placeholder: Int64
    let value: Int64
    let setValue: (_ newValue: Int64) -> Void
    let maxDigits: Int?
    let index: Index
    @Binding var focusedIntegerFieldIndex: Index?
    var unit: String? = "kg"
    
    // MARK: - State
    
    @FocusState private var isFocused: Bool

    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Group {
                if canEdit {
                    TextField(String(placeholder), text: valueAsStringBinding)
                        .focused($isFocused)
                        .foregroundColor(value == 0 ? .placeholder : .primary)
                        .keyboardType(.numberPad)
                } else {
                    Text(String(value))
                        .foregroundColor(value == 0 ? .placeholder : .primary)
                }
            }
            .font(.system(.title3, design: .rounded, weight: .bold))
            .multilineTextAlignment(.center)
            .fixedSize()
            .onChange(of: focusedIntegerFieldIndex) { newValue in
                guard isFocused != (newValue == index) else { return }
                isFocused = newValue == index
            }
            .onChange(of: isFocused) { newValue in
                guard newValue != (focusedIntegerFieldIndex == index) else { return }
                focusedIntegerFieldIndex = index
            }
            Text(unit?.uppercased() ?? "")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundColor(value == 0 ? .placeholder : .primary)
        }
        .onTapGesture {
            isFocused = true
        }
        .frame(minWidth: 100, alignment: .trailing)
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
        .padding(CELL_PADDING)
        .secondaryTileStyle()
    }
}
