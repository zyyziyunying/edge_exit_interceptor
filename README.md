# edge_exit_interceptor

内部维护的 Flutter package，用来解决一个明确问题：
在需要业务拦截的页面上，用自定义左缘手势和反馈动画替代 iOS 风格的路由侧滑返回。

## Status

当前仓库已完成基础搭建，现阶段提供：

- 独立 package 边界
- 最小公开 API 骨架
- 包内自维护文档

手势特效本身还没有开始实现。

## 目标

这个包面向少量特殊页面。它们的共同点是：
页面退出前必须先执行业务逻辑，不能依赖 Flutter 在 iOS 上的默认侧滑返回能力。

目标交互是：

1. 用户从左缘开始滑动。
2. 页面给出一个短距离、明显非原生返回的反馈动画。
3. 松手后触发业务拦截逻辑。
4. 只有业务逻辑明确放行后，页面才真正退出。

## 当前 API 骨架

```dart
EdgeExitInterceptor(
  onTrigger: (details) async {
    // Show dialog or run save logic here.
  },
  child: const Placeholder(),
)
```

当前 `EdgeExitInterceptor` 还是一个 pass-through 壳子，目的是先把后续实现边界和调用方式固定下来，避免过早把实验代码混进业务工程。

## 文档

- [Docs index](docs/README.md)
- [MVP scope](docs/problem/mvp_scope.md)
- [Why iOS `PopScope` is not enough](docs/knowledge/ios_popscope_limitations.md)

## 约束

- 这是内部仓库，不以 pub.dev 发布为目标。
- 文档跟着包一起维护，设计决策优先落在 `docs/` 里。
- 这个包不追求复刻 iOS 原生返回动画，而是追求“业务可控且反馈明确”。

## 下一步实现范围

- 左缘拖拽识别
- 小范围黏性反馈动画
- 阈值与速度触发规则
- 统一的业务拦截回调
- 页面级 opt-in，不影响普通路由
