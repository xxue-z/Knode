import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// AI 对话
  ///
  /// In zh, this message translates to:
  /// **'AI 对话'**
  String get chat_ai_chat;

  /// 回答
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get chat_answer;

  /// 归档
  ///
  /// In zh, this message translates to:
  /// **'归档'**
  String get chat_archive;

  /// 取消
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get chat_cancel;

  /// 对话
  ///
  /// In zh, this message translates to:
  /// **'对话'**
  String get chat_chat;

  /// 引用
  ///
  /// In zh, this message translates to:
  /// **'引用'**
  String get chat_citation;

  /// 清除历史
  ///
  /// In zh, this message translates to:
  /// **'清除历史'**
  String get chat_clear_history;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get chat_confirm;

  /// 已复制
  ///
  /// In zh, this message translates to:
  /// **'已复制'**
  String get chat_copied;

  /// 复制
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get chat_copy;

  /// 删除对话
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get chat_delete_conversation;

  /// 错误
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get chat_error;

  /// 导出对话
  ///
  /// In zh, this message translates to:
  /// **'导出对话'**
  String get chat_export_chat;

  /// 输入消息...
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get chat_input_message;

  /// 意图识别
  ///
  /// In zh, this message translates to:
  /// **'意图识别'**
  String get chat_intent_recognition;

  /// 知识库
  ///
  /// In zh, this message translates to:
  /// **'知识库'**
  String get chat_knowledge_base;

  /// 加载中...
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get chat_loading;

  /// 消息
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get chat_message;

  /// 新建对话
  ///
  /// In zh, this message translates to:
  /// **'新建对话'**
  String get chat_new_conversation;

  /// 暂无对话
  ///
  /// In zh, this message translates to:
  /// **'暂无对话'**
  String get chat_no_conversations_yet;

  /// 问答
  ///
  /// In zh, this message translates to:
  /// **'问答'**
  String get chat_qa;

  /// 问题
  ///
  /// In zh, this message translates to:
  /// **'问题'**
  String get chat_question;

  /// RAG 搜索
  ///
  /// In zh, this message translates to:
  /// **'RAG 搜索'**
  String get chat_rag_search;

  /// 相关文档
  ///
  /// In zh, this message translates to:
  /// **'相关文档'**
  String get chat_related_documents;

  /// 重试
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get chat_retry;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get chat_save;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get chat_search;

  /// 发送
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get chat_send;

  /// 来源
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get chat_sources;

  /// Token 用量
  ///
  /// In zh, this message translates to:
  /// **'Token 用量'**
  String get chat_token_usage;

  /// 答案
  ///
  /// In zh, this message translates to:
  /// **'答案'**
  String get core_answer;

  /// Anthropic API 不支持 Embedding，请使用 OpenAI 兼容接口
  ///
  /// In zh, this message translates to:
  /// **'Anthropic API 不支持 Embedding，请使用 OpenAI 兼容接口'**
  String get core_anthropic_embedding_not_supported;

  /// API 限流，请稍后重试
  ///
  /// In zh, this message translates to:
  /// **'API 限流，请稍后重试'**
  String get core_api_rate_limited;

  /// 返回
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get core_back;

  /// 备份
  ///
  /// In zh, this message translates to:
  /// **'备份'**
  String get core_backup;

  /// 取消
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get core_cancel;

  /// 类目
  ///
  /// In zh, this message translates to:
  /// **'类目'**
  String get core_category;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get core_confirm;

  /// 对话
  ///
  /// In zh, this message translates to:
  /// **'对话'**
  String get core_conversation;

  /// 每日一测
  ///
  /// In zh, this message translates to:
  /// **'每日一测'**
  String get core_daily_quiz;

  /// 删除
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get core_delete;

  /// 文档
  ///
  /// In zh, this message translates to:
  /// **'文档'**
  String get core_document;

  /// 下载失败
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get core_download_failed;

  /// 编辑
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get core_edit;

  /// Embedding 生成失败
  ///
  /// In zh, this message translates to:
  /// **'Embedding 生成失败'**
  String get core_embedding_generation_failed;

  /// 错误
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get core_error;

  /// 考试
  ///
  /// In zh, this message translates to:
  /// **'考试'**
  String get core_exam;

  /// 反馈
  ///
  /// In zh, this message translates to:
  /// **'反馈'**
  String get core_feedback;

  /// 填空题
  ///
  /// In zh, this message translates to:
  /// **'填空题'**
  String get core_fill_in_the_blank;

  /// 评分失败
  ///
  /// In zh, this message translates to:
  /// **'评分失败'**
  String get core_grading_failed;

  /// 评分解析失败
  ///
  /// In zh, this message translates to:
  /// **'评分解析失败'**
  String get core_grading_result_parsing_failed;

  /// API Key 无效
  ///
  /// In zh, this message translates to:
  /// **'API Key 无效'**
  String get core_invalid_api_id;

  /// JSON 解析失败
  ///
  /// In zh, this message translates to:
  /// **'JSON 解析失败'**
  String get core_json_parse_failed;

  /// 知识库
  ///
  /// In zh, this message translates to:
  /// **'知识库'**
  String get core_knowledge_base;

  /// 加载中...
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get core_loading;

  /// 加载失败
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get core_loading_failed;

  /// 本地导入
  ///
  /// In zh, this message translates to:
  /// **'本地导入'**
  String get core_local_import;

  /// 本地模型加载失败
  ///
  /// In zh, this message translates to:
  /// **'本地模型加载失败'**
  String get core_local_model_loading_failed;

  /// 本地模型未加载，请先调用 loadModel()
  ///
  /// In zh, this message translates to:
  /// **'本地模型未加载，请先调用 loadModel()'**
  String get core_local_model_not_loaded;

  /// 消息
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get core_message;

  /// 多选题
  ///
  /// In zh, this message translates to:
  /// **'多选题'**
  String get core_multiple_choice;

  /// 网络请求失败
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败'**
  String get core_network_request_failed;

  /// 新建
  ///
  /// In zh, this message translates to:
  /// **'新建'**
  String get core_new;

  /// 否
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get core_no;

  /// 确定
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get core_ok;

  /// 请在 main.dart 中覆盖
  ///
  /// In zh, this message translates to:
  /// **'请在 main.dart 中覆盖'**
  String get core_please_override_in_main_dart;

  /// 个人中心
  ///
  /// In zh, this message translates to:
  /// **'个人中心'**
  String get core_profile;

  /// 题目
  ///
  /// In zh, this message translates to:
  /// **'题目'**
  String get core_question;

  /// 测验
  ///
  /// In zh, this message translates to:
  /// **'测验'**
  String get core_quiz;

  /// 阅读
  ///
  /// In zh, this message translates to:
  /// **'阅读'**
  String get core_reading;

  /// 远程同步失败
  ///
  /// In zh, this message translates to:
  /// **'远程同步失败'**
  String get core_remote_sync_failed;

  /// 远程模板格式错误
  ///
  /// In zh, this message translates to:
  /// **'远程模板格式错误'**
  String get core_remote_template_format_error;

  /// 请求失败
  ///
  /// In zh, this message translates to:
  /// **'请求失败'**
  String get core_request_failed;

  /// 恢复
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get core_restore;

  /// 重试
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get core_retry;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get core_save;

  /// 分数
  ///
  /// In zh, this message translates to:
  /// **'分数'**
  String get core_score;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get core_search;

  /// 发送
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get core_send;

  /// 服务暂时不可用，请稍后重试
  ///
  /// In zh, this message translates to:
  /// **'服务暂时不可用，请稍后重试'**
  String get core_service_unavailable;

  /// 设置
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get core_settings;

  /// 简答题
  ///
  /// In zh, this message translates to:
  /// **'简答题'**
  String get core_short_answer;

  /// 单选题
  ///
  /// In zh, this message translates to:
  /// **'单选题'**
  String get core_single_choice;

  /// 统计
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get core_statistics;

  /// 成功
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get core_success;

  /// 点击开始答题
  ///
  /// In zh, this message translates to:
  /// **'点击开始答题'**
  String get core_tap_to_start_answering;

  /// 今日测验已准备好，点击开始答题
  ///
  /// In zh, this message translates to:
  /// **'今日测验已准备好，点击开始答题'**
  String get core_today_quiz_ready;

  /// 判断题
  ///
  /// In zh, this message translates to:
  /// **'判断题'**
  String get core_true_false;

  /// WebDAV 未配置
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 未配置'**
  String get core_webdav_not_configured;

  /// 是
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get core_yes;

  /// 关于
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get knode_app_about;

  /// AI 设置
  ///
  /// In zh, this message translates to:
  /// **'AI 设置'**
  String get knode_app_ai_settings;

  /// 应用外壳
  ///
  /// In zh, this message translates to:
  /// **'应用外壳'**
  String get knode_app_app_shell;

  /// 自动备份
  ///
  /// In zh, this message translates to:
  /// **'自动备份'**
  String get knode_app_auto_backup;

  /// 备份设置
  ///
  /// In zh, this message translates to:
  /// **'备份设置'**
  String get knode_app_backup_settings;

  /// 底部导航
  ///
  /// In zh, this message translates to:
  /// **'底部导航'**
  String get knode_app_bottom_navigation;

  /// 取消
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get knode_app_cancel;

  /// 清除缓存
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get knode_app_clear_cache;

  /// 云配置
  ///
  /// In zh, this message translates to:
  /// **'云配置'**
  String get knode_app_cloud_config;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get knode_app_confirm;

  /// 每日卡片
  ///
  /// In zh, this message translates to:
  /// **'每日卡片'**
  String get knode_app_daily_card;

  /// 深色模式
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get knode_app_dark_mode;

  /// 错误
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get knode_app_error;

  /// 导出数据
  ///
  /// In zh, this message translates to:
  /// **'导出数据'**
  String get knode_app_export_data;

  /// 反馈
  ///
  /// In zh, this message translates to:
  /// **'反馈'**
  String get knode_app_feedback;

  /// 字体大小
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get knode_app_font_size;

  /// 首页
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get knode_app_home;

  /// 导入数据
  ///
  /// In zh, this message translates to:
  /// **'导入数据'**
  String get knode_app_import_data;

  /// 语言
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get knode_app_language;

  /// 许可
  ///
  /// In zh, this message translates to:
  /// **'许可'**
  String get knode_app_license;

  /// 浅色模式
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get knode_app_light_mode;

  /// 加载中...
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get knode_app_loading;

  /// 模型卡片
  ///
  /// In zh, this message translates to:
  /// **'模型卡片'**
  String get knode_app_model_card;

  /// 模型下载
  ///
  /// In zh, this message translates to:
  /// **'模型下载'**
  String get knode_app_model_download;

  /// 通知
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get knode_app_notification;

  /// 个人抽屉
  ///
  /// In zh, this message translates to:
  /// **'个人抽屉'**
  String get knode_app_personal_drawer;

  /// 隐私政策
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get knode_app_privacy_policy;

  /// 个人中心
  ///
  /// In zh, this message translates to:
  /// **'个人中心'**
  String get knode_app_profile;

  /// 快捷卡片
  ///
  /// In zh, this message translates to:
  /// **'快捷卡片'**
  String get knode_app_quick_card;

  /// 评价应用
  ///
  /// In zh, this message translates to:
  /// **'评价应用'**
  String get knode_app_rate_us;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get knode_app_save;

  /// 成绩卡片
  ///
  /// In zh, this message translates to:
  /// **'成绩卡片'**
  String get knode_app_score_card;

  /// 服务设置
  ///
  /// In zh, this message translates to:
  /// **'服务设置'**
  String get knode_app_server_settings;

  /// 设置
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get knode_app_settings;

  /// 分享
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get knode_app_share;

  /// 声音
  ///
  /// In zh, this message translates to:
  /// **'声音'**
  String get knode_app_sound;

  /// 存储设置
  ///
  /// In zh, this message translates to:
  /// **'存储设置'**
  String get knode_app_storage_settings;

  /// 存储用量
  ///
  /// In zh, this message translates to:
  /// **'存储用量'**
  String get knode_app_storage_usage;

  /// 成功
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get knode_app_success;

  /// 跟随系统
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get knode_app_system_default;

  /// 主题
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get knode_app_theme;

  /// 版本
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get knode_app_version;

  /// 振动
  ///
  /// In zh, this message translates to:
  /// **'振动'**
  String get knode_app_vibration;

  /// WebDAV
  ///
  /// In zh, this message translates to:
  /// **'WebDAV'**
  String get knode_app_webdav;

  /// 错题卡片
  ///
  /// In zh, this message translates to:
  /// **'错题卡片'**
  String get knode_app_wrong_card;

  /// 提交答案失败
  ///
  /// In zh, this message translates to:
  /// **'提交答案失败'**
  String get micro_server_answer_submission_failed;

  /// CORS 预检请求
  ///
  /// In zh, this message translates to:
  /// **'CORS 预检请求'**
  String get micro_server_cors_preflight_request;

  /// 文档不存在
  ///
  /// In zh, this message translates to:
  /// **'文档不存在'**
  String get micro_server_document_does_not_exist;

  /// 获取文档列表失败
  ///
  /// In zh, this message translates to:
  /// **'获取文档列表失败'**
  String get micro_server_document_list_retrieval_failed;

  /// 获取文档失败
  ///
  /// In zh, this message translates to:
  /// **'获取文档失败'**
  String get micro_server_document_retrieval_failed;

  /// 下载失败
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get micro_server_download_failed;

  /// 获取文件列表失败
  ///
  /// In zh, this message translates to:
  /// **'获取文件列表失败'**
  String get micro_server_file_list_retrieval_failed;

  /// 文件未找到
  ///
  /// In zh, this message translates to:
  /// **'文件未找到'**
  String get micro_server_file_not_found;

  /// 服务器内部错误
  ///
  /// In zh, this message translates to:
  /// **'服务器内部错误'**
  String get micro_server_internal_server_error;

  /// 无效的文档 ID
  ///
  /// In zh, this message translates to:
  /// **'无效的文档 ID'**
  String get micro_server_invalid_document_id;

  /// 无效请求
  ///
  /// In zh, this message translates to:
  /// **'无效请求'**
  String get micro_server_invalid_request;

  /// 缺少 questionId
  ///
  /// In zh, this message translates to:
  /// **'缺少 questionId'**
  String get micro_server_missing_questionId;

  /// 未找到
  ///
  /// In zh, this message translates to:
  /// **'未找到'**
  String get micro_server_not_found;

  /// 端口
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get micro_server_port;

  /// 题目不存在
  ///
  /// In zh, this message translates to:
  /// **'题目不存在'**
  String get micro_server_question_does_not_exist;

  /// 获取题目失败
  ///
  /// In zh, this message translates to:
  /// **'获取题目失败'**
  String get micro_server_question_retrieval_failed;

  /// 请求体为空
  ///
  /// In zh, this message translates to:
  /// **'请求体为空'**
  String get micro_server_request_body_empty;

  /// 服务器地址
  ///
  /// In zh, this message translates to:
  /// **'服务器地址'**
  String get micro_server_server_address;

  /// 服务器已在运行中
  ///
  /// In zh, this message translates to:
  /// **'服务器已在运行中'**
  String get micro_server_server_already_running;

  /// 服务器未运行
  ///
  /// In zh, this message translates to:
  /// **'服务器未运行'**
  String get micro_server_server_not_running;

  /// 服务器已在端口 %d 启动
  ///
  /// In zh, this message translates to:
  /// **'服务器已在端口 %d 启动'**
  String get micro_server_server_started_on_port;

  /// 服务器已停止
  ///
  /// In zh, this message translates to:
  /// **'服务器已停止'**
  String get micro_server_server_stopped;

  /// 正在启动服务器...
  ///
  /// In zh, this message translates to:
  /// **'正在启动服务器...'**
  String get micro_server_starting_server;

  /// 正在停止服务器...
  ///
  /// In zh, this message translates to:
  /// **'正在停止服务器...'**
  String get micro_server_stopping_server;

  /// 上传已确认
  ///
  /// In zh, this message translates to:
  /// **'上传已确认'**
  String get micro_server_upload_confirmed;

  /// 上传失败
  ///
  /// In zh, this message translates to:
  /// **'上传失败'**
  String get micro_server_upload_failed;

  /// 等待上传确认
  ///
  /// In zh, this message translates to:
  /// **'等待上传确认'**
  String get micro_server_upload_pending_confirmation;

  /// 上传已拒绝
  ///
  /// In zh, this message translates to:
  /// **'上传已拒绝'**
  String get micro_server_upload_rejected;

  /// 等待手机端确认
  ///
  /// In zh, this message translates to:
  /// **'等待手机端确认'**
  String get micro_server_waiting_for_device_confirmation;

  /// 正确率
  ///
  /// In zh, this message translates to:
  /// **'正确率'**
  String get quiz_accuracy;

  /// AI 讲解
  ///
  /// In zh, this message translates to:
  /// **'AI 讲解'**
  String get quiz_ai_explanation;

  /// 全部知识库
  ///
  /// In zh, this message translates to:
  /// **'全部知识库'**
  String get quiz_all_knowledge_base;

  /// 答案
  ///
  /// In zh, this message translates to:
  /// **'答案'**
  String get quiz_answer;

  /// 已完成
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get quiz_completed;

  /// 确认交卷
  ///
  /// In zh, this message translates to:
  /// **'确认交卷'**
  String get quiz_confirm_submit;

  /// 恭喜通过！
  ///
  /// In zh, this message translates to:
  /// **'恭喜通过！'**
  String get quiz_congratulations_passed;

  /// 巩固薄弱知识点
  ///
  /// In zh, this message translates to:
  /// **'巩固薄弱知识点'**
  String get quiz_consolidate_weak_knowledge_points;

  /// 继续答题
  ///
  /// In zh, this message translates to:
  /// **'继续答题'**
  String get quiz_continue_answering;

  /// 正确
  ///
  /// In zh, this message translates to:
  /// **'正确'**
  String get quiz_correct;

  /// 正确答案
  ///
  /// In zh, this message translates to:
  /// **'正确答案'**
  String get quiz_correct_answer;

  /// 创建考试失败
  ///
  /// In zh, this message translates to:
  /// **'创建考试失败'**
  String get quiz_create_exam_failed;

  /// 每日一测
  ///
  /// In zh, this message translates to:
  /// **'每日一测'**
  String get quiz_daily_quiz;

  /// 每日一测未启用
  ///
  /// In zh, this message translates to:
  /// **'每日一测未启用'**
  String get quiz_daily_quiz_not_enabled;

  /// 每日一测设置
  ///
  /// In zh, this message translates to:
  /// **'每日一测设置'**
  String get quiz_daily_quiz_settings;

  /// 每日一测已开始，请切换到"测验"标签查看
  ///
  /// In zh, this message translates to:
  /// **'每日一测已开始，请切换到\"测验\"标签查看'**
  String get quiz_daily_quiz_started;

  /// 简单
  ///
  /// In zh, this message translates to:
  /// **'简单'**
  String get quiz_easy;

  /// 启用每日一测
  ///
  /// In zh, this message translates to:
  /// **'启用每日一测'**
  String get quiz_enable_daily_quiz;

  /// 考试
  ///
  /// In zh, this message translates to:
  /// **'考试'**
  String get quiz_exam;

  /// 考试已生成
  ///
  /// In zh, this message translates to:
  /// **'考试已生成'**
  String get quiz_exam_generated;

  /// 测验结果
  ///
  /// In zh, this message translates to:
  /// **'测验结果'**
  String get quiz_exam_result;

  /// 解析
  ///
  /// In zh, this message translates to:
  /// **'解析'**
  String get quiz_explanation;

  /// 反馈
  ///
  /// In zh, this message translates to:
  /// **'反馈'**
  String get quiz_feedback;

  /// 填空题
  ///
  /// In zh, this message translates to:
  /// **'填空题'**
  String get quiz_fill_in_the_blank;

  /// 每天定时生成测验题目
  ///
  /// In zh, this message translates to:
  /// **'每天定时生成测验题目'**
  String get quiz_generate_quiz_questions_daily;

  /// 困难
  ///
  /// In zh, this message translates to:
  /// **'困难'**
  String get quiz_hard;

  /// 继续加油！
  ///
  /// In zh, this message translates to:
  /// **'继续加油！'**
  String get quiz_keep_going;

  /// 加载失败
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get quiz_load_failed;

  /// 加载中...
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get quiz_loading;

  /// 标记为已掌握
  ///
  /// In zh, this message translates to:
  /// **'标记为已掌握'**
  String get quiz_mark_as_mastered;

  /// 已掌握
  ///
  /// In zh, this message translates to:
  /// **'已掌握'**
  String get quiz_mastered;

  /// 已标记为掌握，错题本中将不再显示
  ///
  /// In zh, this message translates to:
  /// **'已标记为掌握，错题本中将不再显示'**
  String get quiz_mastered_will_no_longer_appear;

  /// 中等
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get quiz_medium;

  /// 每月综合测验
  ///
  /// In zh, this message translates to:
  /// **'每月综合测验'**
  String get quiz_monthly_comprehensive_quiz;

  /// 月考
  ///
  /// In zh, this message translates to:
  /// **'月考'**
  String get quiz_monthly_exam;

  /// 月度考试
  ///
  /// In zh, this message translates to:
  /// **'月度考试'**
  String get quiz_monthly_exam_2;

  /// 多选题
  ///
  /// In zh, this message translates to:
  /// **'多选题'**
  String get quiz_multiple_choice;

  /// 下一题
  ///
  /// In zh, this message translates to:
  /// **'下一题'**
  String get quiz_next_question;

  /// 无关联文档
  ///
  /// In zh, this message translates to:
  /// **'无关联文档'**
  String get quiz_no_associated_document;

  /// 暂无考试记录
  ///
  /// In zh, this message translates to:
  /// **'暂无考试记录'**
  String get quiz_no_exam_records;

  /// 暂无错题，继续保持！
  ///
  /// In zh, this message translates to:
  /// **'暂无错题，继续保持！'**
  String get quiz_no_wrong_questions_keep_it_up;

  /// 请在 main.dart 中覆盖
  ///
  /// In zh, this message translates to:
  /// **'请在 main.dart 中覆盖'**
  String get quiz_please_override_in_main_dart;

  /// 请切换到"测验"标签查看考试历史
  ///
  /// In zh, this message translates to:
  /// **'请切换到\"测验\"标签查看考试历史'**
  String get quiz_please_switch_to_quiz_tab;

  /// 开始练习
  ///
  /// In zh, this message translates to:
  /// **'开始练习'**
  String get quiz_practice;

  /// 上一题
  ///
  /// In zh, this message translates to:
  /// **'上一题'**
  String get quiz_previous_question;

  /// 季度综合测验
  ///
  /// In zh, this message translates to:
  /// **'季度综合测验'**
  String get quiz_quarterly_comprehensive_quiz;

  /// 季考
  ///
  /// In zh, this message translates to:
  /// **'季考'**
  String get quiz_quarterly_exam;

  /// 季度考试
  ///
  /// In zh, this message translates to:
  /// **'季度考试'**
  String get quiz_quarterly_exam_2;

  /// 题目
  ///
  /// In zh, this message translates to:
  /// **'题目'**
  String get quiz_question;

  /// 题目数量
  ///
  /// In zh, this message translates to:
  /// **'题目数量'**
  String get quiz_question_count;

  /// 出题范围
  ///
  /// In zh, this message translates to:
  /// **'出题范围'**
  String get quiz_question_scope;

  /// 题
  ///
  /// In zh, this message translates to:
  /// **'题'**
  String get quiz_questions;

  /// 速记已开始，请切换到"测验"标签查看
  ///
  /// In zh, this message translates to:
  /// **'速记已开始，请切换到\"测验\"标签查看'**
  String get quiz_quick_quiz_started;

  /// 测验
  ///
  /// In zh, this message translates to:
  /// **'测验'**
  String get quiz_quiz;

  /// 测验类型
  ///
  /// In zh, this message translates to:
  /// **'测验类型'**
  String get quiz_quiz_types;

  /// 随机抽取快速复习
  ///
  /// In zh, this message translates to:
  /// **'随机抽取快速复习'**
  String get quiz_random_quick_review;

  /// 随机速记
  ///
  /// In zh, this message translates to:
  /// **'随机速记'**
  String get quiz_random_quiz;

  /// 已准备好，共 {count} 题
  ///
  /// In zh, this message translates to:
  /// **'已准备好，共 {count} 题'**
  String quiz_ready_with_n_questions(String count);

  /// 最近阅读文档
  ///
  /// In zh, this message translates to:
  /// **'最近阅读文档'**
  String get quiz_recent_reading_documents;

  /// 提醒时间
  ///
  /// In zh, this message translates to:
  /// **'提醒时间'**
  String get quiz_reminder_time;

  /// 返回
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get quiz_return;

  /// 保存设置
  ///
  /// In zh, this message translates to:
  /// **'保存设置'**
  String get quiz_save_settings;

  /// 分数
  ///
  /// In zh, this message translates to:
  /// **'分数'**
  String get quiz_score;

  /// 设置已保存
  ///
  /// In zh, this message translates to:
  /// **'设置已保存'**
  String get quiz_settings_saved;

  /// 简答题
  ///
  /// In zh, this message translates to:
  /// **'简答题'**
  String get quiz_short_answer;

  /// 单选题
  ///
  /// In zh, this message translates to:
  /// **'单选题'**
  String get quiz_single_choice;

  /// 按难度
  ///
  /// In zh, this message translates to:
  /// **'按难度'**
  String get quiz_sort_by_difficulty;

  /// 按错误次数
  ///
  /// In zh, this message translates to:
  /// **'按错误次数'**
  String get quiz_sort_by_wrong_count;

  /// 指定类目
  ///
  /// In zh, this message translates to:
  /// **'指定类目'**
  String get quiz_specific_category;

  /// 连续天数
  ///
  /// In zh, this message translates to:
  /// **'连续天数'**
  String get quiz_streak_days;

  /// 交卷
  ///
  /// In zh, this message translates to:
  /// **'交卷'**
  String get quiz_submit_exam;

  /// 点击开始练习
  ///
  /// In zh, this message translates to:
  /// **'点击开始练习'**
  String get quiz_tap_to_start;

  /// 每天 10 道题
  ///
  /// In zh, this message translates to:
  /// **'每天 10 道题'**
  String get quiz_ten_questions_per_day;

  /// 今日 {count} 题，点击开始
  ///
  /// In zh, this message translates to:
  /// **'今日 {count} 题，点击开始'**
  String quiz_today_n_questions_tap_to_start(String count);

  /// 判断题
  ///
  /// In zh, this message translates to:
  /// **'判断题'**
  String get quiz_true_false;

  /// 未知
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get quiz_unknown;

  /// 查看源文档
  ///
  /// In zh, this message translates to:
  /// **'查看源文档'**
  String get quiz_view_source_document;

  /// 错误
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get quiz_wrong;

  /// 错题详情
  ///
  /// In zh, this message translates to:
  /// **'错题详情'**
  String get quiz_wrong_question_detail;

  /// 错题重练
  ///
  /// In zh, this message translates to:
  /// **'错题重练'**
  String get quiz_wrong_question_review;

  /// 错题本
  ///
  /// In zh, this message translates to:
  /// **'错题本'**
  String get quiz_wrong_questions;

  /// 年度综合测验
  ///
  /// In zh, this message translates to:
  /// **'年度综合测验'**
  String get quiz_yearly_comprehensive_quiz;

  /// 年考
  ///
  /// In zh, this message translates to:
  /// **'年考'**
  String get quiz_yearly_exam;

  /// 年度考试
  ///
  /// In zh, this message translates to:
  /// **'年度考试'**
  String get quiz_yearly_exam_2;

  /// 你的答案
  ///
  /// In zh, this message translates to:
  /// **'你的答案'**
  String get quiz_your_answer;

  /// 添加类目
  ///
  /// In zh, this message translates to:
  /// **'添加类目'**
  String get wiki_add_category;

  /// 添加引用
  ///
  /// In zh, this message translates to:
  /// **'添加引用'**
  String get wiki_add_citation;

  /// 全部知识
  ///
  /// In zh, this message translates to:
  /// **'全部知识'**
  String get wiki_all_knowledge;

  /// 取消
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get wiki_cancel;

  /// 类目
  ///
  /// In zh, this message translates to:
  /// **'类目'**
  String get wiki_category;

  /// 类目面板
  ///
  /// In zh, this message translates to:
  /// **'类目面板'**
  String get wiki_category_panel;

  /// 类目树
  ///
  /// In zh, this message translates to:
  /// **'类目树'**
  String get wiki_category_tree;

  /// 引用
  ///
  /// In zh, this message translates to:
  /// **'引用'**
  String get wiki_citation;

  /// 引用弹窗
  ///
  /// In zh, this message translates to:
  /// **'引用弹窗'**
  String get wiki_citation_popup;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get wiki_confirm;

  /// 创建节点
  ///
  /// In zh, this message translates to:
  /// **'创建节点'**
  String get wiki_create_node;

  /// 删除
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get wiki_delete;

  /// 删除文档
  ///
  /// In zh, this message translates to:
  /// **'删除文档'**
  String get wiki_delete_document;

  /// 文档
  ///
  /// In zh, this message translates to:
  /// **'文档'**
  String get wiki_document;

  /// 文档标题
  ///
  /// In zh, this message translates to:
  /// **'文档标题'**
  String get wiki_document_title;

  /// 编辑类目
  ///
  /// In zh, this message translates to:
  /// **'编辑类目'**
  String get wiki_edit_category;

  /// 编辑文档
  ///
  /// In zh, this message translates to:
  /// **'编辑文档'**
  String get wiki_edit_document;

  /// 编辑器
  ///
  /// In zh, this message translates to:
  /// **'编辑器'**
  String get wiki_editor;

  /// 错误
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get wiki_error;

  /// 导出
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get wiki_export;

  /// 导出文档
  ///
  /// In zh, this message translates to:
  /// **'导出文档'**
  String get wiki_export_document;

  /// 图谱画布
  ///
  /// In zh, this message translates to:
  /// **'图谱画布'**
  String get wiki_graph_canvas;

  /// 图谱控制器
  ///
  /// In zh, this message translates to:
  /// **'图谱控制器'**
  String get wiki_graph_controller;

  /// 图谱边
  ///
  /// In zh, this message translates to:
  /// **'图谱边'**
  String get wiki_graph_edge;

  /// 图谱节点
  ///
  /// In zh, this message translates to:
  /// **'图谱节点'**
  String get wiki_graph_node;

  /// 灵感
  ///
  /// In zh, this message translates to:
  /// **'灵感'**
  String get wiki_ideas;

  /// 导入
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get wiki_import;

  /// 导入文档
  ///
  /// In zh, this message translates to:
  /// **'导入文档'**
  String get wiki_import_document;

  /// 知识图谱
  ///
  /// In zh, this message translates to:
  /// **'知识图谱'**
  String get wiki_knowledge_graph;

  /// 知识地图
  ///
  /// In zh, this message translates to:
  /// **'知识地图'**
  String get wiki_knowledge_map;

  /// 加载中...
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get wiki_loading;

  /// 管理类目
  ///
  /// In zh, this message translates to:
  /// **'管理类目'**
  String get wiki_manage_categories;

  /// 新建文档
  ///
  /// In zh, this message translates to:
  /// **'新建文档'**
  String get wiki_new_document;

  /// 暂无文档
  ///
  /// In zh, this message translates to:
  /// **'暂无文档'**
  String get wiki_no_documents;

  /// 节点名称
  ///
  /// In zh, this message translates to:
  /// **'节点名称'**
  String get wiki_node_name;

  /// 笔记
  ///
  /// In zh, this message translates to:
  /// **'笔记'**
  String get wiki_notes;

  /// 页
  ///
  /// In zh, this message translates to:
  /// **'页'**
  String get wiki_page;

  /// PDF 导出
  ///
  /// In zh, this message translates to:
  /// **'PDF 导出'**
  String get wiki_pdf_export;

  /// 阅读器
  ///
  /// In zh, this message translates to:
  /// **'阅读器'**
  String get wiki_reader;

  /// 阅读器工具栏
  ///
  /// In zh, this message translates to:
  /// **'阅读器工具栏'**
  String get wiki_reader_toolbar;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get wiki_save;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get wiki_search;

  /// 学习资料
  ///
  /// In zh, this message translates to:
  /// **'学习资料'**
  String get wiki_study_materials;

  /// 摘要
  ///
  /// In zh, this message translates to:
  /// **'摘要'**
  String get wiki_summarize;

  /// 摘要生成器
  ///
  /// In zh, this message translates to:
  /// **'摘要生成器'**
  String get wiki_summarizer;

  /// 摘要
  ///
  /// In zh, this message translates to:
  /// **'摘要'**
  String get wiki_summary;

  /// 文字转语音
  ///
  /// In zh, this message translates to:
  /// **'文字转语音'**
  String get wiki_text_to_speech;

  /// 朗读
  ///
  /// In zh, this message translates to:
  /// **'朗读'**
  String get wiki_tts;

  /// 知识库
  ///
  /// In zh, this message translates to:
  /// **'知识库'**
  String get wiki_wiki;

  /// 工作
  ///
  /// In zh, this message translates to:
  /// **'工作'**
  String get wiki_work;

  /// 放大
  ///
  /// In zh, this message translates to:
  /// **'放大'**
  String get wiki_zoom_in;

  /// 缩小
  ///
  /// In zh, this message translates to:
  /// **'缩小'**
  String get wiki_zoom_out;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
