# P7-128 - pubspec.yaml（依赖更新）

## 任务信息
- **文件路径**: `pubspec.yaml`
- **文件职责**: 项目依赖配置
- **依赖文件**: 无
- **开发阶段**: P7 - 模型配置

## 任务上下文
添加模型配置模块所需的依赖包。

## 需要新增的依赖

```yaml
dio: ^5.4.0                    # HTTP 客户端（model_repo_service, model_download_service 使用）
llama_cpp_dart: ^0.1.0         # 本地 GGUF 模型推理
flutter_secure_storage: ^9.0.0 # API Key 加密存储
crypto: ^3.0.0                 # SHA256 校验
path_provider: ^2.1.0          # 获取应用文档目录
```

## 操作步骤

1. 在 pubspec.yaml 的 dependencies 下添加上述 5 个依赖
2. 运行 `flutter pub get` 确认依赖解析成功

## 注意事项
- dio 已在 model_download_service.dart 中使用，确认版本一致
- llama_cpp_dart 需要原生编译，已在 Android 环境验证
- path_provider 可能在 device_utils.dart 中已有使用，确认版本兼容
