# edge_exit_interceptor

内部维护的 Flutter package，用来解决一个明确问题：
在需要业务拦截的页面上，提供一个自定义边缘退出手势和反馈动画。

## Status

当前仓库已经有可运行实现，现阶段提供：

- 独立 package 边界
- 可用的 `EdgeExitInterceptor`
- 基础反馈动画与触发锁
- 包内自维护文档
- 可运行 example

当前版本已经能用于受控页面试用，但交互手感和手势冲突治理还在继续迭代。

## 目标

这个包面向少量特殊页面。它们的共同点是：
页面退出前必须先执行业务逻辑，不能只依赖 Flutter 在 iOS 上的默认侧滑返回能力。

这个包本身只提供 Flutter 层的自定义边缘手势。
如果某个页面还存在原生或 `Cupertino` 风格返回手势，业务侧需要自行关闭或规避那条返回路径。

目标交互是：

1. 用户从 leading edge 开始滑动。
2. 页面给出一个短距离、明显非原生返回的反馈动画。
3. 松手后触发业务拦截逻辑。
4. 只有业务逻辑明确放行后，页面才真正退出。

## 当前 API

```dart
EdgeExitInterceptor(
  onTrigger: (details) async {
    // Show dialog or run save logic here.
  },
  child: const Placeholder(),
)
```

当前 `EdgeExitInterceptor` 已经具备：

- 边缘区域起手
- 小范围反馈动画
- 松手后的回弹
- 阈值 / 速度触发
- `onTrigger` 执行中的防重入锁

组件自身不做路由退出，是否 `pop` 仍由业务侧决定。

## 文档

- [Docs index](docs/README.md)
- [MVP scope](docs/problem/mvp_scope.md)
- [Gesture contract](docs/problem/gesture_contract.md)
- [Implementation plan](docs/problem/implementation_plan.md)
- [Why iOS `PopScope` is not enough](docs/knowledge/ios_popscope_limitations.md)

## 约束

- 这是内部仓库，不以 pub.dev 发布为目标。
- 文档跟着包一起维护，设计决策优先落在 `docs/` 里。
- 这个包不追求复刻 iOS 原生返回动画，而是追求“业务可控且反馈明确”。
- 这个包不会自动接管或禁用原生 / Cupertino 路由返回手势。

## 下一步实现范围

- 黏性反馈和手感调优
- 横向滚动内容的冲突规则
- API 收口
- 更贴近真实业务的 example
