# Review Check 2026-04-05

## Scope

仅复核以下 3 条审查结论是否属实，不做实现。

## Result

### 1. README / gesture_contract 已明确说明集成前提，但 example 未体现

- 结论：成立
- 依据文件：
  - `README.md:23`
  - `README.md:24`
  - `README.md:67`
  - `docs/problem/gesture_contract.md:16`
  - `docs/problem/gesture_contract.md:17`
  - `docs/problem/gesture_contract.md:44`
  - `example/lib/main.dart:13`
  - `example/lib/main.dart:46`
- 关键原因：
  - 文档已经明确说明：如果页面仍存在原生或 `Cupertino` 风格返回手势，业务侧必须自行关闭或规避。
  - example 仍然是 `MaterialApp` + `MaterialPageRoute` 的普通示例，没有演示该集成前提，也没有在示例文案中提示这一点。

### 2. `disabled mid-drag` 测试未覆盖“禁用后继续 move”

- 结论：成立
- 依据文件：
  - `test/edge_exit_interceptor_test.dart:179`
  - `test/edge_exit_interceptor_test.dart:206`
  - `test/edge_exit_interceptor_test.dart:211`
  - `test/edge_exit_interceptor_test.dart:232`
  - `test/edge_exit_interceptor_test.dart:241`
- 关键原因：
  - 现有测试只覆盖了：拖动开始后把 `enabled` 切到 `false`，再 `up`，最后验证 `onTrigger` 没有触发。
  - 测试没有在 `enabled` 变为 `false` 后继续执行 `gesture.moveBy(...)`，因此没有证明禁用后继续 move 时交互状态是否还会更新。

### 3. 现有 RTL 测试“只验证 indicator 存在”

- 结论：不成立
- 依据文件：
  - `test/edge_exit_interceptor_test.dart:245`
  - `test/edge_exit_interceptor_test.dart:261`
  - `test/edge_exit_interceptor_test.dart:268`
  - `test/edge_exit_interceptor_test.dart:269`
- 关键原因：
  - 该测试不只验证了 indicator 存在。
  - 它还验证了在 RTL 下，从右侧边缘起手并向左拖动后，`triggerCount == 1`，也就是右侧边缘手势可以触发。
  - 该测试没有充分证明的是 RTL 下的视觉位置、位移方向或镜像表现是否正确；但按“只验证 indicator 存在”这个表述本身，不属实。
