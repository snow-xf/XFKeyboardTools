import SwiftUI

/// 键盘工具栏的类型
public enum KeyboardToolType {
    case network
    case email
    case done
    case custom
}

/// 单例管理键盘工具栏（用于全局功能，但不强制使用）
class KeyboardToolManager {
    @MainActor public static let shared = KeyboardToolManager()

    private init() {}

    /// 获取工具栏按钮项
    func getItems(for type: KeyboardToolType) -> [String] {
        switch type {
        case .network:
            return ["http://", "https://", "www.", ".com", ".cn", ".net", ".org", ".live"]
        case .email:
            return [".com", "@qq.com", "@163.com", "@gmail.com", "@yahoo.com", "@outlook.com"]
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

    var body: some View {
        HStack {
            // 滚动显示工具栏项
            ScrollView(.horizontal, showsIndicators: false) {
                createView()
                    .padding(.horizontal, 8) // 避免布局溢出
            }
            .frame(minHeight: 44) // 确保工具栏有合理高度

            // 关闭键盘按钮
            Button(action: hideKeyboardAction) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
            }
        }
    }

    /// 根据工具栏类型创建按钮视图
    private func createView() -> some View {
        if type == .custom {
            return AnyView(customView) // 返回自定义视图
        }

        let items = KeyboardToolManager.shared.getItems(for: type)

        // 为非自定义类型生成工具栏按钮
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
}


