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
  String get chat_ai_assistant => 'AI 助手';

  @override
  String get chat_ai_chat => 'AI 对话';

  @override
  String get chat_answer => '回答';

  @override
  String get chat_archive => '归档';

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
  String get chat_error => '错误';

  @override
  String get chat_export_chat => '导出对话';

  @override
  String get chat_history_sessions => '历史会话';

  @override
  String get chat_history_sessions_dev => '历史会话功能开发中';

  @override
  String get chat_image => '图片';

  @override
  String get chat_image_dev => '图片选择功能开发中';

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
  String get chat_loading => '加载中...';

  @override
  String get chat_message => '消息';

  @override
  String get chat_new_conversation => '新建对话';

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
  String get chat_send => '发送';

  @override
  String get chat_send_message => '发送消息';

  @override
  String get chat_send_message_need_ai => '消息发送功能需连接 AIProvider';

  @override
  String get chat_sources => '来源';

  @override
  String get chat_start_conversation_hint => '发送消息开始与 AI 助手对话';

  @override
  String get chat_test_connection => '测试连接';

  @override
  String get chat_token_usage => 'Token 用量';

  @override
  String get chat_voice_input => '语音输入';

  @override
  String get chat_voice_real_device => '语音输入功能需在真机上使用';

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
  String get core_message => '消息';

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
  String get core_true_false => '判断题';

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
  String get knode_app_ai_engine => 'AI 引擎';

  @override
  String get knode_app_ai_engine_subtitle => '本地模型管理、云端 API 配置';

  @override
  String get knode_app_ai_settings => 'AI 设置';

  @override
  String get knode_app_app_shell => '应用外壳';

  @override
  String get knode_app_auto_backup => '自动备份';

  @override
  String knode_app_available_memory(String memory) {
    return '可用内存: $memory MB';
  }

  @override
  String get knode_app_backup_settings => '备份设置';

  @override
  String get knode_app_bottom_navigation => '底部导航';

  @override
  String get knode_app_cancel => '取消';

  @override
  String get knode_app_clear_cache => '清除缓存';

  @override
  String get knode_app_cloud_api => '云端 API';

  @override
  String get knode_app_cloud_config => '云配置';

  @override
  String get knode_app_cloud_model_repo_url => '云模型仓库地址';

  @override
  String get knode_app_config_api_key_first => '请先配置 API Key';

  @override
  String get knode_app_confirm => '确认';

  @override
  String get knode_app_connection_failed => '连接失败';

  @override
  String get knode_app_connection_success => '连接成功';

  @override
  String get knode_app_custom => '已自定义';

  @override
  String get knode_app_daily_card => '每日卡片';

  @override
  String get knode_app_dark_mode => '深色模式';

  @override
  String get knode_app_error => '错误';

  @override
  String get knode_app_export_data => '导出数据';

  @override
  String get knode_app_export_success => '导出成功';

  @override
  String get knode_app_export_warning => '导出文件包含自定义提示词';

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
  String get knode_app_home => '首页';

  @override
  String get knode_app_import_data => '导入数据';

  @override
  String get knode_app_import_failed => '导入失败';

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
  String get knode_app_language => '语言';

  @override
  String get knode_app_license => '许可';

  @override
  String get knode_app_light_mode => '浅色模式';

  @override
  String get knode_app_load_failed => '加载失败';

  @override
  String get knode_app_loading => '加载中...';

  @override
  String get knode_app_local_model => '本地模型';

  @override
  String get knode_app_model_card => '模型卡片';

  @override
  String get knode_app_model_download => '模型下载';

  @override
  String get knode_app_model_repo_url => '模型仓库地址';

  @override
  String get knode_app_no_models => '暂无模型';

  @override
  String get knode_app_no_templates => '暂无模板';

  @override
  String get knode_app_notification => '通知';

  @override
  String get knode_app_original_template => '原始模板';

  @override
  String get knode_app_original_template_changed => '原始模板已有变更';

  @override
  String get knode_app_personal_drawer => '个人抽屉';

  @override
  String get knode_app_privacy_policy => '隐私政策';

  @override
  String get knode_app_profile => '个人中心';

  @override
  String get knode_app_prompt_edit_hint => '编辑提示词模板...';

  @override
  String get knode_app_prompt_management => '提示词管理';

  @override
  String get knode_app_prompt_management_subtitle => '管理 AI 提示词模板';

  @override
  String get knode_app_quick_card => '快捷卡片';

  @override
  String get knode_app_rate_us => '评价应用';

  @override
  String get knode_app_reset_all => '一键恢复所有';

  @override
  String get knode_app_reset_all_confirm => '所有自定义内容将丢失是否继续？';

  @override
  String get knode_app_reset_override => '恢复默认';

  @override
  String get knode_app_reset_success => '重置成功';

  @override
  String get knode_app_save => '保存';

  @override
  String get knode_app_save_success => '模板已保存';

  @override
  String get knode_app_score_card => '成绩卡片';

  @override
  String get knode_app_search_api_key => '搜索 API Key';

  @override
  String get knode_app_select_search_provider => '选择搜索服务商';

  @override
  String get knode_app_server_settings => '服务设置';

  @override
  String get knode_app_settings => '设置';

  @override
  String get knode_app_share => '分享';

  @override
  String get knode_app_sound => '声音';

  @override
  String get knode_app_storage_path => '存储路径';

  @override
  String get knode_app_storage_path_subtitle => '管理知识库文件存储位置';

  @override
  String get knode_app_storage_settings => '存储设置';

  @override
  String get knode_app_storage_usage => '存储用量';

  @override
  String get knode_app_success => '成功';

  @override
  String get knode_app_system_default => '跟随系统';

  @override
  String get knode_app_testing => '测试中...';

  @override
  String get knode_app_theme => '主题';

  @override
  String get knode_app_variables => '变量';

  @override
  String get knode_app_version => '版本';

  @override
  String get knode_app_vibration => '振动';

  @override
  String get knode_app_web_search => '联网搜索';

  @override
  String get knode_app_web_search_subtitle => '搜索服务商、API Key 配置';

  @override
  String get knode_app_webdav => 'WebDAV';

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
  String get wiki_add_category => '添加类目';

  @override
  String get wiki_add_citation => '添加引用';

  @override
  String get wiki_add_tag => '添加标签';

  @override
  String get wiki_all_knowledge => '全部知识';

  @override
  String get wiki_auto_generate_tags => '自动为新文档生成标签';

  @override
  String get wiki_cancel => '取消';

  @override
  String get wiki_category => '类目';

  @override
  String get wiki_category_panel => '类目面板';

  @override
  String get wiki_category_tree => '类目树';

  @override
  String get wiki_citation => '引用';

  @override
  String get wiki_citation_popup => '引用弹窗';

  @override
  String get wiki_confirm => '确认';

  @override
  String get wiki_create_node => '创建节点';

  @override
  String get wiki_delete => '删除';

  @override
  String get wiki_delete_document => '删除文档';

  @override
  String get wiki_document => '文档';

  @override
  String get wiki_document_title => '文档标题';

  @override
  String get wiki_edit_category => '编辑类目';

  @override
  String get wiki_edit_document => '编辑文档';

  @override
  String get wiki_edit_tags => '编辑标签';

  @override
  String get wiki_editor => '编辑器';

  @override
  String get wiki_error => '错误';

  @override
  String get wiki_export => '导出';

  @override
  String get wiki_export_document => '导出文档';

  @override
  String get wiki_graph_canvas => '图谱画布';

  @override
  String get wiki_graph_controller => '图谱控制器';

  @override
  String get wiki_graph_edge => '图谱边';

  @override
  String get wiki_graph_node => '图谱节点';

  @override
  String get wiki_ideas => '灵感';

  @override
  String get wiki_import => '导入';

  @override
  String get wiki_import_document => '导入文档';

  @override
  String get wiki_knowledge_graph => '知识图谱';

  @override
  String get wiki_knowledge_map => '知识地图';

  @override
  String get wiki_loading => '加载中...';

  @override
  String get wiki_manage_categories => '管理类目';

  @override
  String get wiki_new_document => '新建文档';

  @override
  String get wiki_no_documents => '暂无文档';

  @override
  String get wiki_no_tags => '暂无标签';

  @override
  String get wiki_node_name => '节点名称';

  @override
  String get wiki_notes => '笔记';

  @override
  String get wiki_page => '页';

  @override
  String get wiki_pdf_export => 'PDF 导出';

  @override
  String get wiki_reader => '阅读器';

  @override
  String get wiki_reader_toolbar => '阅读器工具栏';

  @override
  String get wiki_reset_tags => '重置标签';

  @override
  String get wiki_reset_tags_confirm => '确定重置标签？AI 生成的标签将被清除';

  @override
  String get wiki_save => '保存';

  @override
  String get wiki_search => '搜索';

  @override
  String get wiki_study_materials => '学习资料';

  @override
  String get wiki_summarize => '摘要';

  @override
  String get wiki_summarizer => '摘要生成器';

  @override
  String get wiki_summary => '摘要';

  @override
  String get wiki_tag_generated => '标签已生成';

  @override
  String get wiki_tag_generation_failed => '标签生成失败';

  @override
  String get wiki_tags => '标签';

  @override
  String get wiki_text_to_speech => '文字转语音';

  @override
  String get wiki_tts => '朗读';

  @override
  String get wiki_wiki => '知识库';

  @override
  String get wiki_work => '工作';

  @override
  String get wiki_zoom_in => '放大';

  @override
  String get wiki_zoom_out => '缩小';
}
