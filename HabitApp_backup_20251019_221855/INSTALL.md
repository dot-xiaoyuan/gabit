# 安装指南

## 问题解决

如果你遇到路径错误：`One of the paths in DEVELOPMENT_ASSET_PATHS does not exist`

## 解决方案

### 方法1：使用Xcode创建新项目（推荐）

1. **打开Xcode**
2. **创建新项目**：
   - 选择 "Create a new Xcode project"
   - 选择 "iOS" → "App"
   - 填写项目信息：
     - Product Name: `HabitApp`
     - Interface: `SwiftUI`
     - Language: `Swift`
     - Use Core Data: `不勾选`（我们稍后手动添加）
     - Include Tests: `勾选`

3. **替换文件**：
   - 将我创建的所有 `.swift` 文件复制到新项目中
   - 保持文件夹结构不变

### 方法2：修复当前项目

如果你已经安装了Xcode，可以尝试：

1. **在Xcode中打开项目**：
   ```bash
   open HabitApp.xcodeproj
   ```

2. **如果仍有路径错误**：
   - 在Xcode中，选择项目文件（蓝色图标）
   - 在 "Build Settings" 中搜索 "Development Asset Paths"
   - 将路径改为：`Preview Content`

3. **添加文件到项目**：
   - 右键点击项目 → "Add Files to HabitApp"
   - 选择所有 `.swift` 文件
   - 确保 "Add to target" 勾选了 "HabitApp"

## 安装Xcode

如果你还没有安装Xcode：

### 从App Store安装（推荐）
1. 打开App Store
2. 搜索 "Xcode"
3. 点击 "获取" 或 "安装"

### 从Apple Developer网站下载
1. 访问 [developer.apple.com](https://developer.apple.com)
2. 登录你的Apple ID
3. 下载Xcode（需要免费开发者账号）

## 验证安装

安装完成后，在终端运行：
```bash
xcode-select --print-path
```

应该显示类似：`/Applications/Xcode.app/Contents/Developer`

如果不是，运行：
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## 运行项目

1. 打开Xcode
2. 打开 `HabitApp.xcodeproj`
3. 选择iOS模拟器（如iPhone 15）
4. 点击运行按钮（▶️）或按 `Cmd + R`

## 如果仍有问题

请告诉我具体的错误信息，我会帮你解决。
