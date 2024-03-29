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
    @EnvironmentObject var database: Database

    // MARK: - Parameters

    let placeholder: Int64
    @Binding var value: Int64
    let maxDigits: Int?
    let index: Index
    @Binding var focusedIntegerFieldIndex: Index?
    var unit: String? = "kg"

    // MARK: - State

    @State private var valueString: String = ""
    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Group {
                if canEdit {
                    TextField(String(placeholder), text: $valueString)
                        .focused($isFocused)
                        .onChange(of: valueString) { newValue in
                            if newValue.count > 4 {
                                valueString = String(newValue.prefix(4))
                            } else if newValue.isEmpty || Int(newValue) == 0 {
                                valueString = ""
                            }
                        }
                        .keyboardType(.numberPad)
                        .accentColor(.clear)
                } else {
                    Text(valueString)
                        .foregroundColor(isEmpty ? .placeholder : .primary)
                }
            }
            .font(.system(.title3, design: .rounded, weight: .bold))
            .multilineTextAlignment(.center)
            .fixedSize()
            Text(unit?.uppercased() ?? "")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundColor(isEmpty ? .placeholder : .secondary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 2)
                .foregroundStyle(isFocused ? Color.label : Color.clear)
                .frame(height: 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(y: 3)
        }
        .fixedSize()
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            valueString = String(value)
        }
        .onChange(of: focusedIntegerFieldIndex) { newValue in
            guard isFocused != (newValue == index) else { return }
            // Solution, because otherwise moving down wasnt working, since it would first focus on the new field, while the old one was still focused, which caused the focus to get lost.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            guard newValue == index else { return }
            isFocused = true
        }
        .onChange(of: isFocused) { newValue in
            guard newValue != (focusedIntegerFieldIndex == index) else { return }
            focusedIntegerFieldIndex = index
        }
        .onChange(of: valueString) { newValue in
            if let valueInt = Int64(newValue), valueInt != value {
                value = valueInt
            } else if newValue.isEmpty {
                value = 0
            }
        }
        .onChange(of: value) { newValue in
            if String(newValue) != valueString {
                valueString = String(newValue)
            }
        }
        .frame(minWidth: 100, alignment: .trailing)
    }

    // MARK: - Computed Properties
    
    private var isEmpty: Bool {
         Int(valueString) == 0 || valueString.isEmpty
    }

    struct Index: Equatable, Hashable {
        let primary: Int
        var secondary: Int = 0
        var tertiary: Int = 0

        static func == (lhs: Index, rhs: Index) -> Bool {
            lhs.primary == rhs.primary && lhs.secondary == rhs.secondary
                && lhs.tertiary == rhs.tertiary
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(primary)
            hasher.combine(secondary)
            hasher.combine(tertiary)
        }

    }

}

struct IntegerField_Previews: PreviewProvider {
    static var previews: some View {
        IntegerField(
            placeholder: 0,
            value: .constant(12),
            maxDigits: 4,
            index: .init(primary: 0),
            focusedIntegerFieldIndex: .constant(.init(primary: 0))
        )
        .padding(CELL_PADDING)
        .secondaryTileStyle()
        .previewEnvironmentObjects()
    }
}
