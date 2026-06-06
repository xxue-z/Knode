// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get chat_add_attachment => '添加附件';

  @override
  String get chat_add_attachment_label => '添加附件';

  @override
  String get chat_ai_assistant => 'AI 助手';

  @override
  String get chat_ai_chat => 'AI 对话';

  @override
  String get chat_answer => '回答';

  @override
  String get chat_archive => '归档';

  @override
  String get chat_archive_failed => '归档失败';

  @override
  String get chat_archive_in_detail => '归档功能需在会话详情页中使用';

  @override
  String get chat_archive_title => '会话归档';

  @override
  String get chat_cancel => '取消';

  @override
  String get chat_chat => '对话';

  @override
  String get chat_citation => '引用';

  @override
  String get chat_clear_history => '清除历史';

  @override
  String get chat_clear_history_dev => '清空对话功能开发中';

  @override
  String get chat_clear_in_dev => '清空对话功能开发中';

  @override
  String get chat_confirm => '确认';

  @override
  String get chat_connection_failed => '连接失败';

  @override
  String get chat_connection_success => '连接成功';

  @override
  String get chat_copied => '已复制';

  @override
  String get chat_copy => '复制';

  @override
  String get chat_current_session => '当前会话';

  @override
  String get chat_delete_conversation => '删除对话';

  @override
  String get chat_document => '文档';

  @override
  String get chat_document_dev => '文档选择功能开发中';

  @override
  String get chat_document_in_dev => '文档选择功能开发中';

  @override
  String get chat_document_label => '文档';

  @override
  String get chat_error => '错误';

  @override
  String get chat_export_chat => '导出对话';

  @override
  String get chat_history_conversations => '历史会话';

  @override
  String get chat_history_in_dev => '历史会话功能开发中';

  @override
  String get chat_history_sessions => '历史会话';

  @override
  String get chat_history_sessions_dev => '历史会话功能开发中';

  @override
  String get chat_image => '图片';

  @override
  String get chat_image_dev => '图片选择功能开发中';

  @override
  String get chat_image_in_dev => '图片选择功能开发中';

  @override
  String get chat_image_label => '图片';

  @override
  String get chat_input_message => '输入消息...';

  @override
  String get chat_intent_recognition => '意图识别';

  @override
  String get chat_knowledge_base => '知识库';

  @override
  String get chat_link => '链接';

  @override
  String get chat_link_dev => '链接粘贴功能开发中';

  @override
  String get chat_link_in_dev => '链接粘贴功能开发中';

  @override
  String get chat_link_label => '链接';

  @override
  String get chat_load_failed => '加载失败';

  @override
  String get chat_loading => '加载中...';

  @override
  String get chat_message => '消息';

  @override
  String get chat_need_ai_provider => '消息发送功能需连接 AIProvider';

  @override
  String get chat_new_conversation => '新建对话';

  @override
  String get chat_no_conversations => '暂无对话，开始新对话吧';

  @override
  String get chat_no_conversations_yet => '暂无对话';

  @override
  String get chat_please_override_in_main_dart => '请在 main.dart 中覆盖';

  @override
  String get chat_qa => '问答';

  @override
  String get chat_question => '问题';

  @override
  String get chat_rag_search => 'RAG 搜索';

  @override
  String get chat_related_documents => '相关文档';

  @override
  String get chat_rename_conversation => '重命名对话';

  @override
  String get chat_rename_label => '重命名';

  @override
  String get chat_retry => '重试';

  @override
  String get chat_save => '保存';

  @override
  String get chat_search => '搜索';

  @override
  String get chat_search_api_key => '搜索 API Key';

  @override
  String get chat_search_config => '搜索配置';

  @override
  String get chat_search_provider => '搜索服务商';

  @override
  String get chat_select_category => '选择类目';

  @override
  String get chat_select_target_category => '选择目标类目:';

  @override
  String get chat_send => '发送';

  @override
  String get chat_send_message => '发送消息';

  @override
  String get chat_send_message_label => '发送消息';

  @override
  String get chat_send_message_need_ai => '消息发送功能需连接 AIProvider';

  @override
  String chat_session_n_messages(String n) {
    return '会话共 $n 条消息';
  }

  @override
  String get chat_sources => '来源';

  @override
  String get chat_start_conversation_hint => '发送消息开始与 AI 助手对话';

  @override
  String get chat_test_connection => '测试连接';

  @override
  String get chat_token_usage => 'Token 用量';

  @override
  String get chat_user_label => '用户';

  @override
  String get chat_voice_input => '语音输入';

  @override
  String get chat_voice_input_label => '语音输入';

  @override
  String get chat_voice_real_device => '语音输入功能需在真机上使用';

  @override
  String get chat_voice_real_device_label => '语音输入功能需在真机上使用';

  @override
  String get chat_web => '联网';

  @override
  String get chat_web_search => '联网搜索';

  @override
  String get core_ai_role => 'AI';

  @override
  String get core_answer => '答案';

  @override
  String get core_anthropic_embedding_not_supported =>
      'Anthropic API 不支持 Embedding，请使用 OpenAI 兼容接口';

  @override
  String get core_api_rate_limited => 'API 限流，请稍后重试';

  @override
  String get core_available_memory => '可用内存';

  @override
  String get core_back => '返回';

  @override
  String get core_backup => '备份';

  @override
  String get core_cancel => '取消';

  @override
  String get core_category => '类目';

  @override
  String get core_confirm => '确认';

  @override
  String get core_continue_import => '继续导入';

  @override
  String get core_conversation => '对话';

  @override
  String get core_conversation_empty_archive => '会话为空无法归档';

  @override
  String get core_conversation_not_found => '会话不存在';

  @override
  String get core_daily_quiz => '每日一测';

  @override
  String get core_delete => '删除';

  @override
  String get core_document => '文档';

  @override
  String get core_download_failed => '下载失败';

  @override
  String get core_edit => '编辑';

  @override
  String get core_embedding_generation_failed => 'Embedding 生成失败';

  @override
  String get core_error => '错误';

  @override
  String get core_exam => '考试';

  @override
  String get core_exam_not_found => '考试不存在';

  @override
  String get core_feedback => '反馈';

  @override
  String get core_fill_in_the_blank => '填空题';

  @override
  String get core_grading_failed => '评分失败';

  @override
  String get core_grading_result_parsing_failed => '评分解析失败';

  @override
  String get core_invalid_api_id => 'API Key 无效';

  @override
  String get core_json_parse_failed => 'JSON 解析失败';

  @override
  String get core_knowledge_base => '知识库';

  @override
  String get core_loading => '加载中...';

  @override
  String get core_loading_failed => '加载失败';

  @override
  String get core_local_import => '本地导入';

  @override
  String get core_local_model_loading_failed => '本地模型加载失败';

  @override
  String get core_local_model_not_loaded => '本地模型未加载，请先调用 loadModel()';

  @override
  String get core_memory_insufficient => '内存不足';

  @override
  String get core_message => '消息';

  @override
  String get core_mirror_china => '国内';

  @override
  String get core_mirror_global => '国际';

  @override
  String get core_model_delete => '删除';

  @override
  String get core_model_download => '下载';

  @override
  String get core_model_in_use => '使用中';

  @override
  String get core_model_load => '加载';

  @override
  String get core_model_loaded => '已加载';

  @override
  String core_model_may_not_run(String size, String mem) {
    return '该模型约 $size，你的设备内存为 $mem，可能无法正常运行';
  }

  @override
  String get core_model_no_download_source => '无下载源';

  @override
  String get core_model_not_compatible => '不可用（内存不足）';

  @override
  String core_model_requires_ram(String minRam) {
    return '需 $minRam RAM';
  }

  @override
  String get core_model_retry => '重试';

  @override
  String get core_monthly_exam_2 => '月度考试';

  @override
  String get core_multiple_choice => '多选题';

  @override
  String get core_network_request_failed => '网络请求失败';

  @override
  String get core_new => '新建';

  @override
  String get core_no => '否';

  @override
  String get core_ok => '确定';

  @override
  String get core_please_override_in_main_dart => '请在 main.dart 中覆盖';

  @override
  String get core_profile => '个人中心';

  @override
  String get core_progress_backup_complete => '备份完成';

  @override
  String get core_progress_decompressing => '正在解压...';

  @override
  String get core_progress_downloading => '正在下载...';

  @override
  String get core_progress_packing => '正在打包文件...';

  @override
  String get core_progress_restore_complete => '恢复完成';

  @override
  String get core_progress_uploading => '正在上传...';

  @override
  String get core_quarterly_exam_2 => '季度考试';

  @override
  String get core_question => '题目';

  @override
  String get core_quiz => '测验';

  @override
  String get core_random_quick_review => '随机抽取快速复习';

  @override
  String get core_reading => '阅读';

  @override
  String get core_remote_sync_failed => '远程同步失败';

  @override
  String get core_remote_template_format_error => '远程模板格式错误';

  @override
  String get core_request_failed => '请求失败';

  @override
  String get core_restore => '恢复';

  @override
  String get core_retry => '重试';

  @override
  String get core_save => '保存';

  @override
  String get core_score => '分数';

  @override
  String get core_search => '搜索';

  @override
  String get core_send => '发送';

  @override
  String get core_service_unavailable => '服务暂时不可用，请稍后重试';

  @override
  String get core_settings => '设置';

  @override
  String get core_short_answer => '简答题';

  @override
  String get core_single_choice => '单选题';

  @override
  String get core_statistics => '统计';

  @override
  String get core_success => '成功';

  @override
  String get core_tap_to_start_answering => '点击开始答题';

  @override
  String get core_today_quiz_ready => '今日测验已准备好，点击开始答题';

  @override
  String get core_total_memory => '设备总内存';

  @override
  String get core_true_false => '判断题';

  @override
  String get core_unnamed_document => '未命名文档';

  @override
  String get core_user_role => '用户';

  @override
  String get core_webdav_not_configured => 'WebDAV 未配置';

  @override
  String get core_wrong_question_review => '错题重练';

  @override
  String get core_yearly_exam_2 => '年度考试';

  @override
  String get core_yes => '是';

  @override
  String get knode_app_about => '关于';

  @override
  String get knode_app_account => '账号';

  @override
  String get knode_app_advanced_settings => '高级设置';

  @override
  String get knode_app_ai_engine => 'AI 引擎';

  @override
  String get knode_app_ai_engine_subtitle => '本地模型管理、云端 API 配置';

  @override
  String get knode_app_ai_label => 'AI';

  @override
  String get knode_app_ai_settings => 'AI 设置';

  @override
  String get knode_app_api_base_url => '接口地址';

  @override
  String get knode_app_api_protocol => 'API 协议';

  @override
  String get knode_app_app_shell => '应用外壳';

  @override
  String get knode_app_application_log => '应用日志';

  @override
  String get knode_app_archive_title => '会话归档';

  @override
  String get knode_app_auto_backup => '自动备份';

  @override
  String knode_app_available_memory(String memory) {
    return '可用内存: $memory MB';
  }

  @override
  String get knode_app_available_memory_label => '可用内存';

  @override
  String get knode_app_backup => '备份';

  @override
  String get knode_app_backup_complete => '备份完成';

  @override
  String get knode_app_backup_failed => '备份失败';

  @override
  String get knode_app_backup_frequency => '备份频率';

  @override
  String get knode_app_backup_frequency_label => '定时备份频率';

  @override
  String get knode_app_backup_history => '备份历史';

  @override
  String get knode_app_backup_now => '立即备份';

  @override
  String get knode_app_backup_now_label => '立即备份';

  @override
  String get knode_app_backup_settings => '备份设置';

  @override
  String get knode_app_backup_type_local => '本地';

  @override
  String get knode_app_backup_type_webdav => 'WebDAV';

  @override
  String get knode_app_based_on_recent => '基于最近阅读文件出题';

  @override
  String get knode_app_both_not_configured => '未配置备份目标，请配置 WebDAV 或本地备份';

  @override
  String get knode_app_bottom_navigation => '底部导航';

  @override
  String get knode_app_browse_history => '浏览历史';

  @override
  String get knode_app_cancel => '取消';

  @override
  String get knode_app_check_update => '检查更新';

  @override
  String get knode_app_checksum_failed => '文件校验失败，请重新下载';

  @override
  String get knode_app_clear_cache => '清除缓存';

  @override
  String get knode_app_cloud_api => '云端 API';

  @override
  String get knode_app_cloud_api_label => '云端 API';

  @override
  String get knode_app_cloud_config => '云配置';

  @override
  String get knode_app_cloud_model_repo_url => '云模型仓库地址';

  @override
  String get knode_app_cloud_model_repo_url_label => '云模型仓库地址';

  @override
  String get knode_app_cloud_sync => '云同步';

  @override
  String get knode_app_config_api_key_first => '请先配置 API Key';

  @override
  String get knode_app_confirm => '确认';

  @override
  String get knode_app_confirm_restore => '确认恢复';

  @override
  String get knode_app_connection_failed => '连接失败';

  @override
  String get knode_app_connection_success => '连接成功';

  @override
  String get knode_app_copied_to_clipboard => '已复制到剪贴板';

  @override
  String get knode_app_copy => '复制';

  @override
  String knode_app_correct_n_of_m(String n, String m) {
    return '答对 $n / $m 题';
  }

  @override
  String get knode_app_current_storage_path => '当前存储路径';

  @override
  String get knode_app_custom => '已自定义';

  @override
  String get knode_app_custom_label => '自定义...';

  @override
  String get knode_app_daily => '每天';

  @override
  String get knode_app_daily_card => '每日卡片';

  @override
  String get knode_app_daily_encouragement => '今天也要坚持学习哦';

  @override
  String get knode_app_daily_label => '每天';

  @override
  String get knode_app_daily_quiz_started => '每日一测已开始，请切换到[测验]标签查看';

  @override
  String get knode_app_dark_mode => '深色模式';

  @override
  String get knode_app_decompressing => '正在解压...';

  @override
  String get knode_app_default_exam_title => '考试';

  @override
  String get knode_app_delete => '删除';

  @override
  String get knode_app_delete_backup_confirm => '确定删除此备份？';

  @override
  String get knode_app_delete_failed => '删除失败';

  @override
  String get knode_app_description => '说明';

  @override
  String get knode_app_download_failed => '下载失败';

  @override
  String get knode_app_download_label => '下载';

  @override
  String get knode_app_downloading => '正在下载...';

  @override
  String get knode_app_enable_micro_server => '启用微服务';

  @override
  String get knode_app_enable_micro_server_desc => '开启后可通过浏览器访问';

  @override
  String get knode_app_error => '错误';

  @override
  String get knode_app_export_data => '导出数据';

  @override
  String get knode_app_export_success => '导出成功';

  @override
  String get knode_app_export_warning => '导出文件包含自定义提示词';

  @override
  String get knode_app_favorites => '收藏夹';

  @override
  String get knode_app_feedback => '反馈';

  @override
  String get knode_app_fetch => '获取';

  @override
  String get knode_app_fetch_failed_use_cache => '获取失败，使用已缓存数据';

  @override
  String get knode_app_fetch_or_import_hint => '请获取仓库或导入本地文件';

  @override
  String get knode_app_file_too_large => '文件过大';

  @override
  String get knode_app_font_size => '字体大小';

  @override
  String get knode_app_font_size_label => '字号';

  @override
  String get knode_app_get_backup_list_failed => '获取备份列表失败';

  @override
  String get knode_app_gguf_only => '仅支持 .gguf 格式文件';

  @override
  String get knode_app_home => '首页';

  @override
  String knode_app_import_count(String count) {
    return '成功导入 $count 个模板';
  }

  @override
  String get knode_app_import_data => '导入数据';

  @override
  String get knode_app_import_failed => '导入失败';

  @override
  String get knode_app_import_file => '从文件导入';

  @override
  String get knode_app_import_json_hint => '在此粘贴 JSON 内容';

  @override
  String get knode_app_import_local_model => '导入本地模型';

  @override
  String get knode_app_import_success => '导入成功';

  @override
  String get knode_app_input_api_key => '输入 API Key';

  @override
  String get knode_app_invalid_json => 'JSON 格式错误';

  @override
  String get knode_app_keep_backup_count => '保留备份数量';

  @override
  String knode_app_keep_backup_desc(String n) {
    return '自动清理时保留最近 $n 个备份';
  }

  @override
  String get knode_app_language => '语言';

  @override
  String get knode_app_license => '许可';

  @override
  String get knode_app_light_mode => '浅色模式';

  @override
  String get knode_app_line_spacing => '行距';

  @override
  String get knode_app_load_failed => '加载失败';

  @override
  String get knode_app_load_label => '加载';

  @override
  String get knode_app_loaded => '已加载';

  @override
  String get knode_app_loading => '加载中...';

  @override
  String get knode_app_local_backup => '本地备份';

  @override
  String get knode_app_local_backup_config_needed => '请配置本地备份目录';

  @override
  String knode_app_local_backup_last_backup(String time) {
    return '本地上次备份: $time';
  }

  @override
  String get knode_app_local_backup_not_configured => '未配置本地备份';

  @override
  String get knode_app_local_backup_path => '本地备份路径';

  @override
  String get knode_app_local_backup_path_subtitle => '选择本地备份目录';

  @override
  String get knode_app_local_backup_subtitle => '备份到本地存储';

  @override
  String get knode_app_local_model => '本地模型';

  @override
  String get knode_app_local_model_label => '本地模型';

  @override
  String get knode_app_local_restore => '本地恢复';

  @override
  String get knode_app_log_all => '全部';

  @override
  String get knode_app_log_clear => '清空日志';

  @override
  String get knode_app_log_clear_confirm => '确定要清空所有日志文件吗？此操作不可恢复。';

  @override
  String get knode_app_log_clear_success => '日志已清空';

  @override
  String get knode_app_log_copied => '已复制到剪贴板';

  @override
  String get knode_app_log_detail => '日志详情';

  @override
  String get knode_app_log_error_info => '错误信息';

  @override
  String get knode_app_log_export => '导出日志';

  @override
  String get knode_app_log_export_success => '日志已导出';

  @override
  String get knode_app_log_level => '级别';

  @override
  String get knode_app_log_no_logs => '暂无日志';

  @override
  String get knode_app_log_search => '搜索';

  @override
  String get knode_app_log_search_hint => '搜索日志...';

  @override
  String get knode_app_log_stack_trace => '堆栈跟踪';

  @override
  String get knode_app_log_viewer => '日志查看器';

  @override
  String get knode_app_manual => '手动';

  @override
  String get knode_app_manual_operation => '手动操作';

  @override
  String get knode_app_manual_operations => '手动操作';

  @override
  String get knode_app_migrate_and_change => '修改并迁移';

  @override
  String knode_app_migrate_files_confirm(String path) {
    return '将存储路径修改为:\\n$path\\n\\n是否迁移已有文件？';
  }

  @override
  String knode_app_migrated_n_files(String n) {
    return '已迁移 $n 个文件';
  }

  @override
  String get knode_app_migration_failed => '迁移失败';

  @override
  String knode_app_mirror_not_found(String key) {
    return '镜像 \"$key\" 不存在';
  }

  @override
  String get knode_app_model_card => '模型卡片';

  @override
  String get knode_app_model_download => '模型下载';

  @override
  String get knode_app_model_label => '模型';

  @override
  String get knode_app_model_name_label => '模型';

  @override
  String get knode_app_model_repo_url => '模型仓库地址';

  @override
  String get knode_app_model_repo_url_label => '模型仓库地址';

  @override
  String get knode_app_modify_storage_path => '修改存储路径';

  @override
  String get knode_app_module_settings => '模块设置';

  @override
  String get knode_app_multiple_choice_suffix => '（多选）';

  @override
  String get knode_app_night_mode => '夜间模式';

  @override
  String get knode_app_no_backups => '暂无备份记录';

  @override
  String get knode_app_no_backups_available => '没有可用的备份';

  @override
  String get knode_app_no_cleanup => '不清理';

  @override
  String get knode_app_no_custom_templates => '没有自定义模板可导出';

  @override
  String get knode_app_no_download_source => '无下载源';

  @override
  String get knode_app_no_exam_records => '暂无考试记录';

  @override
  String get knode_app_no_key_hint => '还没有 Key？点击获取';

  @override
  String get knode_app_no_local_backup => '无可用本地备份';

  @override
  String get knode_app_no_models => '暂无模型';

  @override
  String get knode_app_no_templates => '暂无模板';

  @override
  String get knode_app_no_webdav_backup => '无可用 WebDAV 备份';

  @override
  String get knode_app_no_wrong_cards => '暂无错题';

  @override
  String get knode_app_not_answered => '未作答';

  @override
  String get knode_app_notification => '通知';

  @override
  String get knode_app_options_label => '选项:';

  @override
  String get knode_app_original_template => '原始模板';

  @override
  String get knode_app_original_template_changed => '原始模板已有变更';

  @override
  String get knode_app_packing_files => '正在打包文件...';

  @override
  String get knode_app_password => '密码';

  @override
  String get knode_app_path_only => '仅修改路径';

  @override
  String get knode_app_personal_drawer => '个人抽屉';

  @override
  String get knode_app_port => '端口号';

  @override
  String get knode_app_privacy_policy => '隐私政策';

  @override
  String get knode_app_profile => '个人中心';

  @override
  String get knode_app_progress_backup_complete => '备份完成';

  @override
  String get knode_app_progress_decompressing => '正在解压...';

  @override
  String get knode_app_progress_downloading => '正在下载...';

  @override
  String get knode_app_progress_packing => '正在打包文件...';

  @override
  String get knode_app_progress_restore_complete => '恢复完成';

  @override
  String get knode_app_progress_uploading => '正在上传...';

  @override
  String get knode_app_prompt_edit_hint => '编辑提示词模板...';

  @override
  String get knode_app_prompt_grader => '阅卷评分';

  @override
  String get knode_app_prompt_intent => '意图分析';

  @override
  String get knode_app_prompt_management => '提示词管理';

  @override
  String get knode_app_prompt_management_subtitle => '管理 AI 提示词模板';

  @override
  String get knode_app_prompt_periodic_exam => '阶段考试';

  @override
  String get knode_app_prompt_question_variant => '变种出题';

  @override
  String get knode_app_prompt_quiz_gen => '出题生成';

  @override
  String get knode_app_prompt_rag_qa => 'RAG 问答';

  @override
  String get knode_app_prompt_search => '联网搜索';

  @override
  String get knode_app_prompt_summary => '摘要生成';

  @override
  String get knode_app_prompt_tag_gen => '标签生成';

  @override
  String get knode_app_quick_card => '快捷卡片';

  @override
  String get knode_app_quiz_due_review => '道待复习';

  @override
  String get knode_app_quiz_settings => '测验设置';

  @override
  String get knode_app_quiz_started_switch_tab => '速记已开始，请切换到[测验]标签查看';

  @override
  String get knode_app_rate_us => '评价应用';

  @override
  String get knode_app_reset_all => '一键恢复所有';

  @override
  String get knode_app_reset_all_confirm => '所有自定义内容将丢失是否继续？';

  @override
  String get knode_app_reset_override => '恢复默认';

  @override
  String get knode_app_reset_single_confirm => '将此模板恢复为默认值？';

  @override
  String get knode_app_reset_success => '重置成功';

  @override
  String get knode_app_restore => '恢复';

  @override
  String get knode_app_restore_btn => '恢复';

  @override
  String get knode_app_restore_complete => '恢复完成';

  @override
  String get knode_app_restore_confirm => '确定恢复到此备份版本？当前数据将被覆盖';

  @override
  String get knode_app_restore_confirm_msg => '恢复将覆盖当前数据，是否继续？';

  @override
  String get knode_app_restore_data => '恢复数据';

  @override
  String get knode_app_restore_failed => '恢复失败';

  @override
  String get knode_app_retry => '重试';

  @override
  String get knode_app_save => '保存';

  @override
  String get knode_app_save_success => '已保存';

  @override
  String get knode_app_score_card => '成绩卡片';

  @override
  String knode_app_score_n_points(String n) {
    return '$n分';
  }

  @override
  String get knode_app_search_api_key => '搜索 API Key';

  @override
  String get knode_app_select_restore_source => '选择恢复来源';

  @override
  String get knode_app_select_restore_version => '选择恢复版本';

  @override
  String get knode_app_select_search_provider => '选择搜索服务商';

  @override
  String get knode_app_server_settings => '服务设置';

  @override
  String get knode_app_service_provider => '服务商';

  @override
  String knode_app_session_n_messages(String n) {
    return '会话共 $n 条消息';
  }

  @override
  String get knode_app_settings => '设置';

  @override
  String get knode_app_share => '分享';

  @override
  String get knode_app_share_logs_subject => '知维应用日志';

  @override
  String get knode_app_skip_memory_check => '跳过内存兼容性检查';

  @override
  String get knode_app_skip_memory_check_desc => '显示所有模型，不根据设备内存过滤';

  @override
  String get knode_app_sound => '声音';

  @override
  String knode_app_source_not_found(String path) {
    return '源文件不存在: $path';
  }

  @override
  String get knode_app_start_practice => '开始练习';

  @override
  String get knode_app_storage_migration_hint_1 => '新文档将保存到新位置';

  @override
  String get knode_app_storage_migration_hint_2 => '迁移会将已有 .md 文件复制到新目录';

  @override
  String get knode_app_storage_migration_hint_3 => '原文件不会被删除，请手动清理';

  @override
  String get knode_app_storage_path => '存储路径';

  @override
  String get knode_app_storage_path_subtitle => '管理知识库文件存储位置';

  @override
  String get knode_app_storage_path_updated => '存储路径已更新';

  @override
  String get knode_app_storage_settings => '存储设置';

  @override
  String get knode_app_storage_space => '存储空间';

  @override
  String get knode_app_storage_usage => '存储用量';

  @override
  String get knode_app_success => '成功';

  @override
  String get knode_app_switch_to_quiz_tab => '请切换到[测验]标签查看考试历史';

  @override
  String get knode_app_system_default => '跟随系统';

  @override
  String get knode_app_tap_to_start => '点击开始练习';

  @override
  String get knode_app_test_connection => '测试连接';

  @override
  String get knode_app_testing => '测试中...';

  @override
  String get knode_app_theme => '主题';

  @override
  String get knode_app_unnamed_document => '未命名文档';

  @override
  String get knode_app_upload_failed => '上传失败';

  @override
  String get knode_app_uploading => '正在上传...';

  @override
  String get knode_app_user => '账号';

  @override
  String get knode_app_user_label => '用户';

  @override
  String get knode_app_variables => '变量';

  @override
  String get knode_app_version => '版本';

  @override
  String get knode_app_vibration => '振动';

  @override
  String get knode_app_view_logs => '查看日志';

  @override
  String get knode_app_view_operation_logs_and_error_records => '查看运行日志、错误记录';

  @override
  String get knode_app_view_source => '查看原文';

  @override
  String get knode_app_web_search => '联网搜索';

  @override
  String get knode_app_web_search_subtitle => '搜索服务商、API Key 配置';

  @override
  String get knode_app_webdav => 'WebDAV';

  @override
  String knode_app_webdav_last_backup(String time) {
    return 'WebDAV 上次备份: $time';
  }

  @override
  String get knode_app_webdav_not_configured => 'WebDAV 未配置';

  @override
  String get knode_app_webdav_restore => 'WebDAV 恢复';

  @override
  String get knode_app_webdav_server => 'WebDAV 服务器';

  @override
  String get knode_app_webdav_subtitle => 'WebDAV / 本地备份';

  @override
  String get knode_app_weekly => '每周';

  @override
  String get knode_app_weekly_label => '每周';

  @override
  String get knode_app_welcome_back => '欢迎回来';

  @override
  String get knode_app_wiki_settings => 'Wiki 设置';

  @override
  String get knode_app_wrong_card => '错题卡片';

  @override
  String get micro_server_answer_submission_failed => '提交答案失败';

  @override
  String get micro_server_cors_preflight_request => 'CORS 预检请求';

  @override
  String get micro_server_document_does_not_exist => '文档不存在';

  @override
  String get micro_server_document_list_retrieval_failed => '获取文档列表失败';

  @override
  String get micro_server_document_retrieval_failed => '获取文档失败';

  @override
  String get micro_server_download_failed => '下载失败';

  @override
  String get micro_server_file_list_retrieval_failed => '获取文件列表失败';

  @override
  String get micro_server_file_not_found => '文件未找到';

  @override
  String get micro_server_internal_server_error => '服务器内部错误';

  @override
  String get micro_server_invalid_document_id => '无效的文档 ID';

  @override
  String get micro_server_invalid_request => '无效请求';

  @override
  String get micro_server_missing_questionId => '缺少 questionId';

  @override
  String get micro_server_not_found => '未找到';

  @override
  String get micro_server_port => '端口';

  @override
  String get micro_server_question_does_not_exist => '题目不存在';

  @override
  String get micro_server_question_retrieval_failed => '获取题目失败';

  @override
  String get micro_server_request_body_empty => '请求体为空';

  @override
  String get micro_server_server_address => '服务器地址';

  @override
  String get micro_server_server_already_running => '服务器已在运行中';

  @override
  String get micro_server_server_not_running => '服务器未运行';

  @override
  String get micro_server_server_started_on_port => '服务器已在端口 %d 启动';

  @override
  String get micro_server_server_stopped => '服务器已停止';

  @override
  String get micro_server_starting_server => '正在启动服务器...';

  @override
  String get micro_server_stopping_server => '正在停止服务器...';

  @override
  String get micro_server_upload_confirmed => '上传已确认';

  @override
  String get micro_server_upload_failed => '上传失败';

  @override
  String get micro_server_upload_pending_confirmation => '等待上传确认';

  @override
  String get micro_server_upload_rejected => '上传已拒绝';

  @override
  String get micro_server_waiting_for_device_confirmation => '等待手机端确认';

  @override
  String get quiz_accuracy => '正确率';

  @override
  String get quiz_add_note => '添加笔记';

  @override
  String get quiz_ai_enabled => '启用 AI 出题';

  @override
  String get quiz_ai_explanation => 'AI 讲解';

  @override
  String get quiz_ai_fixed_ratio => '固定 AI 比例';

  @override
  String get quiz_ai_ratio_fixed => '固定比例';

  @override
  String quiz_ai_ratio_label(String percent) {
    return 'AI 出题: $percent%';
  }

  @override
  String get quiz_ai_ratio_mode => 'AI 出题比例模式';

  @override
  String get quiz_ai_ratio_smart => '智能比例';

  @override
  String get quiz_all_knowledge_base => '全部知识库';

  @override
  String get quiz_answer => '答案';

  @override
  String quiz_answered_n_of_m(String current, String total) {
    return '已答 $current/$total 题';
  }

  @override
  String get quiz_completed => '已完成';

  @override
  String get quiz_confirm_submit => '确认交卷';

  @override
  String get quiz_congratulations_passed => '恭喜通过！';

  @override
  String get quiz_consolidate_weak_knowledge_points => '巩固薄弱知识点';

  @override
  String get quiz_continue_answering => '继续答题';

  @override
  String get quiz_correct => '正确';

  @override
  String get quiz_correct_answer => '正确答案';

  @override
  String get quiz_create_exam_failed => '创建考试失败';

  @override
  String get quiz_daily_count => '每日一测题目数量';

  @override
  String get quiz_daily_quiz => '每日一测';

  @override
  String get quiz_daily_quiz_not_enabled => '每日一测未启用';

  @override
  String get quiz_daily_quiz_settings => '每日一测设置';

  @override
  String get quiz_daily_quiz_started => '每日一测已开始，请切换到\"测验\"标签查看';

  @override
  String get quiz_daily_scope => '每日一测出题范围';

  @override
  String get quiz_easy => '简单';

  @override
  String get quiz_enable_daily_quiz => '启用每日一测';

  @override
  String get quiz_exam => '考试';

  @override
  String get quiz_exam_generated => '考试已生成';

  @override
  String get quiz_exam_history => '考试历史';

  @override
  String get quiz_exam_not_found => '考试不存在';

  @override
  String get quiz_exam_result => '测验结果';

  @override
  String get quiz_explanation => '解析';

  @override
  String get quiz_feedback => '反馈';

  @override
  String get quiz_fill_in_the_blank => '填空题';

  @override
  String get quiz_generate_quiz_questions_daily => '每天定时生成测验题目';

  @override
  String get quiz_hard => '困难';

  @override
  String get quiz_input_answer => '输入答案';

  @override
  String get quiz_input_your_answer => '输入你的回答...';

  @override
  String get quiz_keep_going => '继续加油！';

  @override
  String get quiz_load_failed => '加载失败';

  @override
  String get quiz_loading => '加载中...';

  @override
  String get quiz_makeup_deadline => '补考截止';

  @override
  String get quiz_makeup_exam => '补考';

  @override
  String get quiz_mark_as_mastered => '标记为已掌握';

  @override
  String get quiz_mastered => '已掌握';

  @override
  String get quiz_mastered_will_no_longer_appear => '已标记为掌握，错题本中将不再显示';

  @override
  String get quiz_medium => '中等';

  @override
  String get quiz_missed_exam => '错过考试';

  @override
  String get quiz_monthly_comprehensive_quiz => '每月综合测验';

  @override
  String get quiz_monthly_count => '月考题目数量';

  @override
  String get quiz_monthly_exam => '月考';

  @override
  String get quiz_monthly_exam_2 => '月度考试';

  @override
  String get quiz_multiple_choice => '多选题';

  @override
  String get quiz_next_question => '下一题';

  @override
  String get quiz_no_associated_document => '无关联文档';

  @override
  String get quiz_no_exam_records => '暂无考试记录';

  @override
  String get quiz_no_wrong_questions_keep_it_up => '暂无错题，继续保持！';

  @override
  String get quiz_not_answered => '未作答';

  @override
  String get quiz_note_input_hint => '输入笔记内容...';

  @override
  String get quiz_options => '选项';

  @override
  String get quiz_options_label => '选项:';

  @override
  String get quiz_please_override_in_main_dart => '请在 main.dart 中覆盖';

  @override
  String get quiz_please_switch_to_quiz_tab => '请切换到\"测验\"标签查看考试历史';

  @override
  String get quiz_practice => '开始练习';

  @override
  String get quiz_previous_question => '上一题';

  @override
  String get quiz_quarterly_comprehensive_quiz => '季度综合测验';

  @override
  String get quiz_quarterly_count => '季考题目数量';

  @override
  String get quiz_quarterly_exam => '季考';

  @override
  String get quiz_quarterly_exam_2 => '季度考试';

  @override
  String get quiz_question => '题目';

  @override
  String get quiz_question_count => '题目数量';

  @override
  String quiz_question_n_of_m(String current, String total) {
    return '第 $current/$total 题';
  }

  @override
  String get quiz_question_scope => '出题范围';

  @override
  String get quiz_questions => '题';

  @override
  String get quiz_quick_quiz_started => '速记已开始，请切换到\"测验\"标签查看';

  @override
  String get quiz_quiz => '测验';

  @override
  String get quiz_quiz_config => '出题设置';

  @override
  String get quiz_quiz_types => '测验类型';

  @override
  String get quiz_random_count => '随机速记题目数量';

  @override
  String get quiz_random_days => '随机速记天数范围';

  @override
  String get quiz_random_quick_review => '随机抽取快速复习';

  @override
  String get quiz_random_quiz => '随机速记';

  @override
  String quiz_ready_with_n_questions(String count) {
    return '已准备好，共 $count 题';
  }

  @override
  String get quiz_recent_reading_documents => '最近阅读文档';

  @override
  String get quiz_reminder_hour => '考试提醒时间';

  @override
  String get quiz_reminder_time => '提醒时间';

  @override
  String get quiz_return => '返回';

  @override
  String get quiz_review_count => '温故知新题目数量';

  @override
  String get quiz_review_wrong_ratio => '温故知新错题比例';

  @override
  String get quiz_save => '保存';

  @override
  String get quiz_save_settings => '保存设置';

  @override
  String get quiz_scope_all => '全部题库';

  @override
  String get quiz_scope_category => '指定类目';

  @override
  String get quiz_scope_days => '最近阅读';

  @override
  String get quiz_score => '分数';

  @override
  String get quiz_settings_saved => '设置已保存';

  @override
  String get quiz_short_answer => '简答题';

  @override
  String get quiz_single_choice => '单选题';

  @override
  String get quiz_skip => '跳过';

  @override
  String get quiz_sort_by_difficulty => '按难度';

  @override
  String get quiz_sort_by_wrong_count => '按错误次数';

  @override
  String get quiz_specific_category => '指定类目';

  @override
  String get quiz_streak_days => '连续天数';

  @override
  String get quiz_submit_exam => '交卷';

  @override
  String get quiz_tap_to_start => '点击开始练习';

  @override
  String get quiz_ten_questions_per_day => '每天 10 道题';

  @override
  String quiz_today_n_questions_tap_to_start(String count) {
    return '今日 $count 题，点击开始';
  }

  @override
  String get quiz_true_false => '判断题';

  @override
  String get quiz_unknown => '未知';

  @override
  String get quiz_variant_enabled => '启用变种出题';

  @override
  String get quiz_view_source_document => '查看源文档';

  @override
  String get quiz_wrong => '错误';

  @override
  String get quiz_wrong_question_detail => '错题详情';

  @override
  String get quiz_wrong_question_review => '错题重练';

  @override
  String get quiz_wrong_questions => '错题本';

  @override
  String get quiz_yearly_comprehensive_quiz => '年度综合测验';

  @override
  String get quiz_yearly_count => '年考题目数量';

  @override
  String get quiz_yearly_exam => '年考';

  @override
  String get quiz_yearly_exam_2 => '年度考试';

  @override
  String get quiz_your_answer => '你的答案';

  @override
  String get wiki_add_bookmark => '添加书签';

  @override
  String get wiki_add_category => '添加类目';

  @override
  String get wiki_add_category_in_dev => '添加类目功能开发中';

  @override
  String get wiki_add_citation => '添加引用';

  @override
  String get wiki_add_highlight => '添加高亮';

  @override
  String get wiki_add_note => '添加笔记';

  @override
  String get wiki_add_tag => '添加标签';

  @override
  String get wiki_ai_explanation => 'AI 讲解';

  @override
  String get wiki_ai_explanation_failed => 'AI 讲解失败';

  @override
  String get wiki_all_documents => '全部文档';

  @override
  String get wiki_all_knowledge => '全部知识';

  @override
  String get wiki_answer_correct_n => '答对  /  题';

  @override
  String get wiki_ask_ai => '问问AI';

  @override
  String get wiki_auto_generate_tags => '自动为新文档生成标签';

  @override
  String get wiki_auto_saved => '已自动保存';

  @override
  String get wiki_background => '背景色';

  @override
  String get wiki_bookmark => '书签';

  @override
  String get wiki_browser_search => '浏览器搜索';

  @override
  String get wiki_cancel => '取消';

  @override
  String get wiki_category => '类目';

  @override
  String get wiki_category_name => '类目名称';

  @override
  String get wiki_category_panel => '类目面板';

  @override
  String get wiki_category_tree => '类目树';

  @override
  String get wiki_citation => '引用';

  @override
  String get wiki_citation_popup => '引用弹窗';

  @override
  String get wiki_close => '关闭';

  @override
  String get wiki_confirm => '确认';

  @override
  String get wiki_copied_to_clipboard => '已复制到剪贴板';

  @override
  String get wiki_copy => '复制';

  @override
  String get wiki_create_node => '创建节点';

  @override
  String get wiki_dark => '深色';

  @override
  String get wiki_delete => '删除';

  @override
  String get wiki_delete_category => '删除类目';

  @override
  String wiki_delete_category_confirm(String name) {
    return '确定删除「$name」？子类目将移至根目录。';
  }

  @override
  String get wiki_delete_document => '删除文档';

  @override
  String get wiki_document => '文档';

  @override
  String get wiki_document_name => '文档名称';

  @override
  String get wiki_document_title => '文档标题';

  @override
  String get wiki_edit_category => '编辑类目';

  @override
  String get wiki_edit_category_in_dev => '编辑类目功能开发中';

  @override
  String get wiki_edit_document => '编辑文档';

  @override
  String get wiki_edit_tags => '编辑标签';

  @override
  String get wiki_editor => '编辑器';

  @override
  String get wiki_error => '错误';

  @override
  String get wiki_explain_text => '解释';

  @override
  String get wiki_export => '导出';

  @override
  String get wiki_export_document => '导出文档';

  @override
  String get wiki_eye_care => '护眼';

  @override
  String get wiki_feature_development => '开发中';

  @override
  String get wiki_feature_in_development => '功能开发中';

  @override
  String get wiki_font_size => '字号';

  @override
  String get wiki_fulltext_search => '全文搜索';

  @override
  String get wiki_generate_based => '基于以下内容生成';

  @override
  String get wiki_generate_question => '生成题目';

  @override
  String get wiki_generated_questions => '生成的题目';

  @override
  String get wiki_generating_ai_explanation => '正在生成 AI 讲解...';

  @override
  String get wiki_generating_questions => '正在生成题目...';

  @override
  String get wiki_graph_canvas => '图谱画布';

  @override
  String get wiki_graph_canvas_pending => '图谱画布（开发中）';

  @override
  String get wiki_graph_controller => '图谱控制器';

  @override
  String get wiki_graph_edge => '图谱边';

  @override
  String get wiki_graph_node => '图谱节点';

  @override
  String get wiki_highlight => '高亮';

  @override
  String get wiki_ideas => '灵感';

  @override
  String get wiki_import => '导入';

  @override
  String get wiki_import_document => '导入文档';

  @override
  String get wiki_input_answer => '输入答案';

  @override
  String get wiki_input_word_hint => '输入单词查询释义';

  @override
  String get wiki_input_your_answer => '输入你的回答...';

  @override
  String get wiki_knowledge_graph => '知识图谱';

  @override
  String get wiki_knowledge_map => '知识地图';

  @override
  String get wiki_knowledge_search => '知识库搜索';

  @override
  String get wiki_light => '浅色';

  @override
  String get wiki_line_spacing => '行距';

  @override
  String get wiki_loading => '加载中...';

  @override
  String get wiki_manage_categories => '管理类目';

  @override
  String get wiki_margin => '页边距';

  @override
  String get wiki_markdown_source => 'Markdown 源码...';

  @override
  String get wiki_min => '分钟';

  @override
  String get wiki_move_to => '移动到';

  @override
  String get wiki_new_document => '新建文档';

  @override
  String get wiki_next_match => '下一个匹配';

  @override
  String get wiki_night_mode => '夜间模式';

  @override
  String get wiki_no_bookmarks => '暂无书签';

  @override
  String get wiki_no_categories => '暂无类目';

  @override
  String get wiki_no_documents => '暂无文档';

  @override
  String get wiki_no_docx_text => '(DOCX 文件无文本内容)';

  @override
  String get wiki_no_headings => '暂无标题';

  @override
  String get wiki_no_highlights => '暂无高亮';

  @override
  String get wiki_no_tags => '暂无标签';

  @override
  String get wiki_no_text_content => '(PDF 文件无文本内容，可能为扫描件)';

  @override
  String get wiki_no_titles => '暂无标题';

  @override
  String get wiki_node_name => '节点名称';

  @override
  String get wiki_note => '备注';

  @override
  String get wiki_note_document => '笔记文档';

  @override
  String get wiki_note_input_hint => '输入笔记内容...';

  @override
  String get wiki_note_saved => '笔记已保存';

  @override
  String get wiki_notes => '笔记';

  @override
  String get wiki_outline => '目录';

  @override
  String get wiki_page => '页';

  @override
  String get wiki_pdf_export => 'PDF 导出';

  @override
  String get wiki_please_explain => '请解释以下内容';

  @override
  String get wiki_prev_match => '上一个匹配';

  @override
  String get wiki_question_generation_failed => '题目生成失败';

  @override
  String get wiki_read_aloud => '朗读';

  @override
  String get wiki_reader => '阅读器';

  @override
  String get wiki_reader_ask_ai => '问问AI';

  @override
  String get wiki_reader_bookmark => '书签';

  @override
  String get wiki_reader_browser_search => '浏览器搜索';

  @override
  String get wiki_reader_copy => '复制';

  @override
  String get wiki_reader_dictionary => '字典';

  @override
  String get wiki_reader_full_text_search => '全文搜索';

  @override
  String get wiki_reader_highlight_note => '划重点';

  @override
  String get wiki_reader_kb_search => '知识库搜索';

  @override
  String get wiki_reader_read_aloud => '朗读';

  @override
  String get wiki_reader_toolbar => '阅读器工具栏';

  @override
  String get wiki_reading_settings => '阅读设置';

  @override
  String get wiki_rename => '重命名';

  @override
  String get wiki_rename_category => '重命名类目';

  @override
  String get wiki_reset_tags => '重置标签';

  @override
  String get wiki_reset_tags_confirm => '确定重置标签？AI 生成的标签将被清除';

  @override
  String get wiki_root_directory => '根目录';

  @override
  String get wiki_save => '保存';

  @override
  String get wiki_score_suffix => '分';

  @override
  String get wiki_search => '搜索';

  @override
  String get wiki_search_document => '搜索文档...';

  @override
  String get wiki_search_word => '搜索单词';

  @override
  String get wiki_skip => '跳过';

  @override
  String get wiki_study_materials => '学习资料';

  @override
  String get wiki_style => '样式';

  @override
  String get wiki_summarize => '摘要';

  @override
  String get wiki_summarizer => '摘要生成器';

  @override
  String get wiki_summary => '摘要';

  @override
  String get wiki_switch_to_rich => '切换到富文本模式';

  @override
  String get wiki_switch_to_source => '切换到源码模式';

  @override
  String get wiki_system_prompt_explain => '你是一个善于清晰解释知识的助手。请以清晰、有条理的方式解释以下内容。';

  @override
  String get wiki_tag_generated => '标签已生成';

  @override
  String get wiki_tag_generation_failed => '标签生成失败';

  @override
  String get wiki_tags => '标签';

  @override
  String get wiki_tap_to_select => '点击选择';

  @override
  String get wiki_text_to_speech => '文字转语音';

  @override
  String get wiki_theme => '主题';

  @override
  String get wiki_toc => '目录';

  @override
  String get wiki_today_reading => '今天阅读';

  @override
  String get wiki_total_reading => '总阅读';

  @override
  String get wiki_tts => '朗读';

  @override
  String get wiki_underline => '下划线';

  @override
  String get wiki_view_source => '查看原文';

  @override
  String get wiki_wiki => '知识库';

  @override
  String get wiki_work => '工作';

  @override
  String get wiki_zoom_in => '放大';

  @override
  String get wiki_zoom_out => '缩小';
}
