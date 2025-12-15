```markdown
## 9）明天在公司要做的具体开发任务（Next Day Plan）

> 目标：保证当前 MVP 流程「能稳定跑起来」并开始补齐核心闭环功能，而不是继续在工程配置里打转。

### 9.1 构建 & 稳定性检查
- **9.1.1 在公司机器上重新打开 Xcode 工程**
  - 确认能正常打开 `HabitApp.xcodeproj`，无 “project is damaged” 报错。
- **9.1.2 在模拟器上运行一次（Command + R）**
  - 设备建议：`iPhone 15` 或任意 iPhone 模拟器。
  - 记录所有新的 **编译错误 / 运行时崩溃**，后续逐条修。

### 9.2 「今日」页面功能自测（Today Tab）
- **9.2.1 习惯列表**
  - 在「今日」页点击右上角「添加」：
    - 能成功弹出 `AddHabitView`。
    - 输入标题后点击保存，列表出现新习惯。
  - 连续添加 3 个习惯，验证：
    - 超过 3 个时，是否正确触发免费版限制文案（`Constants.freeUserHabitLimit`）。

- **9.2.2 打卡交互**
  - 在 `TodayView` 中，对每个习惯：
    - 使用 `HabitCardView` 的 完成 / 跳过 / 重置 按钮。
    - 观察 `HabitViewModel.getTodayStatus(for:)` 返回是否正确变化。
    - 重启 App 后，状态是否能通过 Core Data 持久化。

- **9.2.3 今日复盘**
  - 在「今日复盘」输入框中输入一句话：
    - 点击「保存复盘」，检查：
      - `DailyViewModel.saveReview()` 是否被调用。
      - 重新进入 App 后，`reviewText` 是否能正确回显。

- **9.2.4 模拟 AI 建议**
  - 点击「获取建议」按钮：
    - 确认 `DailyViewModel.generateAISuggestion(for:)` 被触发。
    - 加载期间显示 `ProgressView` + “正在生成建议…”。
    - 1 秒后展示模拟建议文案，并写入 Core Data（`Review.aiSuggestion`）。

### 9.3 Core Data 数据校验
- **9.3.1 核对数据模型和实体代码**
  - 对照文档里的数据结构，确认 Core Data 模型 `HabitApp.xcdatamodeld` 中：
    - `Habit`: `id: UUID`, `title: String?`, `goalType: String`, `createdAt: Date`
    - `DailyRecord`: `id: UUID`, `date: Date`, `status: Int16`, `note: String?`, 及与 `Habit` 的关系
    - `Review`: `date: Date`, `text: String?`, `aiSuggestion: String?`
  - 确认 `CoreDataManager` 中的 CRUD 方法（`createHabit`、`createOrUpdateDailyRecord`、`createOrUpdateReview` 等）与模型字段一一对应。

- **9.3.2 持久化行为检查**
  - 测试流程：
    - 启动 App → 创建 1~2 个习惯 → 打卡 → 填写复盘 → 获取 AI 建议。
    - 直接杀掉 App（停止调试）→ 重新运行：
      - 习惯列表是否还在。
      - 今日状态是否仍然正确。
      - 今日复盘与 AI 建议是否能回显。

### 9.4 代码层面小整理（可选，若还有时间）
- **9.4.1 去掉暂时不用的预览代码或标记 TODO**
  - 检查各个 `#Preview` 块：
    - 确认是否都能正常编译。
    - 如与 Core Data 相关的预览较难跑通，可以先用注释标记 `// TODO: 修复预览环境的 Core Data 注入`。

- **9.4.2 补充必要注释**
  - 在以下位置补简短注释（方便之后继续开发）：
    - `HabitViewModel` 中：习惯上限逻辑、完成率计算逻辑。
    - `DailyViewModel` 中：AI 建议模拟逻辑（后续要替换成 OpenAI 调用）。
    - `CoreDataManager` 中：每个公开方法的用途。

### 9.5 为后天做准备（提前想好）
如果上述流程都跑通了，下一步的优先方向是：
- **优先 A：把 AI 建议从“模拟”换成真实 OpenAI API 调用。**
- **优先 B：把「历史」页从占位改成真实历史记录 + 简单统计。**

可以在公司时根据当天精力，在 A / B 之间二选一作为下一个冲刺目标。
```


