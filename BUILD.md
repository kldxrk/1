# 构建说明（无 Mac）

工程已是完整的 Xcode 工程（VNPlayer.xcodeproj + 共享 scheme），不需要再手动建项目。

## 路线 A：没有付费开发者账号 → 未签名 IPA + Sideloadly
1. 把整个目录推到 Git 仓库（Codemagic 原生支持 GitHub / GitLab / Bitbucket）。
2. Codemagic 添加仓库，选择 `ios-unsigned` 工作流，Start build。
3. 下载 Artifacts 里的 `VNPlayer-unsigned.ipa`。
4. 在电脑上用 Sideloadly 或 AltStore，用你自己的 Apple ID 签名安装到 iPhone（免费账号 7 天过期，需重装）。

## 路线 B：有付费账号 → TestFlight
1. 把 `com.example.vnplayer` 改成你自己的唯一 Bundle ID（codemagic.yaml 和 pbxproj 两处）。
2. 在 Codemagic 配好 App Store Connect API Key 集成，名称与 yaml 中 `app_store_connect:` 一致。
3. 运行 `ios-testflight`。

证书、私钥、API key 只放在 Codemagic 里，不要发给任何人。

## 当前状态
- 这是运行时原型：只有 Demo 场景；PAC / XP3 是占位，尚未实现。
- 横屏已在 Info 设置里锁定（iPhone / iPad 均为左右横屏）。
