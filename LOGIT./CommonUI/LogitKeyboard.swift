//
//  LogitKeyboard.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 20.02.23.
//

import SwiftUI

struct LogitKeyboard<Content: View>: View {
    
    let content: Content
    
    @Binding var text: String
    @State var isShowingKeyboard: Bool = true
    
    var body: some View {
        ZStack {
            content
            if isShowingKeyboard {
                VStack(spacing: 0) {
                    Spacer()
                    Divider()
                    HStack {
                        Key(content: Image(systemName: "doc.on.doc"), onTap: {  })
                        Key(content: Image(systemName: "arrow.left.circle"), onTap: {  })
                        Key(content: Image(systemName: "arrow.right.circle"), onTap: {  })
                        Key(content: Image(systemName: "checkmark.circle"), onTap: {  })
                    }
                    .background(.thinMaterial)
                    Divider()
                    VStack {
                        HStack {
                            Key(content: Text("1"), onTap: { text.append("1") })
                            Key(content: Text("2"), onTap: { text.append("2") })
                            Key(content: Text("3"), onTap: { text.append("3") })
                        }
                        HStack {
                            Key(content: Text("4"), onTap: { text.append("4") })
                            Key(content: Text("5"), onTap: { text.append("5") })
                            Key(content: Text("6"), onTap: { text.append("6") })
                        }
                        HStack {
                            Key(content: Text("7"), onTap: { text.append("7") })
                            Key(content: Text("8"), onTap: { text.append("8") })
                            Key(content: Text("9"), onTap: { text.append("9") })
                        }
                        HStack {
                            Key(content: Image(systemName: "keyboard.chevron.compact.down"), onTap: { isShowingKeyboard = false })
                            Key(content: Text("0"), onTap: { text.append("2") })
                            Key(content: Image(systemName: "delete.backward"), onTap: { text.removeLast() })
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(.thickMaterial)
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    struct Key<Content: View>: View {
        let content: Content
        let onTap: () -> Void
        
        var body: some View {
            Button {
                onTap()
            } label: {
                content
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(height: 80)
                    .frame(maxWidth: 100)
                    .contentShape(Rectangle())
            }
        }
    }
    
}



private struct LogitKeyboardPreviewContainer: View {
    
    @State private var text: String = ""
    
    var body: some View {
        LogitKeyboard(content: Text(text), text: $text)
    }
}

struct LogitKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        LogitKeyboardPreviewContainer()
    }
}
