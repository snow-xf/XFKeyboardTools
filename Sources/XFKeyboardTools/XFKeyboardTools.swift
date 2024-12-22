import SwiftUI

/// 键盘工具栏的类型
public enum KeyboardToolType {
    case network
    case email
    case done
    case custom
    case regex // 支持正则工具栏
}

/// 正则符号类别
public enum RegexSymbolCategory: String, CaseIterable {
    case characterClass = "字符类"
    case anchors = "锚点"
    case quantifiers = "量词"
    case groups = "分组"
    case specials = "特殊符号"

    var symbols: [String] {
        switch self {
        case .characterClass: return ["\\d", "\\w", "\\s", "\\D", "\\W", "\\S", "."]
        case .anchors: return ["^", "$", "\\b", "\\B"]
        case .quantifiers: return ["*", "+", "?", "{n}", "{n,}", "{n,m}"]
        case .groups: return ["()", "[]", "{}", "(?:)", "(?=)", "(?!)"]
        case .specials: return ["|", "\\n", "\\t", "\\\\", "\\(", "\\)"]
        }
    }
}

/// 单例管理键盘工具栏
class KeyboardToolManager {
    @MainActor public static let shared = KeyboardToolManager()

    private init() {}

    /// 获取工具栏按钮项
    func getItems(for type: KeyboardToolType, category: RegexSymbolCategory? = nil) -> [String] {
        switch type {
        case .network:
            return ["http://", "https://", "www.", ".com", ".cn", ".net", ".org", ".dev"]
        case .email:
            return [".com", "@qq.com", "@163.com", "@gmail.com", "@yahoo.com", "@outlook.com"]
        case .regex:
            return category?.symbols ?? []
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
    let hideKeyboardAction: () -> Void

    @State private var selectedCategory: RegexSymbolCategory = .characterClass // 默认类别

    var body: some View {
        VStack(spacing: 6) {
            if type == .regex {
                // 添加类别切换器
                Picker("分类", selection: $selectedCategory) {
                    ForEach(RegexSymbolCategory.allCases, id: \.self) { category in
                        Text(category.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }

            HStack {
                // 滚动显示工具栏项
                ScrollView(.horizontal, showsIndicators: false) {
                    createView()
                        .padding(.horizontal, 8)
                }
                .frame(minHeight: 44)

                // 关闭键盘按钮
                Button(action: hideKeyboardAction) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
            }
        }
    }

    /// 根据工具栏类型创建按钮视图
    private func createView() -> some View {
        if case .custom = type {
            return AnyView(customView)
        }

        let items: [String] = {
            if type == .regex {
                return KeyboardToolManager.shared.getItems(for: type, category: selectedCategory)
            } else {
                return KeyboardToolManager.shared.getItems(for: type)
            }
        }()

        return AnyView(
            HStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        text.wrappedValue.append(item)
                    }) {
                        Text(item)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                    }
                }
            }
        )
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
                            customView: customView,
                            hideKeyboardAction: hideKeyboard
                        )
                    }
                }
            }
    }

    /// 隐藏键盘
    @MainActor private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

@available(iOS 15.0, *)
public extension View {
    /// 为当前视图添加键盘工具栏
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
    
    /// 默认工具栏
    func keyboardToolDone() -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .done,
                text: .constant(""),
                customView: EmptyView()
            )
        )
    }
    
    /// 网络工具栏
    func keyboardToolNetwork(text: Binding<String>) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .network,
                text: text,
                customView: EmptyView()
            )
        )
    }
    
    /// email工具栏
    func keyboardToolEmail(text: Binding<String>) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .email,
                text: text,
                customView: EmptyView()
            )
        )
    }
    
    /// 自定义View工具栏
    func keyboardToolCustom<CustomView: View>(text: Binding<String>, customView: CustomView) -> some View {
        self.modifier(
            KeyboardToolModifier(
                type: .custom,
                text: text,
                customView: customView
            )
        )
    }

    /// 正则工具栏
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
