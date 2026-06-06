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

  /// 添加附件
  ///
  /// In zh, this message translates to:
  /// **'添加附件'**
  String get chat_add_attachment;

  /// 添加附件
  ///
  /// In zh, this message translates to:
  /// **'添加附件'**
  String get chat_add_attachment_label;

  /// AI 助手
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get chat_ai_assistant;

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

  /// 归档失败
  ///
  /// In zh, this message translates to:
  /// **'归档失败'**
  String get chat_archive_failed;

  /// 归档功能需在会话详情页中使用
  ///
  /// In zh, this message translates to:
  /// **'归档功能需在会话详情页中使用'**
  String get chat_archive_in_detail;

  /// 会话归档
  ///
  /// In zh, this message translates to:
  /// **'会话归档'**
  String get chat_archive_title;

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

  /// 清空对话功能开发中
  ///
  /// In zh, this message translates to:
  /// **'清空对话功能开发中'**
  String get chat_clear_history_dev;

  /// 清空对话功能开发中
  ///
  /// In zh, this message translates to:
  /// **'清空对话功能开发中'**
  String get chat_clear_in_dev;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get chat_confirm;

  /// 连接失败
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get chat_connection_failed;

  /// 连接成功
  ///
  /// In zh, this message translates to:
  /// **'连接成功'**
  String get chat_connection_success;

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

  /// 当前会话
  ///
  /// In zh, this message translates to:
  /// **'当前会话'**
  String get chat_current_session;

  /// 删除对话
  ///
  /// In zh, this message translates to:
  /// **'删除对话'**
  String get chat_delete_conversation;

  /// 文档
  ///
  /// In zh, this message translates to:
  /// **'文档'**
  String get chat_document;

  /// 文档选择功能开发中
  ///
  /// In zh, this message translates to:
  /// **'文档选择功能开发中'**
  String get chat_document_dev;

  /// 文档选择功能开发中
  ///
  /// In zh, this message translates to:
  /// **'文档选择功能开发中'**
  String get chat_document_in_dev;

  /// 文档
  ///
  /// In zh, this message translates to:
  /// **'文档'**
  String get chat_document_label;

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

  /// 历史会话
  ///
  /// In zh, this message translates to:
  /// **'历史会话'**
  String get chat_history_conversations;

  /// 历史会话功能开发中
  ///
  /// In zh, this message translates to:
  /// **'历史会话功能开发中'**
  String get chat_history_in_dev;

  /// 历史会话
  ///
  /// In zh, this message translates to:
  /// **'历史会话'**
  String get chat_history_sessions;

  /// 历史会话功能开发中
  ///
  /// In zh, this message translates to:
  /// **'历史会话功能开发中'**
  String get chat_history_sessions_dev;

  /// 图片
  ///
  /// In zh, this message translates to:
  /// **'图片'**
  String get chat_image;

  /// 图片选择功能开发中
  ///
  /// In zh, this message translates to:
  /// **'图片选择功能开发中'**
  String get chat_image_dev;

  /// 图片选择功能开发中
  ///
  /// In zh, this message translates to:
  /// **'图片选择功能开发中'**
  String get chat_image_in_dev;

  /// 图片
  ///
  /// In zh, this message translates to:
  /// **'图片'**
  String get chat_image_label;

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

  /// 链接
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get chat_link;

  /// 链接粘贴功能开发中
  ///
  /// In zh, this message translates to:
  /// **'链接粘贴功能开发中'**
  String get chat_link_dev;

  /// 链接粘贴功能开发中
  ///
  /// In zh, this message translates to:
  /// **'链接粘贴功能开发中'**
  String get chat_link_in_dev;

  /// 链接
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get chat_link_label;

  /// 加载失败
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get chat_load_failed;

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

  /// 消息发送功能需连接 AIProvider
  ///
  /// In zh, this message translates to:
  /// **'消息发送功能需连接 AIProvider'**
  String get chat_need_ai_provider;

  /// 新建对话
  ///
  /// In zh, this message translates to:
  /// **'新建对话'**
  String get chat_new_conversation;

  /// 暂无对话，开始新对话吧
  ///
  /// In zh, this message translates to:
  /// **'暂无对话，开始新对话吧'**
  String get chat_no_conversations;

  /// 暂无对话
  ///
  /// In zh, this message translates to:
  /// **'暂无对话'**
  String get chat_no_conversations_yet;

  /// 请在 main.dart 中覆盖
  ///
  /// In zh, this message translates to:
  /// **'请在 main.dart 中覆盖'**
  String get chat_please_override_in_main_dart;

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

  /// 重命名对话
  ///
  /// In zh, this message translates to:
  /// **'重命名对话'**
  String get chat_rename_conversation;

  /// 重命名
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get chat_rename_label;

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

  /// 搜索 API Key
  ///
  /// In zh, this message translates to:
  /// **'搜索 API Key'**
  String get chat_search_api_key;

  /// 搜索配置
  ///
  /// In zh, this message translates to:
  /// **'搜索配置'**
  String get chat_search_config;

  /// 搜索服务商
  ///
  /// In zh, this message translates to:
  /// **'搜索服务商'**
  String get chat_search_provider;

  /// 选择类目
  ///
  /// In zh, this message translates to:
  /// **'选择类目'**
  String get chat_select_category;

  /// 选择目标类目:
  ///
  /// In zh, this message translates to:
  /// **'选择目标类目:'**
  String get chat_select_target_category;

  /// 发送
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get chat_send;

  /// 发送消息
  ///
  /// In zh, this message translates to:
  /// **'发送消息'**
  String get chat_send_message;

  /// 发送消息
  ///
  /// In zh, this message translates to:
  /// **'发送消息'**
  String get chat_send_message_label;

  /// 消息发送功能需连接 AIProvider
  ///
  /// In zh, this message translates to:
  /// **'消息发送功能需连接 AIProvider'**
  String get chat_send_message_need_ai;

  /// 会话共 {n} 条消息
  ///
  /// In zh, this message translates to:
  /// **'会话共 {n} 条消息'**
  String chat_session_n_messages(String n);

  /// 来源
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get chat_sources;

  /// 发送消息开始与 AI 助手对话
  ///
  /// In zh, this message translates to:
  /// **'发送消息开始与 AI 助手对话'**
  String get chat_start_conversation_hint;

  /// 测试连接
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get chat_test_connection;

  /// Token 用量
  ///
  /// In zh, this message translates to:
  /// **'Token 用量'**
  String get chat_token_usage;

  /// 用户
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get chat_user_label;

  /// 语音输入
  ///
  /// In zh, this message translates to:
  /// **'语音输入'**
  String get chat_voice_input;

  /// 语音输入
  ///
  /// In zh, this message translates to:
  /// **'语音输入'**
  String get chat_voice_input_label;

  /// 语音输入功能需在真机上使用
  ///
  /// In zh, this message translates to:
  /// **'语音输入功能需在真机上使用'**
  String get chat_voice_real_device;

  /// 语音输入功能需在真机上使用
  ///
  /// In zh, this message translates to:
  /// **'语音输入功能需在真机上使用'**
  String get chat_voice_real_device_label;

  /// 联网
  ///
  /// In zh, this message translates to:
  /// **'联网'**
  String get chat_web;

  /// 联网搜索
  ///
  /// In zh, this message translates to:
  /// **'联网搜索'**
  String get chat_web_search;

  /// AI
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get core_ai_role;

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

  /// 可用内存
  ///
  /// In zh, this message translates to:
  /// **'可用内存'**
  String get core_available_memory;

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

  /// 继续导入
  ///
  /// In zh, this message translates to:
  /// **'继续导入'**
  String get core_continue_import;

  /// 对话
  ///
  /// In zh, this message translates to:
  /// **'对话'**
  String get core_conversation;

  /// 会话为空无法归档
  ///
  /// In zh, this message translates to:
  /// **'会话为空无法归档'**
  String get core_conversation_empty_archive;

  /// 会话不存在
  ///
  /// In zh, this message translates to:
  /// **'会话不存在'**
  String get core_conversation_not_found;

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

  /// 考试不存在
  ///
  /// In zh, this message translates to:
  /// **'考试不存在'**
  String get core_exam_not_found;

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

  /// 内存不足
  ///
  /// In zh, this message translates to:
  /// **'内存不足'**
  String get core_memory_insufficient;

  /// 消息
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get core_message;

  /// 国内
  ///
  /// In zh, this message translates to:
  /// **'国内'**
  String get core_mirror_china;

  /// 国际
  ///
  /// In zh, this message translates to:
  /// **'国际'**
  String get core_mirror_global;

  /// 删除
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get core_model_delete;

  /// 下载
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get core_model_download;

  /// 使用中
  ///
  /// In zh, this message translates to:
  /// **'使用中'**
  String get core_model_in_use;

  /// 加载
  ///
  /// In zh, this message translates to:
  /// **'加载'**
  String get core_model_load;

  /// 已加载
  ///
  /// In zh, this message translates to:
  /// **'已加载'**
  String get core_model_loaded;

  /// 该模型约 {size}，你的设备内存为 {mem}，可能无法正常运行
  ///
  /// In zh, this message translates to:
  /// **'该模型约 {size}，你的设备内存为 {mem}，可能无法正常运行'**
  String core_model_may_not_run(String size, String mem);

  /// 无下载源
  ///
  /// In zh, this message translates to:
  /// **'无下载源'**
  String get core_model_no_download_source;

  /// 不可用（内存不足）
  ///
  /// In zh, this message translates to:
  /// **'不可用（内存不足）'**
  String get core_model_not_compatible;

  /// 需 {minRam} RAM
  ///
  /// In zh, this message translates to:
  /// **'需 {minRam} RAM'**
  String core_model_requires_ram(String minRam);

  /// 重试
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get core_model_retry;

  /// 月度考试
  ///
  /// In zh, this message translates to:
  /// **'月度考试'**
  String get core_monthly_exam_2;

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

  /// 备份完成
  ///
  /// In zh, this message translates to:
  /// **'备份完成'**
  String get core_progress_backup_complete;

  /// 正在解压...
  ///
  /// In zh, this message translates to:
  /// **'正在解压...'**
  String get core_progress_decompressing;

  /// 正在下载...
  ///
  /// In zh, this message translates to:
  /// **'正在下载...'**
  String get core_progress_downloading;

  /// 正在打包文件...
  ///
  /// In zh, this message translates to:
  /// **'正在打包文件...'**
  String get core_progress_packing;

  /// 恢复完成
  ///
  /// In zh, this message translates to:
  /// **'恢复完成'**
  String get core_progress_restore_complete;

  /// 正在上传...
  ///
  /// In zh, this message translates to:
  /// **'正在上传...'**
  String get core_progress_uploading;

  /// 季度考试
  ///
  /// In zh, this message translates to:
  /// **'季度考试'**
  String get core_quarterly_exam_2;

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

  /// 随机抽取快速复习
  ///
  /// In zh, this message translates to:
  /// **'随机抽取快速复习'**
  String get core_random_quick_review;

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

  /// 设备总内存
  ///
  /// In zh, this message translates to:
  /// **'设备总内存'**
  String get core_total_memory;

  /// 判断题
  ///
  /// In zh, this message translates to:
  /// **'判断题'**
  String get core_true_false;

  /// 未命名文档
  ///
  /// In zh, this message translates to:
  /// **'未命名文档'**
  String get core_unnamed_document;

  /// 用户
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get core_user_role;

  /// WebDAV 未配置
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 未配置'**
  String get core_webdav_not_configured;

  /// 错题重练
  ///
  /// In zh, this message translates to:
  /// **'错题重练'**
  String get core_wrong_question_review;

  /// 年度考试
  ///
  /// In zh, this message translates to:
  /// **'年度考试'**
  String get core_yearly_exam_2;

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

  /// 账号
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get knode_app_account;

  /// 高级设置
  ///
  /// In zh, this message translates to:
  /// **'高级设置'**
  String get knode_app_advanced_settings;

  /// AI 引擎
  ///
  /// In zh, this message translates to:
  /// **'AI 引擎'**
  String get knode_app_ai_engine;

  /// 本地模型管理、云端 API 配置
  ///
  /// In zh, this message translates to:
  /// **'本地模型管理、云端 API 配置'**
  String get knode_app_ai_engine_subtitle;

  /// AI
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get knode_app_ai_label;

  /// AI 设置
  ///
  /// In zh, this message translates to:
  /// **'AI 设置'**
  String get knode_app_ai_settings;

  /// 接口地址
  ///
  /// In zh, this message translates to:
  /// **'接口地址'**
  String get knode_app_api_base_url;

  /// API 协议
  ///
  /// In zh, this message translates to:
  /// **'API 协议'**
  String get knode_app_api_protocol;

  /// 应用外壳
  ///
  /// In zh, this message translates to:
  /// **'应用外壳'**
  String get knode_app_app_shell;

  /// 应用日志
  ///
  /// In zh, this message translates to:
  /// **'应用日志'**
  String get knode_app_application_log;

  /// 会话归档
  ///
  /// In zh, this message translates to:
  /// **'会话归档'**
  String get knode_app_archive_title;

  /// 自动备份
  ///
  /// In zh, this message translates to:
  /// **'自动备份'**
  String get knode_app_auto_backup;

  /// 可用内存: {memory} MB
  ///
  /// In zh, this message translates to:
  /// **'可用内存: {memory} MB'**
  String knode_app_available_memory(String memory);

  /// 可用内存
  ///
  /// In zh, this message translates to:
  /// **'可用内存'**
  String get knode_app_available_memory_label;

  /// 备份
  ///
  /// In zh, this message translates to:
  /// **'备份'**
  String get knode_app_backup;

  /// 备份完成
  ///
  /// In zh, this message translates to:
  /// **'备份完成'**
  String get knode_app_backup_complete;

  /// 备份失败
  ///
  /// In zh, this message translates to:
  /// **'备份失败'**
  String get knode_app_backup_failed;

  /// 备份频率
  ///
  /// In zh, this message translates to:
  /// **'备份频率'**
  String get knode_app_backup_frequency;

  /// 定时备份频率
  ///
  /// In zh, this message translates to:
  /// **'定时备份频率'**
  String get knode_app_backup_frequency_label;

  /// 备份历史
  ///
  /// In zh, this message translates to:
  /// **'备份历史'**
  String get knode_app_backup_history;

  /// 立即备份
  ///
  /// In zh, this message translates to:
  /// **'立即备份'**
  String get knode_app_backup_now;

  /// 立即备份
  ///
  /// In zh, this message translates to:
  /// **'立即备份'**
  String get knode_app_backup_now_label;

  /// 备份设置
  ///
  /// In zh, this message translates to:
  /// **'备份设置'**
  String get knode_app_backup_settings;

  /// 本地
  ///
  /// In zh, this message translates to:
  /// **'本地'**
  String get knode_app_backup_type_local;

  /// WebDAV
  ///
  /// In zh, this message translates to:
  /// **'WebDAV'**
  String get knode_app_backup_type_webdav;

  /// 基于最近阅读文件出题
  ///
  /// In zh, this message translates to:
  /// **'基于最近阅读文件出题'**
  String get knode_app_based_on_recent;

  /// 未配置备份目标，请配置 WebDAV 或本地备份
  ///
  /// In zh, this message translates to:
  /// **'未配置备份目标，请配置 WebDAV 或本地备份'**
  String get knode_app_both_not_configured;

  /// 底部导航
  ///
  /// In zh, this message translates to:
  /// **'底部导航'**
  String get knode_app_bottom_navigation;

  /// 浏览历史
  ///
  /// In zh, this message translates to:
  /// **'浏览历史'**
  String get knode_app_browse_history;

  /// 取消
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get knode_app_cancel;

  /// 检查更新
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get knode_app_check_update;

  /// 文件校验失败，请重新下载
  ///
  /// In zh, this message translates to:
  /// **'文件校验失败，请重新下载'**
  String get knode_app_checksum_failed;

  /// 清除缓存
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get knode_app_clear_cache;

  /// 云端 API
  ///
  /// In zh, this message translates to:
  /// **'云端 API'**
  String get knode_app_cloud_api;

  /// 云端 API
  ///
  /// In zh, this message translates to:
  /// **'云端 API'**
  String get knode_app_cloud_api_label;

  /// 云配置
  ///
  /// In zh, this message translates to:
  /// **'云配置'**
  String get knode_app_cloud_config;

  /// 云模型仓库地址
  ///
  /// In zh, this message translates to:
  /// **'云模型仓库地址'**
  String get knode_app_cloud_model_repo_url;

  /// 云模型仓库地址
  ///
  /// In zh, this message translates to:
  /// **'云模型仓库地址'**
  String get knode_app_cloud_model_repo_url_label;

  /// 云同步
  ///
  /// In zh, this message translates to:
  /// **'云同步'**
  String get knode_app_cloud_sync;

  /// 请先配置 API Key
  ///
  /// In zh, this message translates to:
  /// **'请先配置 API Key'**
  String get knode_app_config_api_key_first;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get knode_app_confirm;

  /// 确认恢复
  ///
  /// In zh, this message translates to:
  /// **'确认恢复'**
  String get knode_app_confirm_restore;

  /// 连接失败
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get knode_app_connection_failed;

  /// 连接成功
  ///
  /// In zh, this message translates to:
  /// **'连接成功'**
  String get knode_app_connection_success;

  /// 已复制到剪贴板
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get knode_app_copied_to_clipboard;

  /// 复制
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get knode_app_copy;

  /// 答对 {n} / {m} 题
  ///
  /// In zh, this message translates to:
  /// **'答对 {n} / {m} 题'**
  String knode_app_correct_n_of_m(String n, String m);

  /// 当前存储路径
  ///
  /// In zh, this message translates to:
  /// **'当前存储路径'**
  String get knode_app_current_storage_path;

  /// 已自定义
  ///
  /// In zh, this message translates to:
  /// **'已自定义'**
  String get knode_app_custom;

  /// 自定义...
  ///
  /// In zh, this message translates to:
  /// **'自定义...'**
  String get knode_app_custom_label;

  /// 每天
  ///
  /// In zh, this message translates to:
  /// **'每天'**
  String get knode_app_daily;

  /// 每日卡片
  ///
  /// In zh, this message translates to:
  /// **'每日卡片'**
  String get knode_app_daily_card;

  /// 今天也要坚持学习哦
  ///
  /// In zh, this message translates to:
  /// **'今天也要坚持学习哦'**
  String get knode_app_daily_encouragement;

  /// 每天
  ///
  /// In zh, this message translates to:
  /// **'每天'**
  String get knode_app_daily_label;

  /// 每日一测已开始，请切换到[测验]标签查看
  ///
  /// In zh, this message translates to:
  /// **'每日一测已开始，请切换到[测验]标签查看'**
  String get knode_app_daily_quiz_started;

  /// 深色模式
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get knode_app_dark_mode;

  /// 正在解压...
  ///
  /// In zh, this message translates to:
  /// **'正在解压...'**
  String get knode_app_decompressing;

  /// 考试
  ///
  /// In zh, this message translates to:
  /// **'考试'**
  String get knode_app_default_exam_title;

  /// 删除
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get knode_app_delete;

  /// 确定删除此备份？
  ///
  /// In zh, this message translates to:
  /// **'确定删除此备份？'**
  String get knode_app_delete_backup_confirm;

  /// 删除失败
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get knode_app_delete_failed;

  /// 说明
  ///
  /// In zh, this message translates to:
  /// **'说明'**
  String get knode_app_description;

  /// 下载失败
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get knode_app_download_failed;

  /// 下载
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get knode_app_download_label;

  /// 正在下载...
  ///
  /// In zh, this message translates to:
  /// **'正在下载...'**
  String get knode_app_downloading;

  /// 启用微服务
  ///
  /// In zh, this message translates to:
  /// **'启用微服务'**
  String get knode_app_enable_micro_server;

  /// 开启后可通过浏览器访问
  ///
  /// In zh, this message translates to:
  /// **'开启后可通过浏览器访问'**
  String get knode_app_enable_micro_server_desc;

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

  /// 导出成功
  ///
  /// In zh, this message translates to:
  /// **'导出成功'**
  String get knode_app_export_success;

  /// 导出文件包含自定义提示词
  ///
  /// In zh, this message translates to:
  /// **'导出文件包含自定义提示词'**
  String get knode_app_export_warning;

  /// 收藏夹
  ///
  /// In zh, this message translates to:
  /// **'收藏夹'**
  String get knode_app_favorites;

  /// 反馈
  ///
  /// In zh, this message translates to:
  /// **'反馈'**
  String get knode_app_feedback;

  /// 获取
  ///
  /// In zh, this message translates to:
  /// **'获取'**
  String get knode_app_fetch;

  /// 获取失败，使用已缓存数据
  ///
  /// In zh, this message translates to:
  /// **'获取失败，使用已缓存数据'**
  String get knode_app_fetch_failed_use_cache;

  /// 请获取仓库或导入本地文件
  ///
  /// In zh, this message translates to:
  /// **'请获取仓库或导入本地文件'**
  String get knode_app_fetch_or_import_hint;

  /// 文件过大
  ///
  /// In zh, this message translates to:
  /// **'文件过大'**
  String get knode_app_file_too_large;

  /// 字体大小
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get knode_app_font_size;

  /// 字号
  ///
  /// In zh, this message translates to:
  /// **'字号'**
  String get knode_app_font_size_label;

  /// 获取备份列表失败
  ///
  /// In zh, this message translates to:
  /// **'获取备份列表失败'**
  String get knode_app_get_backup_list_failed;

  /// 仅支持 .gguf 格式文件
  ///
  /// In zh, this message translates to:
  /// **'仅支持 .gguf 格式文件'**
  String get knode_app_gguf_only;

  /// 首页
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get knode_app_home;

  /// 成功导入 {count} 个模板
  ///
  /// In zh, this message translates to:
  /// **'成功导入 {count} 个模板'**
  String knode_app_import_count(String count);

  /// 导入数据
  ///
  /// In zh, this message translates to:
  /// **'导入数据'**
  String get knode_app_import_data;

  /// 导入失败
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get knode_app_import_failed;

  /// 从文件导入
  ///
  /// In zh, this message translates to:
  /// **'从文件导入'**
  String get knode_app_import_file;

  /// 在此粘贴 JSON 内容
  ///
  /// In zh, this message translates to:
  /// **'在此粘贴 JSON 内容'**
  String get knode_app_import_json_hint;

  /// 导入本地模型
  ///
  /// In zh, this message translates to:
  /// **'导入本地模型'**
  String get knode_app_import_local_model;

  /// 导入成功
  ///
  /// In zh, this message translates to:
  /// **'导入成功'**
  String get knode_app_import_success;

  /// 输入 API Key
  ///
  /// In zh, this message translates to:
  /// **'输入 API Key'**
  String get knode_app_input_api_key;

  /// JSON 格式错误
  ///
  /// In zh, this message translates to:
  /// **'JSON 格式错误'**
  String get knode_app_invalid_json;

  /// 保留备份数量
  ///
  /// In zh, this message translates to:
  /// **'保留备份数量'**
  String get knode_app_keep_backup_count;

  /// 自动清理时保留最近 {n} 个备份
  ///
  /// In zh, this message translates to:
  /// **'自动清理时保留最近 {n} 个备份'**
  String knode_app_keep_backup_desc(String n);

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

  /// 行距
  ///
  /// In zh, this message translates to:
  /// **'行距'**
  String get knode_app_line_spacing;

  /// 加载失败
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get knode_app_load_failed;

  /// 加载
  ///
  /// In zh, this message translates to:
  /// **'加载'**
  String get knode_app_load_label;

  /// 已加载
  ///
  /// In zh, this message translates to:
  /// **'已加载'**
  String get knode_app_loaded;

  /// 加载中...
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get knode_app_loading;

  /// 本地备份
  ///
  /// In zh, this message translates to:
  /// **'本地备份'**
  String get knode_app_local_backup;

  /// 请配置本地备份目录
  ///
  /// In zh, this message translates to:
  /// **'请配置本地备份目录'**
  String get knode_app_local_backup_config_needed;

  /// 本地上次备份: {time}
  ///
  /// In zh, this message translates to:
  /// **'本地上次备份: {time}'**
  String knode_app_local_backup_last_backup(String time);

  /// 未配置本地备份
  ///
  /// In zh, this message translates to:
  /// **'未配置本地备份'**
  String get knode_app_local_backup_not_configured;

  /// 本地备份路径
  ///
  /// In zh, this message translates to:
  /// **'本地备份路径'**
  String get knode_app_local_backup_path;

  /// 选择本地备份目录
  ///
  /// In zh, this message translates to:
  /// **'选择本地备份目录'**
  String get knode_app_local_backup_path_subtitle;

  /// 备份到本地存储
  ///
  /// In zh, this message translates to:
  /// **'备份到本地存储'**
  String get knode_app_local_backup_subtitle;

  /// 本地模型
  ///
  /// In zh, this message translates to:
  /// **'本地模型'**
  String get knode_app_local_model;

  /// 本地模型
  ///
  /// In zh, this message translates to:
  /// **'本地模型'**
  String get knode_app_local_model_label;

  /// 本地恢复
  ///
  /// In zh, this message translates to:
  /// **'本地恢复'**
  String get knode_app_local_restore;

  /// 全部
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get knode_app_log_all;

  /// 清空日志
  ///
  /// In zh, this message translates to:
  /// **'清空日志'**
  String get knode_app_log_clear;

  /// 确定要清空所有日志文件吗？此操作不可恢复。
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有日志文件吗？此操作不可恢复。'**
  String get knode_app_log_clear_confirm;

  /// 日志已清空
  ///
  /// In zh, this message translates to:
  /// **'日志已清空'**
  String get knode_app_log_clear_success;

  /// 已复制到剪贴板
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get knode_app_log_copied;

  /// 日志详情
  ///
  /// In zh, this message translates to:
  /// **'日志详情'**
  String get knode_app_log_detail;

  /// 错误信息
  ///
  /// In zh, this message translates to:
  /// **'错误信息'**
  String get knode_app_log_error_info;

  /// 导出日志
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get knode_app_log_export;

  /// 日志已导出
  ///
  /// In zh, this message translates to:
  /// **'日志已导出'**
  String get knode_app_log_export_success;

  /// 级别
  ///
  /// In zh, this message translates to:
  /// **'级别'**
  String get knode_app_log_level;

  /// 暂无日志
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get knode_app_log_no_logs;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get knode_app_log_search;

  /// 搜索日志...
  ///
  /// In zh, this message translates to:
  /// **'搜索日志...'**
  String get knode_app_log_search_hint;

  /// 堆栈跟踪
  ///
  /// In zh, this message translates to:
  /// **'堆栈跟踪'**
  String get knode_app_log_stack_trace;

  /// 日志查看器
  ///
  /// In zh, this message translates to:
  /// **'日志查看器'**
  String get knode_app_log_viewer;

  /// 手动
  ///
  /// In zh, this message translates to:
  /// **'手动'**
  String get knode_app_manual;

  /// 手动操作
  ///
  /// In zh, this message translates to:
  /// **'手动操作'**
  String get knode_app_manual_operation;

  /// 手动操作
  ///
  /// In zh, this message translates to:
  /// **'手动操作'**
  String get knode_app_manual_operations;

  /// 修改并迁移
  ///
  /// In zh, this message translates to:
  /// **'修改并迁移'**
  String get knode_app_migrate_and_change;

  /// 将存储路径修改为:\n{path}\n\n是否迁移已有文件？
  ///
  /// In zh, this message translates to:
  /// **'将存储路径修改为:\\n{path}\\n\\n是否迁移已有文件？'**
  String knode_app_migrate_files_confirm(String path);

  /// 已迁移 {n} 个文件
  ///
  /// In zh, this message translates to:
  /// **'已迁移 {n} 个文件'**
  String knode_app_migrated_n_files(String n);

  /// 迁移失败
  ///
  /// In zh, this message translates to:
  /// **'迁移失败'**
  String get knode_app_migration_failed;

  /// 镜像 "{key}" 不存在
  ///
  /// In zh, this message translates to:
  /// **'镜像 \"{key}\" 不存在'**
  String knode_app_mirror_not_found(String key);

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

  /// 模型
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get knode_app_model_label;

  /// 模型
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get knode_app_model_name_label;

  /// 模型仓库地址
  ///
  /// In zh, this message translates to:
  /// **'模型仓库地址'**
  String get knode_app_model_repo_url;

  /// 模型仓库地址
  ///
  /// In zh, this message translates to:
  /// **'模型仓库地址'**
  String get knode_app_model_repo_url_label;

  /// 修改存储路径
  ///
  /// In zh, this message translates to:
  /// **'修改存储路径'**
  String get knode_app_modify_storage_path;

  /// 模块设置
  ///
  /// In zh, this message translates to:
  /// **'模块设置'**
  String get knode_app_module_settings;

  /// （多选）
  ///
  /// In zh, this message translates to:
  /// **'（多选）'**
  String get knode_app_multiple_choice_suffix;

  /// 夜间模式
  ///
  /// In zh, this message translates to:
  /// **'夜间模式'**
  String get knode_app_night_mode;

  /// 暂无备份记录
  ///
  /// In zh, this message translates to:
  /// **'暂无备份记录'**
  String get knode_app_no_backups;

  /// 没有可用的备份
  ///
  /// In zh, this message translates to:
  /// **'没有可用的备份'**
  String get knode_app_no_backups_available;

  /// 不清理
  ///
  /// In zh, this message translates to:
  /// **'不清理'**
  String get knode_app_no_cleanup;

  /// 没有自定义模板可导出
  ///
  /// In zh, this message translates to:
  /// **'没有自定义模板可导出'**
  String get knode_app_no_custom_templates;

  /// 无下载源
  ///
  /// In zh, this message translates to:
  /// **'无下载源'**
  String get knode_app_no_download_source;

  /// 暂无考试记录
  ///
  /// In zh, this message translates to:
  /// **'暂无考试记录'**
  String get knode_app_no_exam_records;

  /// 还没有 Key？点击获取
  ///
  /// In zh, this message translates to:
  /// **'还没有 Key？点击获取'**
  String get knode_app_no_key_hint;

  /// 无可用本地备份
  ///
  /// In zh, this message translates to:
  /// **'无可用本地备份'**
  String get knode_app_no_local_backup;

  /// 暂无模型
  ///
  /// In zh, this message translates to:
  /// **'暂无模型'**
  String get knode_app_no_models;

  /// 暂无模板
  ///
  /// In zh, this message translates to:
  /// **'暂无模板'**
  String get knode_app_no_templates;

  /// 无可用 WebDAV 备份
  ///
  /// In zh, this message translates to:
  /// **'无可用 WebDAV 备份'**
  String get knode_app_no_webdav_backup;

  /// 暂无错题
  ///
  /// In zh, this message translates to:
  /// **'暂无错题'**
  String get knode_app_no_wrong_cards;

  /// 未作答
  ///
  /// In zh, this message translates to:
  /// **'未作答'**
  String get knode_app_not_answered;

  /// 通知
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get knode_app_notification;

  /// 选项:
  ///
  /// In zh, this message translates to:
  /// **'选项:'**
  String get knode_app_options_label;

  /// 原始模板
  ///
  /// In zh, this message translates to:
  /// **'原始模板'**
  String get knode_app_original_template;

  /// 原始模板已有变更
  ///
  /// In zh, this message translates to:
  /// **'原始模板已有变更'**
  String get knode_app_original_template_changed;

  /// 正在打包文件...
  ///
  /// In zh, this message translates to:
  /// **'正在打包文件...'**
  String get knode_app_packing_files;

  /// 密码
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get knode_app_password;

  /// 仅修改路径
  ///
  /// In zh, this message translates to:
  /// **'仅修改路径'**
  String get knode_app_path_only;

  /// 个人抽屉
  ///
  /// In zh, this message translates to:
  /// **'个人抽屉'**
  String get knode_app_personal_drawer;

  /// 端口号
  ///
  /// In zh, this message translates to:
  /// **'端口号'**
  String get knode_app_port;

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

  /// 备份完成
  ///
  /// In zh, this message translates to:
  /// **'备份完成'**
  String get knode_app_progress_backup_complete;

  /// 正在解压...
  ///
  /// In zh, this message translates to:
  /// **'正在解压...'**
  String get knode_app_progress_decompressing;

  /// 正在下载...
  ///
  /// In zh, this message translates to:
  /// **'正在下载...'**
  String get knode_app_progress_downloading;

  /// 正在打包文件...
  ///
  /// In zh, this message translates to:
  /// **'正在打包文件...'**
  String get knode_app_progress_packing;

  /// 恢复完成
  ///
  /// In zh, this message translates to:
  /// **'恢复完成'**
  String get knode_app_progress_restore_complete;

  /// 正在上传...
  ///
  /// In zh, this message translates to:
  /// **'正在上传...'**
  String get knode_app_progress_uploading;

  /// 编辑提示词模板...
  ///
  /// In zh, this message translates to:
  /// **'编辑提示词模板...'**
  String get knode_app_prompt_edit_hint;

  /// 阅卷评分
  ///
  /// In zh, this message translates to:
  /// **'阅卷评分'**
  String get knode_app_prompt_grader;

  /// 意图分析
  ///
  /// In zh, this message translates to:
  /// **'意图分析'**
  String get knode_app_prompt_intent;

  /// 提示词管理
  ///
  /// In zh, this message translates to:
  /// **'提示词管理'**
  String get knode_app_prompt_management;

  /// 管理 AI 提示词模板
  ///
  /// In zh, this message translates to:
  /// **'管理 AI 提示词模板'**
  String get knode_app_prompt_management_subtitle;

  /// 阶段考试
  ///
  /// In zh, this message translates to:
  /// **'阶段考试'**
  String get knode_app_prompt_periodic_exam;

  /// 变种出题
  ///
  /// In zh, this message translates to:
  /// **'变种出题'**
  String get knode_app_prompt_question_variant;

  /// 出题生成
  ///
  /// In zh, this message translates to:
  /// **'出题生成'**
  String get knode_app_prompt_quiz_gen;

  /// RAG 问答
  ///
  /// In zh, this message translates to:
  /// **'RAG 问答'**
  String get knode_app_prompt_rag_qa;

  /// 联网搜索
  ///
  /// In zh, this message translates to:
  /// **'联网搜索'**
  String get knode_app_prompt_search;

  /// 摘要生成
  ///
  /// In zh, this message translates to:
  /// **'摘要生成'**
  String get knode_app_prompt_summary;

  /// 标签生成
  ///
  /// In zh, this message translates to:
  /// **'标签生成'**
  String get knode_app_prompt_tag_gen;

  /// 快捷卡片
  ///
  /// In zh, this message translates to:
  /// **'快捷卡片'**
  String get knode_app_quick_card;

  /// 道待复习
  ///
  /// In zh, this message translates to:
  /// **'道待复习'**
  String get knode_app_quiz_due_review;

  /// 测验设置
  ///
  /// In zh, this message translates to:
  /// **'测验设置'**
  String get knode_app_quiz_settings;

  /// 速记已开始，请切换到[测验]标签查看
  ///
  /// In zh, this message translates to:
  /// **'速记已开始，请切换到[测验]标签查看'**
  String get knode_app_quiz_started_switch_tab;

  /// 评价应用
  ///
  /// In zh, this message translates to:
  /// **'评价应用'**
  String get knode_app_rate_us;

  /// 一键恢复所有
  ///
  /// In zh, this message translates to:
  /// **'一键恢复所有'**
  String get knode_app_reset_all;

  /// 所有自定义内容将丢失是否继续？
  ///
  /// In zh, this message translates to:
  /// **'所有自定义内容将丢失是否继续？'**
  String get knode_app_reset_all_confirm;

  /// 恢复默认
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get knode_app_reset_override;

  /// 将此模板恢复为默认值？
  ///
  /// In zh, this message translates to:
  /// **'将此模板恢复为默认值？'**
  String get knode_app_reset_single_confirm;

  /// 重置成功
  ///
  /// In zh, this message translates to:
  /// **'重置成功'**
  String get knode_app_reset_success;

  /// 恢复
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get knode_app_restore;

  /// 恢复
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get knode_app_restore_btn;

  /// 恢复完成
  ///
  /// In zh, this message translates to:
  /// **'恢复完成'**
  String get knode_app_restore_complete;

  /// 确定恢复到此备份版本？当前数据将被覆盖
  ///
  /// In zh, this message translates to:
  /// **'确定恢复到此备份版本？当前数据将被覆盖'**
  String get knode_app_restore_confirm;

  /// 恢复将覆盖当前数据，是否继续？
  ///
  /// In zh, this message translates to:
  /// **'恢复将覆盖当前数据，是否继续？'**
  String get knode_app_restore_confirm_msg;

  /// 恢复数据
  ///
  /// In zh, this message translates to:
  /// **'恢复数据'**
  String get knode_app_restore_data;

  /// 恢复失败
  ///
  /// In zh, this message translates to:
  /// **'恢复失败'**
  String get knode_app_restore_failed;

  /// 重试
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get knode_app_retry;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get knode_app_save;

  /// 已保存
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get knode_app_save_success;

  /// 成绩卡片
  ///
  /// In zh, this message translates to:
  /// **'成绩卡片'**
  String get knode_app_score_card;

  /// {n}分
  ///
  /// In zh, this message translates to:
  /// **'{n}分'**
  String knode_app_score_n_points(String n);

  /// 搜索 API Key
  ///
  /// In zh, this message translates to:
  /// **'搜索 API Key'**
  String get knode_app_search_api_key;

  /// 选择恢复来源
  ///
  /// In zh, this message translates to:
  /// **'选择恢复来源'**
  String get knode_app_select_restore_source;

  /// 选择恢复版本
  ///
  /// In zh, this message translates to:
  /// **'选择恢复版本'**
  String get knode_app_select_restore_version;

  /// 选择搜索服务商
  ///
  /// In zh, this message translates to:
  /// **'选择搜索服务商'**
  String get knode_app_select_search_provider;

  /// 服务设置
  ///
  /// In zh, this message translates to:
  /// **'服务设置'**
  String get knode_app_server_settings;

  /// 服务商
  ///
  /// In zh, this message translates to:
  /// **'服务商'**
  String get knode_app_service_provider;

  /// 会话共 {n} 条消息
  ///
  /// In zh, this message translates to:
  /// **'会话共 {n} 条消息'**
  String knode_app_session_n_messages(String n);

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

  /// 知维应用日志
  ///
  /// In zh, this message translates to:
  /// **'知维应用日志'**
  String get knode_app_share_logs_subject;

  /// 跳过内存兼容性检查
  ///
  /// In zh, this message translates to:
  /// **'跳过内存兼容性检查'**
  String get knode_app_skip_memory_check;

  /// 显示所有模型，不根据设备内存过滤
  ///
  /// In zh, this message translates to:
  /// **'显示所有模型，不根据设备内存过滤'**
  String get knode_app_skip_memory_check_desc;

  /// 声音
  ///
  /// In zh, this message translates to:
  /// **'声音'**
  String get knode_app_sound;

  /// 源文件不存在: {path}
  ///
  /// In zh, this message translates to:
  /// **'源文件不存在: {path}'**
  String knode_app_source_not_found(String path);

  /// 开始练习
  ///
  /// In zh, this message translates to:
  /// **'开始练习'**
  String get knode_app_start_practice;

  /// 新文档将保存到新位置
  ///
  /// In zh, this message translates to:
  /// **'新文档将保存到新位置'**
  String get knode_app_storage_migration_hint_1;

  /// 迁移会将已有 .md 文件复制到新目录
  ///
  /// In zh, this message translates to:
  /// **'迁移会将已有 .md 文件复制到新目录'**
  String get knode_app_storage_migration_hint_2;

  /// 原文件不会被删除，请手动清理
  ///
  /// In zh, this message translates to:
  /// **'原文件不会被删除，请手动清理'**
  String get knode_app_storage_migration_hint_3;

  /// 存储路径
  ///
  /// In zh, this message translates to:
  /// **'存储路径'**
  String get knode_app_storage_path;

  /// 管理知识库文件存储位置
  ///
  /// In zh, this message translates to:
  /// **'管理知识库文件存储位置'**
  String get knode_app_storage_path_subtitle;

  /// 存储路径已更新
  ///
  /// In zh, this message translates to:
  /// **'存储路径已更新'**
  String get knode_app_storage_path_updated;

  /// 存储设置
  ///
  /// In zh, this message translates to:
  /// **'存储设置'**
  String get knode_app_storage_settings;

  /// 存储空间
  ///
  /// In zh, this message translates to:
  /// **'存储空间'**
  String get knode_app_storage_space;

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

  /// 请切换到[测验]标签查看考试历史
  ///
  /// In zh, this message translates to:
  /// **'请切换到[测验]标签查看考试历史'**
  String get knode_app_switch_to_quiz_tab;

  /// 跟随系统
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get knode_app_system_default;

  /// 点击开始练习
  ///
  /// In zh, this message translates to:
  /// **'点击开始练习'**
  String get knode_app_tap_to_start;

  /// 测试连接
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get knode_app_test_connection;

  /// 测试中...
  ///
  /// In zh, this message translates to:
  /// **'测试中...'**
  String get knode_app_testing;

  /// 主题
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get knode_app_theme;

  /// 未命名文档
  ///
  /// In zh, this message translates to:
  /// **'未命名文档'**
  String get knode_app_unnamed_document;

  /// 上传失败
  ///
  /// In zh, this message translates to:
  /// **'上传失败'**
  String get knode_app_upload_failed;

  /// 正在上传...
  ///
  /// In zh, this message translates to:
  /// **'正在上传...'**
  String get knode_app_uploading;

  /// 账号
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get knode_app_user;

  /// 用户
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get knode_app_user_label;

  /// 变量
  ///
  /// In zh, this message translates to:
  /// **'变量'**
  String get knode_app_variables;

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

  /// 查看日志
  ///
  /// In zh, this message translates to:
  /// **'查看日志'**
  String get knode_app_view_logs;

  /// 查看运行日志、错误记录
  ///
  /// In zh, this message translates to:
  /// **'查看运行日志、错误记录'**
  String get knode_app_view_operation_logs_and_error_records;

  /// 查看原文
  ///
  /// In zh, this message translates to:
  /// **'查看原文'**
  String get knode_app_view_source;

  /// 联网搜索
  ///
  /// In zh, this message translates to:
  /// **'联网搜索'**
  String get knode_app_web_search;

  /// 搜索服务商、API Key 配置
  ///
  /// In zh, this message translates to:
  /// **'搜索服务商、API Key 配置'**
  String get knode_app_web_search_subtitle;

  /// WebDAV
  ///
  /// In zh, this message translates to:
  /// **'WebDAV'**
  String get knode_app_webdav;

  /// WebDAV 上次备份: {time}
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 上次备份: {time}'**
  String knode_app_webdav_last_backup(String time);

  /// WebDAV 未配置
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 未配置'**
  String get knode_app_webdav_not_configured;

  /// WebDAV 恢复
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 恢复'**
  String get knode_app_webdav_restore;

  /// WebDAV 服务器
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 服务器'**
  String get knode_app_webdav_server;

  /// WebDAV / 本地备份
  ///
  /// In zh, this message translates to:
  /// **'WebDAV / 本地备份'**
  String get knode_app_webdav_subtitle;

  /// 每周
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get knode_app_weekly;

  /// 每周
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get knode_app_weekly_label;

  /// 欢迎回来
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来'**
  String get knode_app_welcome_back;

  /// Wiki 设置
  ///
  /// In zh, this message translates to:
  /// **'Wiki 设置'**
  String get knode_app_wiki_settings;

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

  /// 添加笔记
  ///
  /// In zh, this message translates to:
  /// **'添加笔记'**
  String get quiz_add_note;

  /// 启用 AI 出题
  ///
  /// In zh, this message translates to:
  /// **'启用 AI 出题'**
  String get quiz_ai_enabled;

  /// AI 讲解
  ///
  /// In zh, this message translates to:
  /// **'AI 讲解'**
  String get quiz_ai_explanation;

  /// 固定 AI 比例
  ///
  /// In zh, this message translates to:
  /// **'固定 AI 比例'**
  String get quiz_ai_fixed_ratio;

  /// 固定比例
  ///
  /// In zh, this message translates to:
  /// **'固定比例'**
  String get quiz_ai_ratio_fixed;

  /// AI 出题: {percent}%
  ///
  /// In zh, this message translates to:
  /// **'AI 出题: {percent}%'**
  String quiz_ai_ratio_label(String percent);

  /// AI 出题比例模式
  ///
  /// In zh, this message translates to:
  /// **'AI 出题比例模式'**
  String get quiz_ai_ratio_mode;

  /// 智能比例
  ///
  /// In zh, this message translates to:
  /// **'智能比例'**
  String get quiz_ai_ratio_smart;

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

  /// 已答 {current}/{total} 题
  ///
  /// In zh, this message translates to:
  /// **'已答 {current}/{total} 题'**
  String quiz_answered_n_of_m(String current, String total);

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

  /// 每日一测题目数量
  ///
  /// In zh, this message translates to:
  /// **'每日一测题目数量'**
  String get quiz_daily_count;

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

  /// 每日一测出题范围
  ///
  /// In zh, this message translates to:
  /// **'每日一测出题范围'**
  String get quiz_daily_scope;

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

  /// 考试历史
  ///
  /// In zh, this message translates to:
  /// **'考试历史'**
  String get quiz_exam_history;

  /// 考试不存在
  ///
  /// In zh, this message translates to:
  /// **'考试不存在'**
  String get quiz_exam_not_found;

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

  /// 输入答案
  ///
  /// In zh, this message translates to:
  /// **'输入答案'**
  String get quiz_input_answer;

  /// 输入你的回答...
  ///
  /// In zh, this message translates to:
  /// **'输入你的回答...'**
  String get quiz_input_your_answer;

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

  /// 补考截止
  ///
  /// In zh, this message translates to:
  /// **'补考截止'**
  String get quiz_makeup_deadline;

  /// 补考
  ///
  /// In zh, this message translates to:
  /// **'补考'**
  String get quiz_makeup_exam;

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

  /// 错过考试
  ///
  /// In zh, this message translates to:
  /// **'错过考试'**
  String get quiz_missed_exam;

  /// 每月综合测验
  ///
  /// In zh, this message translates to:
  /// **'每月综合测验'**
  String get quiz_monthly_comprehensive_quiz;

  /// 月考题目数量
  ///
  /// In zh, this message translates to:
  /// **'月考题目数量'**
  String get quiz_monthly_count;

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

  /// 未作答
  ///
  /// In zh, this message translates to:
  /// **'未作答'**
  String get quiz_not_answered;

  /// 输入笔记内容...
  ///
  /// In zh, this message translates to:
  /// **'输入笔记内容...'**
  String get quiz_note_input_hint;

  /// 选项
  ///
  /// In zh, this message translates to:
  /// **'选项'**
  String get quiz_options;

  /// 选项:
  ///
  /// In zh, this message translates to:
  /// **'选项:'**
  String get quiz_options_label;

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

  /// 季考题目数量
  ///
  /// In zh, this message translates to:
  /// **'季考题目数量'**
  String get quiz_quarterly_count;

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

  /// 第 {current}/{total} 题
  ///
  /// In zh, this message translates to:
  /// **'第 {current}/{total} 题'**
  String quiz_question_n_of_m(String current, String total);

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

  /// 出题设置
  ///
  /// In zh, this message translates to:
  /// **'出题设置'**
  String get quiz_quiz_config;

  /// 测验类型
  ///
  /// In zh, this message translates to:
  /// **'测验类型'**
  String get quiz_quiz_types;

  /// 随机速记题目数量
  ///
  /// In zh, this message translates to:
  /// **'随机速记题目数量'**
  String get quiz_random_count;

  /// 随机速记天数范围
  ///
  /// In zh, this message translates to:
  /// **'随机速记天数范围'**
  String get quiz_random_days;

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

  /// 考试提醒时间
  ///
  /// In zh, this message translates to:
  /// **'考试提醒时间'**
  String get quiz_reminder_hour;

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

  /// 温故知新题目数量
  ///
  /// In zh, this message translates to:
  /// **'温故知新题目数量'**
  String get quiz_review_count;

  /// 温故知新错题比例
  ///
  /// In zh, this message translates to:
  /// **'温故知新错题比例'**
  String get quiz_review_wrong_ratio;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get quiz_save;

  /// 保存设置
  ///
  /// In zh, this message translates to:
  /// **'保存设置'**
  String get quiz_save_settings;

  /// 全部题库
  ///
  /// In zh, this message translates to:
  /// **'全部题库'**
  String get quiz_scope_all;

  /// 指定类目
  ///
  /// In zh, this message translates to:
  /// **'指定类目'**
  String get quiz_scope_category;

  /// 最近阅读
  ///
  /// In zh, this message translates to:
  /// **'最近阅读'**
  String get quiz_scope_days;

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

  /// 跳过
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get quiz_skip;

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

  /// 启用变种出题
  ///
  /// In zh, this message translates to:
  /// **'启用变种出题'**
  String get quiz_variant_enabled;

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

  /// 年考题目数量
  ///
  /// In zh, this message translates to:
  /// **'年考题目数量'**
  String get quiz_yearly_count;

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

  /// 添加书签
  ///
  /// In zh, this message translates to:
  /// **'添加书签'**
  String get wiki_add_bookmark;

  /// 添加类目
  ///
  /// In zh, this message translates to:
  /// **'添加类目'**
  String get wiki_add_category;

  /// 添加类目功能开发中
  ///
  /// In zh, this message translates to:
  /// **'添加类目功能开发中'**
  String get wiki_add_category_in_dev;

  /// 添加引用
  ///
  /// In zh, this message translates to:
  /// **'添加引用'**
  String get wiki_add_citation;

  /// 添加高亮
  ///
  /// In zh, this message translates to:
  /// **'添加高亮'**
  String get wiki_add_highlight;

  /// 添加笔记
  ///
  /// In zh, this message translates to:
  /// **'添加笔记'**
  String get wiki_add_note;

  /// 添加标签
  ///
  /// In zh, this message translates to:
  /// **'添加标签'**
  String get wiki_add_tag;

  /// AI 讲解
  ///
  /// In zh, this message translates to:
  /// **'AI 讲解'**
  String get wiki_ai_explanation;

  /// AI 讲解失败
  ///
  /// In zh, this message translates to:
  /// **'AI 讲解失败'**
  String get wiki_ai_explanation_failed;

  /// 全部文档
  ///
  /// In zh, this message translates to:
  /// **'全部文档'**
  String get wiki_all_documents;

  /// 全部知识
  ///
  /// In zh, this message translates to:
  /// **'全部知识'**
  String get wiki_all_knowledge;

  /// 答对  /  题
  ///
  /// In zh, this message translates to:
  /// **'答对  /  题'**
  String get wiki_answer_correct_n;

  /// 问问AI
  ///
  /// In zh, this message translates to:
  /// **'问问AI'**
  String get wiki_ask_ai;

  /// 自动为新文档生成标签
  ///
  /// In zh, this message translates to:
  /// **'自动为新文档生成标签'**
  String get wiki_auto_generate_tags;

  /// 已自动保存
  ///
  /// In zh, this message translates to:
  /// **'已自动保存'**
  String get wiki_auto_saved;

  /// 背景色
  ///
  /// In zh, this message translates to:
  /// **'背景色'**
  String get wiki_background;

  /// 书签
  ///
  /// In zh, this message translates to:
  /// **'书签'**
  String get wiki_bookmark;

  /// 浏览器搜索
  ///
  /// In zh, this message translates to:
  /// **'浏览器搜索'**
  String get wiki_browser_search;

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

  /// 类目名称
  ///
  /// In zh, this message translates to:
  /// **'类目名称'**
  String get wiki_category_name;

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

  /// 关闭
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get wiki_close;

  /// 确认
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get wiki_confirm;

  /// 已复制到剪贴板
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get wiki_copied_to_clipboard;

  /// 复制
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get wiki_copy;

  /// 创建节点
  ///
  /// In zh, this message translates to:
  /// **'创建节点'**
  String get wiki_create_node;

  /// 深色
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get wiki_dark;

  /// 删除
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get wiki_delete;

  /// 删除类目
  ///
  /// In zh, this message translates to:
  /// **'删除类目'**
  String get wiki_delete_category;

  /// 确定删除「{name}」？子类目将移至根目录。
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」？子类目将移至根目录。'**
  String wiki_delete_category_confirm(String name);

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

  /// 文档名称
  ///
  /// In zh, this message translates to:
  /// **'文档名称'**
  String get wiki_document_name;

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

  /// 编辑类目功能开发中
  ///
  /// In zh, this message translates to:
  /// **'编辑类目功能开发中'**
  String get wiki_edit_category_in_dev;

  /// 编辑文档
  ///
  /// In zh, this message translates to:
  /// **'编辑文档'**
  String get wiki_edit_document;

  /// 编辑标签
  ///
  /// In zh, this message translates to:
  /// **'编辑标签'**
  String get wiki_edit_tags;

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

  /// 解释
  ///
  /// In zh, this message translates to:
  /// **'解释'**
  String get wiki_explain_text;

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

  /// 护眼
  ///
  /// In zh, this message translates to:
  /// **'护眼'**
  String get wiki_eye_care;

  /// 开发中
  ///
  /// In zh, this message translates to:
  /// **'开发中'**
  String get wiki_feature_development;

  /// 功能开发中
  ///
  /// In zh, this message translates to:
  /// **'功能开发中'**
  String get wiki_feature_in_development;

  /// 字号
  ///
  /// In zh, this message translates to:
  /// **'字号'**
  String get wiki_font_size;

  /// 全文搜索
  ///
  /// In zh, this message translates to:
  /// **'全文搜索'**
  String get wiki_fulltext_search;

  /// 基于以下内容生成
  ///
  /// In zh, this message translates to:
  /// **'基于以下内容生成'**
  String get wiki_generate_based;

  /// 生成题目
  ///
  /// In zh, this message translates to:
  /// **'生成题目'**
  String get wiki_generate_question;

  /// 生成的题目
  ///
  /// In zh, this message translates to:
  /// **'生成的题目'**
  String get wiki_generated_questions;

  /// 正在生成 AI 讲解...
  ///
  /// In zh, this message translates to:
  /// **'正在生成 AI 讲解...'**
  String get wiki_generating_ai_explanation;

  /// 正在生成题目...
  ///
  /// In zh, this message translates to:
  /// **'正在生成题目...'**
  String get wiki_generating_questions;

  /// 图谱画布
  ///
  /// In zh, this message translates to:
  /// **'图谱画布'**
  String get wiki_graph_canvas;

  /// 图谱画布（开发中）
  ///
  /// In zh, this message translates to:
  /// **'图谱画布（开发中）'**
  String get wiki_graph_canvas_pending;

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

  /// 高亮
  ///
  /// In zh, this message translates to:
  /// **'高亮'**
  String get wiki_highlight;

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

  /// 输入答案
  ///
  /// In zh, this message translates to:
  /// **'输入答案'**
  String get wiki_input_answer;

  /// 输入单词查询释义
  ///
  /// In zh, this message translates to:
  /// **'输入单词查询释义'**
  String get wiki_input_word_hint;

  /// 输入你的回答...
  ///
  /// In zh, this message translates to:
  /// **'输入你的回答...'**
  String get wiki_input_your_answer;

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

  /// 知识库搜索
  ///
  /// In zh, this message translates to:
  /// **'知识库搜索'**
  String get wiki_knowledge_search;

  /// 浅色
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get wiki_light;

  /// 行距
  ///
  /// In zh, this message translates to:
  /// **'行距'**
  String get wiki_line_spacing;

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

  /// 页边距
  ///
  /// In zh, this message translates to:
  /// **'页边距'**
  String get wiki_margin;

  /// Markdown 源码...
  ///
  /// In zh, this message translates to:
  /// **'Markdown 源码...'**
  String get wiki_markdown_source;

  /// 分钟
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get wiki_min;

  /// 移动到
  ///
  /// In zh, this message translates to:
  /// **'移动到'**
  String get wiki_move_to;

  /// 新建文档
  ///
  /// In zh, this message translates to:
  /// **'新建文档'**
  String get wiki_new_document;

  /// 下一个匹配
  ///
  /// In zh, this message translates to:
  /// **'下一个匹配'**
  String get wiki_next_match;

  /// 夜间模式
  ///
  /// In zh, this message translates to:
  /// **'夜间模式'**
  String get wiki_night_mode;

  /// 暂无书签
  ///
  /// In zh, this message translates to:
  /// **'暂无书签'**
  String get wiki_no_bookmarks;

  /// 暂无类目
  ///
  /// In zh, this message translates to:
  /// **'暂无类目'**
  String get wiki_no_categories;

  /// 暂无文档
  ///
  /// In zh, this message translates to:
  /// **'暂无文档'**
  String get wiki_no_documents;

  /// (DOCX 文件无文本内容)
  ///
  /// In zh, this message translates to:
  /// **'(DOCX 文件无文本内容)'**
  String get wiki_no_docx_text;

  /// 暂无标题
  ///
  /// In zh, this message translates to:
  /// **'暂无标题'**
  String get wiki_no_headings;

  /// 暂无高亮
  ///
  /// In zh, this message translates to:
  /// **'暂无高亮'**
  String get wiki_no_highlights;

  /// 暂无标签
  ///
  /// In zh, this message translates to:
  /// **'暂无标签'**
  String get wiki_no_tags;

  /// (PDF 文件无文本内容，可能为扫描件)
  ///
  /// In zh, this message translates to:
  /// **'(PDF 文件无文本内容，可能为扫描件)'**
  String get wiki_no_text_content;

  /// 暂无标题
  ///
  /// In zh, this message translates to:
  /// **'暂无标题'**
  String get wiki_no_titles;

  /// 节点名称
  ///
  /// In zh, this message translates to:
  /// **'节点名称'**
  String get wiki_node_name;

  /// 备注
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get wiki_note;

  /// 笔记文档
  ///
  /// In zh, this message translates to:
  /// **'笔记文档'**
  String get wiki_note_document;

  /// 输入笔记内容...
  ///
  /// In zh, this message translates to:
  /// **'输入笔记内容...'**
  String get wiki_note_input_hint;

  /// 笔记已保存
  ///
  /// In zh, this message translates to:
  /// **'笔记已保存'**
  String get wiki_note_saved;

  /// 笔记
  ///
  /// In zh, this message translates to:
  /// **'笔记'**
  String get wiki_notes;

  /// 目录
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get wiki_outline;

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

  /// 请解释以下内容
  ///
  /// In zh, this message translates to:
  /// **'请解释以下内容'**
  String get wiki_please_explain;

  /// 上一个匹配
  ///
  /// In zh, this message translates to:
  /// **'上一个匹配'**
  String get wiki_prev_match;

  /// 题目生成失败
  ///
  /// In zh, this message translates to:
  /// **'题目生成失败'**
  String get wiki_question_generation_failed;

  /// 朗读
  ///
  /// In zh, this message translates to:
  /// **'朗读'**
  String get wiki_read_aloud;

  /// 阅读器
  ///
  /// In zh, this message translates to:
  /// **'阅读器'**
  String get wiki_reader;

  /// 问问AI
  ///
  /// In zh, this message translates to:
  /// **'问问AI'**
  String get wiki_reader_ask_ai;

  /// 书签
  ///
  /// In zh, this message translates to:
  /// **'书签'**
  String get wiki_reader_bookmark;

  /// 浏览器搜索
  ///
  /// In zh, this message translates to:
  /// **'浏览器搜索'**
  String get wiki_reader_browser_search;

  /// 复制
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get wiki_reader_copy;

  /// 字典
  ///
  /// In zh, this message translates to:
  /// **'字典'**
  String get wiki_reader_dictionary;

  /// 全文搜索
  ///
  /// In zh, this message translates to:
  /// **'全文搜索'**
  String get wiki_reader_full_text_search;

  /// 划重点
  ///
  /// In zh, this message translates to:
  /// **'划重点'**
  String get wiki_reader_highlight_note;

  /// 知识库搜索
  ///
  /// In zh, this message translates to:
  /// **'知识库搜索'**
  String get wiki_reader_kb_search;

  /// 朗读
  ///
  /// In zh, this message translates to:
  /// **'朗读'**
  String get wiki_reader_read_aloud;

  /// 阅读器工具栏
  ///
  /// In zh, this message translates to:
  /// **'阅读器工具栏'**
  String get wiki_reader_toolbar;

  /// 阅读设置
  ///
  /// In zh, this message translates to:
  /// **'阅读设置'**
  String get wiki_reading_settings;

  /// 重命名
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get wiki_rename;

  /// 重命名类目
  ///
  /// In zh, this message translates to:
  /// **'重命名类目'**
  String get wiki_rename_category;

  /// 重置标签
  ///
  /// In zh, this message translates to:
  /// **'重置标签'**
  String get wiki_reset_tags;

  /// 确定重置标签？AI 生成的标签将被清除
  ///
  /// In zh, this message translates to:
  /// **'确定重置标签？AI 生成的标签将被清除'**
  String get wiki_reset_tags_confirm;

  /// 根目录
  ///
  /// In zh, this message translates to:
  /// **'根目录'**
  String get wiki_root_directory;

  /// 保存
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get wiki_save;

  /// 分
  ///
  /// In zh, this message translates to:
  /// **'分'**
  String get wiki_score_suffix;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get wiki_search;

  /// 搜索文档...
  ///
  /// In zh, this message translates to:
  /// **'搜索文档...'**
  String get wiki_search_document;

  /// 搜索单词
  ///
  /// In zh, this message translates to:
  /// **'搜索单词'**
  String get wiki_search_word;

  /// 跳过
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get wiki_skip;

  /// 学习资料
  ///
  /// In zh, this message translates to:
  /// **'学习资料'**
  String get wiki_study_materials;

  /// 样式
  ///
  /// In zh, this message translates to:
  /// **'样式'**
  String get wiki_style;

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

  /// 切换到富文本模式
  ///
  /// In zh, this message translates to:
  /// **'切换到富文本模式'**
  String get wiki_switch_to_rich;

  /// 切换到源码模式
  ///
  /// In zh, this message translates to:
  /// **'切换到源码模式'**
  String get wiki_switch_to_source;

  /// 你是一个善于清晰解释知识的助手。请以清晰、有条理的方式解释以下内容。
  ///
  /// In zh, this message translates to:
  /// **'你是一个善于清晰解释知识的助手。请以清晰、有条理的方式解释以下内容。'**
  String get wiki_system_prompt_explain;

  /// 标签已生成
  ///
  /// In zh, this message translates to:
  /// **'标签已生成'**
  String get wiki_tag_generated;

  /// 标签生成失败
  ///
  /// In zh, this message translates to:
  /// **'标签生成失败'**
  String get wiki_tag_generation_failed;

  /// 标签
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get wiki_tags;

  /// 点击选择
  ///
  /// In zh, this message translates to:
  /// **'点击选择'**
  String get wiki_tap_to_select;

  /// 文字转语音
  ///
  /// In zh, this message translates to:
  /// **'文字转语音'**
  String get wiki_text_to_speech;

  /// 主题
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get wiki_theme;

  /// 目录
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get wiki_toc;

  /// 今天阅读
  ///
  /// In zh, this message translates to:
  /// **'今天阅读'**
  String get wiki_today_reading;

  /// 总阅读
  ///
  /// In zh, this message translates to:
  /// **'总阅读'**
  String get wiki_total_reading;

  /// 朗读
  ///
  /// In zh, this message translates to:
  /// **'朗读'**
  String get wiki_tts;

  /// 下划线
  ///
  /// In zh, this message translates to:
  /// **'下划线'**
  String get wiki_underline;

  /// 查看原文
  ///
  /// In zh, this message translates to:
  /// **'查看原文'**
  String get wiki_view_source;

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
