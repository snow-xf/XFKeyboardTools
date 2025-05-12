import SwiftUI

/// 正则符号类别和符号数据
public struct RegexSymbol {
    static let allSymbols: [String] = [
        "\\d", "\\D", "\\s", "\\S", "\\w", "\\W", ".", "^", "$", "\\b", "\\B",
        "*", "+", "?", "{", "}", "(", ")", "[", "]",
        ":", "|", "\\"
    ]
}

/// 键盘工具栏的类型
public enum KeyboardToolType {
    case network
    case email
    case done
    case custom
    case regex
}

/// 单例管理键盘工具栏
class KeyboardToolManager {
    @MainActor public static let shared = KeyboardToolManager()
    private init() {}

    func getItems(for type: KeyboardToolType) -> [String] {
        switch type {
        case .network:
            return ["http://", "https://", "www.", ".com", ".cn", ".net", ".org", ".dev"]
        case .email:
            return [".com", "@qq.com", "@163.com", "@gmail.com", "@yahoo.com", "@outlook.com"]
        case .regex:
            return RegexSymbol.allSymbols
        case .done, .custom:
            return []
        }
    }
}

@available(iOS 15.0, *)
struct ToolbarItemsView<CustomView: View>: View {
    let type: KeyboardToolType
    let text: Binding<String>
    let customView: CustomView

    @FocusState private var dummyFocus: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    createView()
                }
                .padding(.horizontal, 8)
            }

            Button(action: {
                dummyFocus = false
                dismiss()
            }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func createView() -> some View {
        if case .custom = type {
            customView
        } else {
            let items = KeyboardToolManager.shared.getItems(for: type)
            HStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        text.wrappedValue.append(item)
                    }) {
                        Text(item)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct KeyboardToolModifier<CustomView: View>: ViewModifier {
    @FocusState private var isEditing: Bool
    let type: KeyboardToolType
    let text: Binding<String>
    let customView: CustomView

    func body(content: Content) -> some View {
        content
            .focused($isEditing)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isEditing {
                        ToolbarItemsView(
                            type: type,
                            text: text,
                            customView: customView
                        )
                    }
                }
            }
    }
}

@available(iOS 15.0, *)
public extension View {
    func keyboardTool<CustomView: View>(
        type: KeyboardToolType,
        text: Binding<String>,
        customView: CustomView = EmptyView()
    ) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: type,
                text: text,
                customView: customView
            )
        )
    }

    func keyboardToolDone() -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .done,
                text: .constant(""),
                customView: EmptyView()
            )
        )
    }

    func keyboardToolNetwork(text: Binding<String>) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .network,
                text: text,
                customView: EmptyView()
            )
        )
    }

    func keyboardToolEmail(text: Binding<String>) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .email,
                text: text,
                customView: EmptyView()
            )
        )
    }

    func keyboardToolCustom<CustomView: View>(text: Binding<String>, customView: CustomView) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .custom,
                text: text,
                customView: customView
            )
        )
    }

    func keyboardToolRegex(text: Binding<String>) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .regex,
                text: text,
                customView: EmptyView()
            )
        )
    }
}
