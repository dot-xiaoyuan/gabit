# 习惯追踪 App

一个基于SwiftUI开发的个人习惯追踪应用，支持每日打卡、复盘记录和AI建议功能。

## 功能特性

- ✅ 习惯管理（创建、编辑、删除）
- ✅ 每日打卡（完成/跳过/未填）
- ✅ 每日复盘记录
- ✅ AI建议生成（Mock数据）
- ✅ 历史记录查看
- ✅ 周总结统计

## 技术栈

- **SwiftUI** - 用户界面框架
- **Core Data** - 本地数据持久化
- **Swift 5.9+** - 编程语言
- **iOS 16.0+** - 最低支持版本

## 项目结构

```
HabitApp/
├── Models/              # 数据模型
├── ViewModels/          # 视图模型
├── Views/               # 视图组件
│   └── Components/      # 可复用组件
├── Services/            # 服务层
├── Utils/               # 工具类
└── Assets.xcassets/     # 资源文件
```

## 开发环境要求

- macOS 13.0+
- Xcode 15.0+
- iOS 16.0+ 设备或模拟器

## 安装和运行

1. **安装Xcode**
   ```bash
   # 从App Store安装Xcode，或使用命令行工具
   xcode-select --install
   ```

2. **打开项目**
   ```bash
   # 在Xcode中打开项目
   open HabitApp.xcodeproj
   ```

3. **配置开发者账号**
   - 在Xcode中登录你的Apple ID
   - 设置Bundle Identifier（建议改为你的唯一标识符）

4. **运行项目**
   - 选择目标设备（模拟器或真机）
   - 点击运行按钮或按 `Cmd + R`

## 开发阶段

### 第一阶段：项目搭建 ✅
- [x] 创建SwiftUI项目结构
- [x] 搭建TabView导航
- [x] 实现静态UI界面

### 第二阶段：Core Data集成
- [ ] 设计数据模型
- [ ] 实现习惯管理
- [ ] 添加打卡功能

### 第三阶段：AI服务集成
- [ ] 创建Mock AI服务
- [ ] 实现复盘功能
- [ ] 添加每日建议

### 第四阶段：完善功能
- [ ] 历史记录查看
- [ ] 周总结统计
- [ ] UI优化和动画

## 学习资源

- [Apple SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
- [Hacking with SwiftUI](https://www.hackingwithswift.com/quick-start/swiftui)
- [Stanford CS193p](https://cs193p.stanford.edu/)

## 注意事项

1. **Bundle Identifier**: 请将项目中的 `com.yourname.HabitApp` 改为你的唯一标识符
2. **开发者账号**: 真机测试需要付费开发者账号
3. **模拟器**: 可以使用免费的iOS模拟器进行开发测试

## 下一步

完成第一阶段后，可以开始第二阶段的Core Data集成开发。
