
# KeyboardTool

`KeyboardTool` 是一个适用于 SwiftUI 的键盘工具栏管理组件。它提供了网络输入、邮箱输入、自定义视图以及关闭键盘等功能的工具栏，方便开发者快速集成和扩展键盘工具栏。

---

## 功能特性

- **内置工具栏类型：**
  - 网络地址输入（`.network`）
  - 邮箱输入（`.email`）
  - 完成按钮（`.done`）
- **自定义工具栏视图支持**
- **一键隐藏键盘功能**
- **轻量级的 SwiftUI 扩展**

---

## 安装

1. 将 `KeyboardTool` 文件添加到你的项目中。
2. 确保你的项目使用 **iOS 15.0** 或更高版本。
3. 在需要使用的 SwiftUI 视图中导入 `SwiftUI`。

---

## 使用示例

以下是如何在项目中使用 `KeyboardTool` 的示例。

### 1. 基本用法

#### 使用网络工具栏
```swift
import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    
    var body: some View {
        TextField("输入网络地址", text: $text)
            .keyboardToolNetwork(text: $text)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
```

#### 使用邮箱工具栏
```swift
import SwiftUI

struct EmailView: View {
    @State private var email: String = ""
    
    var body: some View {
        TextField("输入邮箱地址", text: $email)
            .keyboardToolEmail(text: $email)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
```

### 2. 使用完成按钮工具栏
```swift
import SwiftUI

struct DoneView: View {
    @State private var input: String = ""
    
    var body: some View {
        TextField("完成后关闭键盘", text: $input)
            .keyboardToolDone()
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
```

### 3. 使用自定义工具栏视图
```swift
import SwiftUI

struct CustomToolbarView: View {
    @State private var input: String = ""

    var body: some View {
        TextField("输入内容", text: $input)
            .keyboardToolCustom(
                text: $input,
                customView: HStack {
                    Button("添加") {
                        input.append("添加")
                    }
                    Button("清空") {
                        input = ""
                    }
                }
            )
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
```
---


此项目遵循 MIT 许可证。可自由使用、修改和分发。

---

通过以上方式，你可以轻松地在 SwiftUI 项目中集成和使用 `KeyboardTool`，为你的用户提供更佳的输入体验。
