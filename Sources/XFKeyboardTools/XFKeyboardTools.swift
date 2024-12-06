import SwiftUI

/// 定义工具栏类型
public enum KeyboardToolType {
    case done      // 关闭键盘
    case network   // 网络相关快捷工具
    case email     // 邮件相关快捷工具
    case custom    // 自定义工具栏
}

@available(iOS 15.0, *)
public extension TextField {
    
    /// - Parameters: 根据工具栏类型添加工具栏修饰符，支持自定义工具栏
    ///   - type: 工具栏类型
    ///   - text: 文本内容
    ///   - customView: 自定义View
    /// - Returns: some View
    @MainActor func keyboardToolType<CustomView: View>(
        type: KeyboardToolType,  // 外部控制工具栏类型
        text: Binding<String>,
        @ViewBuilder customView: @escaping () -> CustomView = { EmptyView() } // 可选的自定义视图
    ) -> some View {
        modifier(
            KeyboardToolModifier(
                type: type,
                text: text,
                customView: customView
            )
        )
    }
    
    @MainActor func keyboardToolDone<CustomView: View>(
        @ViewBuilder customView: @escaping () -> CustomView = { EmptyView() } // 可选的自定义视图
    ) -> some View {
        modifier(
            KeyboardToolModifier(
                type: .done,
                text: .constant(""),
                customView: customView
            )
        )
    }
}

@available(iOS 15.0, *)
public extension TextEditor {
    /// - Parameters: 根据工具栏类型添加工具栏修饰符，支持自定义工具栏
    ///   - type: 工具栏类型
    ///   - text: 文本内容
    ///   - customView: 自定义View
    /// - Returns: some View
    @MainActor func keyboardToolType<CustomView: View>(
        type: KeyboardToolType,  // 外部控制工具栏类型
        text: Binding<String>,
        @ViewBuilder customView: @escaping () -> CustomView = { EmptyView() } // 可选的自定义视图
    ) -> some View {
        modifier(
            KeyboardToolModifier(
                type: type,
                text: text,
                customView: customView
            )
        )
    }
    
    @MainActor func keyboardToolDone<CustomView: View>(
        @ViewBuilder customView: @escaping () -> CustomView = { EmptyView() } // 可选的自定义视图
    ) -> some View {
        modifier(
            KeyboardToolModifier(
                type: .done,
                text: .constant(""),
                customView: customView
            )
        )
    }
}

@available(iOS 15.0, *)
public extension SecureField {
    /// - Parameters: 根据工具栏类型添加工具栏修饰符，支持自定义工具栏
    ///   - type: 工具栏类型
    ///   - text: 文本内容
    ///   - customView: 自定义View
    /// - Returns: some View
    @MainActor func keyboardToolType<CustomView: View>(
        type: KeyboardToolType,  // 外部控制工具栏类型
        text: Binding<String>,
        @ViewBuilder customView: @escaping () -> CustomView = { EmptyView() } // 可选的自定义视图
    ) -> some View {
        modifier(
            KeyboardToolModifier(
                type: type,
                text: text,
                customView: customView
            )
        )
    }
    
    
    @MainActor func keyboardToolDone<CustomView: View>(
        @ViewBuilder customView: @escaping () -> CustomView = { EmptyView() } // 可选的自定义视图
    ) -> some View {
        modifier(
            KeyboardToolModifier(
                type: .done,
                text: .constant(""),
                customView: customView
            )
        )
    }
}





/// 工具栏修饰符
@available(iOS 15.0, *)
struct KeyboardToolModifier<CustomView: View>: ViewModifier {
    @FocusState private var isEditing: Bool
    var type: KeyboardToolType      // 动态工具栏类型
    let text: Binding<String>
    let customView: () -> CustomView
    
    func body(content: Content) -> some View {
        content
            .focused($isEditing)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isEditing{
                        HStack{
                            ScrollView(.horizontal, showsIndicators: false) {
                                createView()
                            }
                            
                            
                            Button(action: hideKeyboard) {
                                Image(systemName: "chevron.down") // 关闭键盘按钮
                                    .foregroundColor(Color(.label))
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(
                                        Color(.systemGroupedBackground)
                                    )
                            )
                            .layoutPriority(1)
                        }
                    }
                }
            }
    }

    /// 根据工具栏类型创建按钮
    
    private func createView() -> some View {
        let items: [String]
        switch type {
        case .network:
            items = ["http://", "https://", "www.", ".com", ".cn",".net",".org",".live"]
        case .email:
            items = [".com","@qq.com", "@163.com", "@gmail.com", "@yahoo.com", "@outlook.com"]
        case .done, .custom:
            items = []
        }

        return HStack(spacing: 16) {
            if type == .custom{
                if CustomView.self == EmptyView.self {
                    EmptyView().frame(width:10)
                } else {
                    customView() // 显示自定义视图
                }
            } else {
                ForEach(items, id: \.self) { item in
                    Button(item) {
                        text.wrappedValue.append(item) // 更新绑定值
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(8)
                }
            }
        }
        
    }

    /// 隐藏键盘
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


/// 工具栏修饰符
//@available(iOS 15.0, *)
//struct ViewKeyboardToolModifier: ViewModifier {
//    
//    @StateObject private var keyboard = KeyboardResponder()
//
//    func body(content: Content) -> some View {
//        content
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button(action: hideKeyboard) {
//                        Image(systemName: "chevron.down") // 关闭键盘按钮
//                            .foregroundColor(Color(.label))
//                    }
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .foregroundStyle(
//                                Color(.systemGroupedBackground)
//                            )
//                    )
//                }
//            }
//            .onChange(of: keyboard.keyboardHeight) { value in
//                if value > 0 {
//                    debugPrint("键盘出现")
//                }else{
//                    debugPrint("键盘消失")
//                }
//            }
//    }
//    /// 隐藏键盘
//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}


//import SwiftUI
//import Combine
//
///// 键盘监听管理器
//@available(iOS 13.0, *)
//class KeyboardResponder: ObservableObject {
//    @Published var keyboardHeight: CGFloat = 0
//    private var cancellable: AnyCancellable?
//
//    init() {
//        // 订阅键盘显示和隐藏的通知
//        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//
//        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
//            .sink { [weak self] notification in
//                self?.keyboardHeight = notification.name == UIResponder.keyboardWillShowNotification
//                    ? (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
//                    : 0
//            }
//    }
//
//    deinit {
//        cancellable?.cancel()
//    }
//}


// 这是一个键盘工具栏,我要的效果是在输入框添加工具栏,编辑的时候显示工具栏,编辑结束工具栏消失,同时可以在View上设置一个默认工具栏,当输入框显示工具栏时,view的工具栏隐藏掉
