// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: depend_on_referenced_packages, implementation_imports, invalid_use_of_internal_member
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:monolith_localization_runtime/src/localize_string_delegate.dart';
import 'package:monolith_localization_runtime/src/localize_string_source.dart';

import 'l10n.dart';

/// e.g.
/// localizationsDelegates: [
///   L10nHelper.delegate,
///   GlobalMaterialLocalizations.delegate,
///   GlobalCupertinoLocalizations.delegate,
///   GlobalWidgetsLocalizations.delegate,
/// ]
final class L10nHelper {
  const L10nHelper._();

  /// L10n Delegate instance.
  static const delegate = _L10nHelperDelegate();

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
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const supportedLocales = L10n.supportedLocales;

  static void configure(L10n? l10n) {
    if (l10n == null) {
      return;
    }
    final table = <String, String Function(LocalizeStringSource source)>{
      'chat_add_attachment': (source) {
        // No Placeholders
        return l10n.chat_add_attachment;
      },
      'chat_add_attachment_label': (source) {
        // No Placeholders
        return l10n.chat_add_attachment_label;
      },
      'chat_ai_assistant': (source) {
        // No Placeholders
        return l10n.chat_ai_assistant;
      },
      'chat_ai_chat': (source) {
        // No Placeholders
        return l10n.chat_ai_chat;
      },
      'chat_answer': (source) {
        // No Placeholders
        return l10n.chat_answer;
      },
      'chat_archive': (source) {
        // No Placeholders
        return l10n.chat_archive;
      },
      'chat_archive_failed': (source) {
        // No Placeholders
        return l10n.chat_archive_failed;
      },
      'chat_archive_in_detail': (source) {
        // No Placeholders
        return l10n.chat_archive_in_detail;
      },
      'chat_archive_title': (source) {
        // No Placeholders
        return l10n.chat_archive_title;
      },
      'chat_cancel': (source) {
        // No Placeholders
        return l10n.chat_cancel;
      },
      'chat_chat': (source) {
        // No Placeholders
        return l10n.chat_chat;
      },
      'chat_citation': (source) {
        // No Placeholders
        return l10n.chat_citation;
      },
      'chat_clear_history': (source) {
        // No Placeholders
        return l10n.chat_clear_history;
      },
      'chat_clear_history_dev': (source) {
        // No Placeholders
        return l10n.chat_clear_history_dev;
      },
      'chat_clear_in_dev': (source) {
        // No Placeholders
        return l10n.chat_clear_in_dev;
      },
      'chat_confirm': (source) {
        // No Placeholders
        return l10n.chat_confirm;
      },
      'chat_connection_failed': (source) {
        // No Placeholders
        return l10n.chat_connection_failed;
      },
      'chat_connection_success': (source) {
        // No Placeholders
        return l10n.chat_connection_success;
      },
      'chat_copied': (source) {
        // No Placeholders
        return l10n.chat_copied;
      },
      'chat_copy': (source) {
        // No Placeholders
        return l10n.chat_copy;
      },
      'chat_current_session': (source) {
        // No Placeholders
        return l10n.chat_current_session;
      },
      'chat_delete_conversation': (source) {
        // No Placeholders
        return l10n.chat_delete_conversation;
      },
      'chat_document': (source) {
        // No Placeholders
        return l10n.chat_document;
      },
      'chat_document_dev': (source) {
        // No Placeholders
        return l10n.chat_document_dev;
      },
      'chat_document_in_dev': (source) {
        // No Placeholders
        return l10n.chat_document_in_dev;
      },
      'chat_document_label': (source) {
        // No Placeholders
        return l10n.chat_document_label;
      },
      'chat_error': (source) {
        // No Placeholders
        return l10n.chat_error;
      },
      'chat_export_chat': (source) {
        // No Placeholders
        return l10n.chat_export_chat;
      },
      'chat_history_conversations': (source) {
        // No Placeholders
        return l10n.chat_history_conversations;
      },
      'chat_history_in_dev': (source) {
        // No Placeholders
        return l10n.chat_history_in_dev;
      },
      'chat_history_sessions': (source) {
        // No Placeholders
        return l10n.chat_history_sessions;
      },
      'chat_history_sessions_dev': (source) {
        // No Placeholders
        return l10n.chat_history_sessions_dev;
      },
      'chat_image': (source) {
        // No Placeholders
        return l10n.chat_image;
      },
      'chat_image_dev': (source) {
        // No Placeholders
        return l10n.chat_image_dev;
      },
      'chat_image_in_dev': (source) {
        // No Placeholders
        return l10n.chat_image_in_dev;
      },
      'chat_image_label': (source) {
        // No Placeholders
        return l10n.chat_image_label;
      },
      'chat_input_message': (source) {
        // No Placeholders
        return l10n.chat_input_message;
      },
      'chat_intent_recognition': (source) {
        // No Placeholders
        return l10n.chat_intent_recognition;
      },
      'chat_knowledge_base': (source) {
        // No Placeholders
        return l10n.chat_knowledge_base;
      },
      'chat_link': (source) {
        // No Placeholders
        return l10n.chat_link;
      },
      'chat_link_dev': (source) {
        // No Placeholders
        return l10n.chat_link_dev;
      },
      'chat_link_in_dev': (source) {
        // No Placeholders
        return l10n.chat_link_in_dev;
      },
      'chat_link_label': (source) {
        // No Placeholders
        return l10n.chat_link_label;
      },
      'chat_load_failed': (source) {
        // No Placeholders
        return l10n.chat_load_failed;
      },
      'chat_loading': (source) {
        // No Placeholders
        return l10n.chat_loading;
      },
      'chat_message': (source) {
        // No Placeholders
        return l10n.chat_message;
      },
      'chat_need_ai_provider': (source) {
        // No Placeholders
        return l10n.chat_need_ai_provider;
      },
      'chat_new_conversation': (source) {
        // No Placeholders
        return l10n.chat_new_conversation;
      },
      'chat_no_conversations': (source) {
        // No Placeholders
        return l10n.chat_no_conversations;
      },
      'chat_no_conversations_yet': (source) {
        // No Placeholders
        return l10n.chat_no_conversations_yet;
      },
      'chat_please_override_in_main_dart': (source) {
        // No Placeholders
        return l10n.chat_please_override_in_main_dart;
      },
      'chat_qa': (source) {
        // No Placeholders
        return l10n.chat_qa;
      },
      'chat_question': (source) {
        // No Placeholders
        return l10n.chat_question;
      },
      'chat_rag_search': (source) {
        // No Placeholders
        return l10n.chat_rag_search;
      },
      'chat_related_documents': (source) {
        // No Placeholders
        return l10n.chat_related_documents;
      },
      'chat_rename_conversation': (source) {
        // No Placeholders
        return l10n.chat_rename_conversation;
      },
      'chat_rename_label': (source) {
        // No Placeholders
        return l10n.chat_rename_label;
      },
      'chat_retry': (source) {
        // No Placeholders
        return l10n.chat_retry;
      },
      'chat_save': (source) {
        // No Placeholders
        return l10n.chat_save;
      },
      'chat_search': (source) {
        // No Placeholders
        return l10n.chat_search;
      },
      'chat_search_api_key': (source) {
        // No Placeholders
        return l10n.chat_search_api_key;
      },
      'chat_search_config': (source) {
        // No Placeholders
        return l10n.chat_search_config;
      },
      'chat_search_provider': (source) {
        // No Placeholders
        return l10n.chat_search_provider;
      },
      'chat_select_category': (source) {
        // No Placeholders
        return l10n.chat_select_category;
      },
      'chat_select_target_category': (source) {
        // No Placeholders
        return l10n.chat_select_target_category;
      },
      'chat_send': (source) {
        // No Placeholders
        return l10n.chat_send;
      },
      'chat_send_message': (source) {
        // No Placeholders
        return l10n.chat_send_message;
      },
      'chat_send_message_label': (source) {
        // No Placeholders
        return l10n.chat_send_message_label;
      },
      'chat_send_message_need_ai': (source) {
        // No Placeholders
        return l10n.chat_send_message_need_ai;
      },
      'chat_session_n_messages': (source) {
        // Has Placeholders
        var index = 0;
        String n = source.arguments[index];
        index++;
        return l10n.chat_session_n_messages(n);
      },
      'chat_sources': (source) {
        // No Placeholders
        return l10n.chat_sources;
      },
      'chat_start_conversation_hint': (source) {
        // No Placeholders
        return l10n.chat_start_conversation_hint;
      },
      'chat_test_connection': (source) {
        // No Placeholders
        return l10n.chat_test_connection;
      },
      'chat_token_usage': (source) {
        // No Placeholders
        return l10n.chat_token_usage;
      },
      'chat_user_label': (source) {
        // No Placeholders
        return l10n.chat_user_label;
      },
      'chat_voice_input': (source) {
        // No Placeholders
        return l10n.chat_voice_input;
      },
      'chat_voice_input_label': (source) {
        // No Placeholders
        return l10n.chat_voice_input_label;
      },
      'chat_voice_real_device': (source) {
        // No Placeholders
        return l10n.chat_voice_real_device;
      },
      'chat_voice_real_device_label': (source) {
        // No Placeholders
        return l10n.chat_voice_real_device_label;
      },
      'chat_web': (source) {
        // No Placeholders
        return l10n.chat_web;
      },
      'chat_web_search': (source) {
        // No Placeholders
        return l10n.chat_web_search;
      },
      'core_ai_role': (source) {
        // No Placeholders
        return l10n.core_ai_role;
      },
      'core_answer': (source) {
        // No Placeholders
        return l10n.core_answer;
      },
      'core_anthropic_embedding_not_supported': (source) {
        // No Placeholders
        return l10n.core_anthropic_embedding_not_supported;
      },
      'core_api_rate_limited': (source) {
        // No Placeholders
        return l10n.core_api_rate_limited;
      },
      'core_available_memory': (source) {
        // No Placeholders
        return l10n.core_available_memory;
      },
      'core_back': (source) {
        // No Placeholders
        return l10n.core_back;
      },
      'core_backup': (source) {
        // No Placeholders
        return l10n.core_backup;
      },
      'core_cancel': (source) {
        // No Placeholders
        return l10n.core_cancel;
      },
      'core_category': (source) {
        // No Placeholders
        return l10n.core_category;
      },
      'core_confirm': (source) {
        // No Placeholders
        return l10n.core_confirm;
      },
      'core_continue_import': (source) {
        // No Placeholders
        return l10n.core_continue_import;
      },
      'core_conversation': (source) {
        // No Placeholders
        return l10n.core_conversation;
      },
      'core_conversation_empty_archive': (source) {
        // No Placeholders
        return l10n.core_conversation_empty_archive;
      },
      'core_conversation_not_found': (source) {
        // No Placeholders
        return l10n.core_conversation_not_found;
      },
      'core_daily_quiz': (source) {
        // No Placeholders
        return l10n.core_daily_quiz;
      },
      'core_delete': (source) {
        // No Placeholders
        return l10n.core_delete;
      },
      'core_document': (source) {
        // No Placeholders
        return l10n.core_document;
      },
      'core_download_failed': (source) {
        // No Placeholders
        return l10n.core_download_failed;
      },
      'core_edit': (source) {
        // No Placeholders
        return l10n.core_edit;
      },
      'core_embedding_generation_failed': (source) {
        // No Placeholders
        return l10n.core_embedding_generation_failed;
      },
      'core_error': (source) {
        // No Placeholders
        return l10n.core_error;
      },
      'core_exam': (source) {
        // No Placeholders
        return l10n.core_exam;
      },
      'core_exam_not_found': (source) {
        // No Placeholders
        return l10n.core_exam_not_found;
      },
      'core_feedback': (source) {
        // No Placeholders
        return l10n.core_feedback;
      },
      'core_fill_in_the_blank': (source) {
        // No Placeholders
        return l10n.core_fill_in_the_blank;
      },
      'core_grading_failed': (source) {
        // No Placeholders
        return l10n.core_grading_failed;
      },
      'core_grading_result_parsing_failed': (source) {
        // No Placeholders
        return l10n.core_grading_result_parsing_failed;
      },
      'core_invalid_api_id': (source) {
        // No Placeholders
        return l10n.core_invalid_api_id;
      },
      'core_json_parse_failed': (source) {
        // No Placeholders
        return l10n.core_json_parse_failed;
      },
      'core_knowledge_base': (source) {
        // No Placeholders
        return l10n.core_knowledge_base;
      },
      'core_loading': (source) {
        // No Placeholders
        return l10n.core_loading;
      },
      'core_loading_failed': (source) {
        // No Placeholders
        return l10n.core_loading_failed;
      },
      'core_local_import': (source) {
        // No Placeholders
        return l10n.core_local_import;
      },
      'core_local_model_loading_failed': (source) {
        // No Placeholders
        return l10n.core_local_model_loading_failed;
      },
      'core_local_model_not_loaded': (source) {
        // No Placeholders
        return l10n.core_local_model_not_loaded;
      },
      'core_memory_insufficient': (source) {
        // No Placeholders
        return l10n.core_memory_insufficient;
      },
      'core_message': (source) {
        // No Placeholders
        return l10n.core_message;
      },
      'core_mirror_china': (source) {
        // No Placeholders
        return l10n.core_mirror_china;
      },
      'core_mirror_global': (source) {
        // No Placeholders
        return l10n.core_mirror_global;
      },
      'core_model_delete': (source) {
        // No Placeholders
        return l10n.core_model_delete;
      },
      'core_model_download': (source) {
        // No Placeholders
        return l10n.core_model_download;
      },
      'core_model_in_use': (source) {
        // No Placeholders
        return l10n.core_model_in_use;
      },
      'core_model_load': (source) {
        // No Placeholders
        return l10n.core_model_load;
      },
      'core_model_loaded': (source) {
        // No Placeholders
        return l10n.core_model_loaded;
      },
      'core_model_may_not_run': (source) {
        // Has Placeholders
        var index = 0;
        String size = source.arguments[index];
        index++;
        String mem = source.arguments[index];
        index++;
        return l10n.core_model_may_not_run(size, mem);
      },
      'core_model_no_download_source': (source) {
        // No Placeholders
        return l10n.core_model_no_download_source;
      },
      'core_model_not_compatible': (source) {
        // No Placeholders
        return l10n.core_model_not_compatible;
      },
      'core_model_requires_ram': (source) {
        // Has Placeholders
        var index = 0;
        String minRam = source.arguments[index];
        index++;
        return l10n.core_model_requires_ram(minRam);
      },
      'core_model_retry': (source) {
        // No Placeholders
        return l10n.core_model_retry;
      },
      'core_monthly_exam_2': (source) {
        // No Placeholders
        return l10n.core_monthly_exam_2;
      },
      'core_multiple_choice': (source) {
        // No Placeholders
        return l10n.core_multiple_choice;
      },
      'core_network_request_failed': (source) {
        // No Placeholders
        return l10n.core_network_request_failed;
      },
      'core_new': (source) {
        // No Placeholders
        return l10n.core_new;
      },
      'core_no': (source) {
        // No Placeholders
        return l10n.core_no;
      },
      'core_ok': (source) {
        // No Placeholders
        return l10n.core_ok;
      },
      'core_please_override_in_main_dart': (source) {
        // No Placeholders
        return l10n.core_please_override_in_main_dart;
      },
      'core_profile': (source) {
        // No Placeholders
        return l10n.core_profile;
      },
      'core_progress_backup_complete': (source) {
        // No Placeholders
        return l10n.core_progress_backup_complete;
      },
      'core_progress_decompressing': (source) {
        // No Placeholders
        return l10n.core_progress_decompressing;
      },
      'core_progress_downloading': (source) {
        // No Placeholders
        return l10n.core_progress_downloading;
      },
      'core_progress_packing': (source) {
        // No Placeholders
        return l10n.core_progress_packing;
      },
      'core_progress_restore_complete': (source) {
        // No Placeholders
        return l10n.core_progress_restore_complete;
      },
      'core_progress_uploading': (source) {
        // No Placeholders
        return l10n.core_progress_uploading;
      },
      'core_quarterly_exam_2': (source) {
        // No Placeholders
        return l10n.core_quarterly_exam_2;
      },
      'core_question': (source) {
        // No Placeholders
        return l10n.core_question;
      },
      'core_quiz': (source) {
        // No Placeholders
        return l10n.core_quiz;
      },
      'core_random_quick_review': (source) {
        // No Placeholders
        return l10n.core_random_quick_review;
      },
      'core_reading': (source) {
        // No Placeholders
        return l10n.core_reading;
      },
      'core_remote_sync_failed': (source) {
        // No Placeholders
        return l10n.core_remote_sync_failed;
      },
      'core_remote_template_format_error': (source) {
        // No Placeholders
        return l10n.core_remote_template_format_error;
      },
      'core_request_failed': (source) {
        // No Placeholders
        return l10n.core_request_failed;
      },
      'core_restore': (source) {
        // No Placeholders
        return l10n.core_restore;
      },
      'core_retry': (source) {
        // No Placeholders
        return l10n.core_retry;
      },
      'core_save': (source) {
        // No Placeholders
        return l10n.core_save;
      },
      'core_score': (source) {
        // No Placeholders
        return l10n.core_score;
      },
      'core_search': (source) {
        // No Placeholders
        return l10n.core_search;
      },
      'core_send': (source) {
        // No Placeholders
        return l10n.core_send;
      },
      'core_service_unavailable': (source) {
        // No Placeholders
        return l10n.core_service_unavailable;
      },
      'core_settings': (source) {
        // No Placeholders
        return l10n.core_settings;
      },
      'core_short_answer': (source) {
        // No Placeholders
        return l10n.core_short_answer;
      },
      'core_single_choice': (source) {
        // No Placeholders
        return l10n.core_single_choice;
      },
      'core_statistics': (source) {
        // No Placeholders
        return l10n.core_statistics;
      },
      'core_success': (source) {
        // No Placeholders
        return l10n.core_success;
      },
      'core_tap_to_start_answering': (source) {
        // No Placeholders
        return l10n.core_tap_to_start_answering;
      },
      'core_today_quiz_ready': (source) {
        // No Placeholders
        return l10n.core_today_quiz_ready;
      },
      'core_total_memory': (source) {
        // No Placeholders
        return l10n.core_total_memory;
      },
      'core_true_false': (source) {
        // No Placeholders
        return l10n.core_true_false;
      },
      'core_unnamed_document': (source) {
        // No Placeholders
        return l10n.core_unnamed_document;
      },
      'core_user_role': (source) {
        // No Placeholders
        return l10n.core_user_role;
      },
      'core_webdav_not_configured': (source) {
        // No Placeholders
        return l10n.core_webdav_not_configured;
      },
      'core_wrong_question_review': (source) {
        // No Placeholders
        return l10n.core_wrong_question_review;
      },
      'core_yearly_exam_2': (source) {
        // No Placeholders
        return l10n.core_yearly_exam_2;
      },
      'core_yes': (source) {
        // No Placeholders
        return l10n.core_yes;
      },
      'knode_app_about': (source) {
        // No Placeholders
        return l10n.knode_app_about;
      },
      'knode_app_account': (source) {
        // No Placeholders
        return l10n.knode_app_account;
      },
      'knode_app_advanced_settings': (source) {
        // No Placeholders
        return l10n.knode_app_advanced_settings;
      },
      'knode_app_ai_engine': (source) {
        // No Placeholders
        return l10n.knode_app_ai_engine;
      },
      'knode_app_ai_engine_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_ai_engine_subtitle;
      },
      'knode_app_ai_label': (source) {
        // No Placeholders
        return l10n.knode_app_ai_label;
      },
      'knode_app_ai_settings': (source) {
        // No Placeholders
        return l10n.knode_app_ai_settings;
      },
      'knode_app_api_base_url': (source) {
        // No Placeholders
        return l10n.knode_app_api_base_url;
      },
      'knode_app_api_protocol': (source) {
        // No Placeholders
        return l10n.knode_app_api_protocol;
      },
      'knode_app_app_shell': (source) {
        // No Placeholders
        return l10n.knode_app_app_shell;
      },
      'knode_app_application_log': (source) {
        // No Placeholders
        return l10n.knode_app_application_log;
      },
      'knode_app_archive_title': (source) {
        // No Placeholders
        return l10n.knode_app_archive_title;
      },
      'knode_app_auto_backup': (source) {
        // No Placeholders
        return l10n.knode_app_auto_backup;
      },
      'knode_app_available_memory': (source) {
        // Has Placeholders
        var index = 0;
        String memory = source.arguments[index];
        index++;
        return l10n.knode_app_available_memory(memory);
      },
      'knode_app_available_memory_label': (source) {
        // No Placeholders
        return l10n.knode_app_available_memory_label;
      },
      'knode_app_backup': (source) {
        // No Placeholders
        return l10n.knode_app_backup;
      },
      'knode_app_backup_complete': (source) {
        // No Placeholders
        return l10n.knode_app_backup_complete;
      },
      'knode_app_backup_failed': (source) {
        // No Placeholders
        return l10n.knode_app_backup_failed;
      },
      'knode_app_backup_frequency': (source) {
        // No Placeholders
        return l10n.knode_app_backup_frequency;
      },
      'knode_app_backup_frequency_label': (source) {
        // No Placeholders
        return l10n.knode_app_backup_frequency_label;
      },
      'knode_app_backup_history': (source) {
        // No Placeholders
        return l10n.knode_app_backup_history;
      },
      'knode_app_backup_now': (source) {
        // No Placeholders
        return l10n.knode_app_backup_now;
      },
      'knode_app_backup_now_label': (source) {
        // No Placeholders
        return l10n.knode_app_backup_now_label;
      },
      'knode_app_backup_settings': (source) {
        // No Placeholders
        return l10n.knode_app_backup_settings;
      },
      'knode_app_backup_type_local': (source) {
        // No Placeholders
        return l10n.knode_app_backup_type_local;
      },
      'knode_app_backup_type_webdav': (source) {
        // No Placeholders
        return l10n.knode_app_backup_type_webdav;
      },
      'knode_app_based_on_recent': (source) {
        // No Placeholders
        return l10n.knode_app_based_on_recent;
      },
      'knode_app_both_not_configured': (source) {
        // No Placeholders
        return l10n.knode_app_both_not_configured;
      },
      'knode_app_bottom_navigation': (source) {
        // No Placeholders
        return l10n.knode_app_bottom_navigation;
      },
      'knode_app_browse_history': (source) {
        // No Placeholders
        return l10n.knode_app_browse_history;
      },
      'knode_app_cancel': (source) {
        // No Placeholders
        return l10n.knode_app_cancel;
      },
      'knode_app_check_update': (source) {
        // No Placeholders
        return l10n.knode_app_check_update;
      },
      'knode_app_checksum_failed': (source) {
        // No Placeholders
        return l10n.knode_app_checksum_failed;
      },
      'knode_app_clear_cache': (source) {
        // No Placeholders
        return l10n.knode_app_clear_cache;
      },
      'knode_app_cloud_api': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_api;
      },
      'knode_app_cloud_api_label': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_api_label;
      },
      'knode_app_cloud_config': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_config;
      },
      'knode_app_cloud_model_repo_url': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_model_repo_url;
      },
      'knode_app_cloud_model_repo_url_label': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_model_repo_url_label;
      },
      'knode_app_cloud_sync': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_sync;
      },
      'knode_app_config_api_key_first': (source) {
        // No Placeholders
        return l10n.knode_app_config_api_key_first;
      },
      'knode_app_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_confirm;
      },
      'knode_app_confirm_restore': (source) {
        // No Placeholders
        return l10n.knode_app_confirm_restore;
      },
      'knode_app_connection_failed': (source) {
        // No Placeholders
        return l10n.knode_app_connection_failed;
      },
      'knode_app_connection_success': (source) {
        // No Placeholders
        return l10n.knode_app_connection_success;
      },
      'knode_app_copied_to_clipboard': (source) {
        // No Placeholders
        return l10n.knode_app_copied_to_clipboard;
      },
      'knode_app_copy': (source) {
        // No Placeholders
        return l10n.knode_app_copy;
      },
      'knode_app_correct_n_of_m': (source) {
        // Has Placeholders
        var index = 0;
        String n = source.arguments[index];
        index++;
        String m = source.arguments[index];
        index++;
        return l10n.knode_app_correct_n_of_m(n, m);
      },
      'knode_app_current_storage_path': (source) {
        // No Placeholders
        return l10n.knode_app_current_storage_path;
      },
      'knode_app_custom': (source) {
        // No Placeholders
        return l10n.knode_app_custom;
      },
      'knode_app_custom_label': (source) {
        // No Placeholders
        return l10n.knode_app_custom_label;
      },
      'knode_app_daily': (source) {
        // No Placeholders
        return l10n.knode_app_daily;
      },
      'knode_app_daily_card': (source) {
        // No Placeholders
        return l10n.knode_app_daily_card;
      },
      'knode_app_daily_encouragement': (source) {
        // No Placeholders
        return l10n.knode_app_daily_encouragement;
      },
      'knode_app_daily_label': (source) {
        // No Placeholders
        return l10n.knode_app_daily_label;
      },
      'knode_app_daily_quiz_started': (source) {
        // No Placeholders
        return l10n.knode_app_daily_quiz_started;
      },
      'knode_app_dark_mode': (source) {
        // No Placeholders
        return l10n.knode_app_dark_mode;
      },
      'knode_app_decompressing': (source) {
        // No Placeholders
        return l10n.knode_app_decompressing;
      },
      'knode_app_default_exam_title': (source) {
        // No Placeholders
        return l10n.knode_app_default_exam_title;
      },
      'knode_app_delete': (source) {
        // No Placeholders
        return l10n.knode_app_delete;
      },
      'knode_app_delete_backup_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_delete_backup_confirm;
      },
      'knode_app_delete_failed': (source) {
        // No Placeholders
        return l10n.knode_app_delete_failed;
      },
      'knode_app_description': (source) {
        // No Placeholders
        return l10n.knode_app_description;
      },
      'knode_app_download_failed': (source) {
        // No Placeholders
        return l10n.knode_app_download_failed;
      },
      'knode_app_download_label': (source) {
        // No Placeholders
        return l10n.knode_app_download_label;
      },
      'knode_app_downloading': (source) {
        // No Placeholders
        return l10n.knode_app_downloading;
      },
      'knode_app_enable_micro_server': (source) {
        // No Placeholders
        return l10n.knode_app_enable_micro_server;
      },
      'knode_app_enable_micro_server_desc': (source) {
        // No Placeholders
        return l10n.knode_app_enable_micro_server_desc;
      },
      'knode_app_error': (source) {
        // No Placeholders
        return l10n.knode_app_error;
      },
      'knode_app_export_data': (source) {
        // No Placeholders
        return l10n.knode_app_export_data;
      },
      'knode_app_export_success': (source) {
        // No Placeholders
        return l10n.knode_app_export_success;
      },
      'knode_app_export_warning': (source) {
        // No Placeholders
        return l10n.knode_app_export_warning;
      },
      'knode_app_favorites': (source) {
        // No Placeholders
        return l10n.knode_app_favorites;
      },
      'knode_app_feedback': (source) {
        // No Placeholders
        return l10n.knode_app_feedback;
      },
      'knode_app_fetch': (source) {
        // No Placeholders
        return l10n.knode_app_fetch;
      },
      'knode_app_fetch_failed_use_cache': (source) {
        // No Placeholders
        return l10n.knode_app_fetch_failed_use_cache;
      },
      'knode_app_fetch_or_import_hint': (source) {
        // No Placeholders
        return l10n.knode_app_fetch_or_import_hint;
      },
      'knode_app_file_too_large': (source) {
        // No Placeholders
        return l10n.knode_app_file_too_large;
      },
      'knode_app_font_size': (source) {
        // No Placeholders
        return l10n.knode_app_font_size;
      },
      'knode_app_font_size_label': (source) {
        // No Placeholders
        return l10n.knode_app_font_size_label;
      },
      'knode_app_get_backup_list_failed': (source) {
        // No Placeholders
        return l10n.knode_app_get_backup_list_failed;
      },
      'knode_app_gguf_only': (source) {
        // No Placeholders
        return l10n.knode_app_gguf_only;
      },
      'knode_app_home': (source) {
        // No Placeholders
        return l10n.knode_app_home;
      },
      'knode_app_import_count': (source) {
        // Has Placeholders
        var index = 0;
        String count = source.arguments[index];
        index++;
        return l10n.knode_app_import_count(count);
      },
      'knode_app_import_data': (source) {
        // No Placeholders
        return l10n.knode_app_import_data;
      },
      'knode_app_import_failed': (source) {
        // No Placeholders
        return l10n.knode_app_import_failed;
      },
      'knode_app_import_file': (source) {
        // No Placeholders
        return l10n.knode_app_import_file;
      },
      'knode_app_import_json_hint': (source) {
        // No Placeholders
        return l10n.knode_app_import_json_hint;
      },
      'knode_app_import_local_model': (source) {
        // No Placeholders
        return l10n.knode_app_import_local_model;
      },
      'knode_app_import_success': (source) {
        // No Placeholders
        return l10n.knode_app_import_success;
      },
      'knode_app_input_api_key': (source) {
        // No Placeholders
        return l10n.knode_app_input_api_key;
      },
      'knode_app_invalid_json': (source) {
        // No Placeholders
        return l10n.knode_app_invalid_json;
      },
      'knode_app_keep_backup_count': (source) {
        // No Placeholders
        return l10n.knode_app_keep_backup_count;
      },
      'knode_app_keep_backup_desc': (source) {
        // Has Placeholders
        var index = 0;
        String n = source.arguments[index];
        index++;
        return l10n.knode_app_keep_backup_desc(n);
      },
      'knode_app_language': (source) {
        // No Placeholders
        return l10n.knode_app_language;
      },
      'knode_app_license': (source) {
        // No Placeholders
        return l10n.knode_app_license;
      },
      'knode_app_light_mode': (source) {
        // No Placeholders
        return l10n.knode_app_light_mode;
      },
      'knode_app_line_spacing': (source) {
        // No Placeholders
        return l10n.knode_app_line_spacing;
      },
      'knode_app_load_failed': (source) {
        // No Placeholders
        return l10n.knode_app_load_failed;
      },
      'knode_app_load_label': (source) {
        // No Placeholders
        return l10n.knode_app_load_label;
      },
      'knode_app_loaded': (source) {
        // No Placeholders
        return l10n.knode_app_loaded;
      },
      'knode_app_loading': (source) {
        // No Placeholders
        return l10n.knode_app_loading;
      },
      'knode_app_local_backup': (source) {
        // No Placeholders
        return l10n.knode_app_local_backup;
      },
      'knode_app_local_backup_config_needed': (source) {
        // No Placeholders
        return l10n.knode_app_local_backup_config_needed;
      },
      'knode_app_local_backup_last_backup': (source) {
        // Has Placeholders
        var index = 0;
        String time = source.arguments[index];
        index++;
        return l10n.knode_app_local_backup_last_backup(time);
      },
      'knode_app_local_backup_not_configured': (source) {
        // No Placeholders
        return l10n.knode_app_local_backup_not_configured;
      },
      'knode_app_local_backup_path': (source) {
        // No Placeholders
        return l10n.knode_app_local_backup_path;
      },
      'knode_app_local_backup_path_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_local_backup_path_subtitle;
      },
      'knode_app_local_backup_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_local_backup_subtitle;
      },
      'knode_app_local_model': (source) {
        // No Placeholders
        return l10n.knode_app_local_model;
      },
      'knode_app_local_model_label': (source) {
        // No Placeholders
        return l10n.knode_app_local_model_label;
      },
      'knode_app_local_restore': (source) {
        // No Placeholders
        return l10n.knode_app_local_restore;
      },
      'knode_app_log_all': (source) {
        // No Placeholders
        return l10n.knode_app_log_all;
      },
      'knode_app_log_clear': (source) {
        // No Placeholders
        return l10n.knode_app_log_clear;
      },
      'knode_app_log_clear_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_log_clear_confirm;
      },
      'knode_app_log_clear_success': (source) {
        // No Placeholders
        return l10n.knode_app_log_clear_success;
      },
      'knode_app_log_copied': (source) {
        // No Placeholders
        return l10n.knode_app_log_copied;
      },
      'knode_app_log_detail': (source) {
        // No Placeholders
        return l10n.knode_app_log_detail;
      },
      'knode_app_log_error_info': (source) {
        // No Placeholders
        return l10n.knode_app_log_error_info;
      },
      'knode_app_log_export': (source) {
        // No Placeholders
        return l10n.knode_app_log_export;
      },
      'knode_app_log_export_success': (source) {
        // No Placeholders
        return l10n.knode_app_log_export_success;
      },
      'knode_app_log_level': (source) {
        // No Placeholders
        return l10n.knode_app_log_level;
      },
      'knode_app_log_no_logs': (source) {
        // No Placeholders
        return l10n.knode_app_log_no_logs;
      },
      'knode_app_log_search': (source) {
        // No Placeholders
        return l10n.knode_app_log_search;
      },
      'knode_app_log_search_hint': (source) {
        // No Placeholders
        return l10n.knode_app_log_search_hint;
      },
      'knode_app_log_stack_trace': (source) {
        // No Placeholders
        return l10n.knode_app_log_stack_trace;
      },
      'knode_app_log_viewer': (source) {
        // No Placeholders
        return l10n.knode_app_log_viewer;
      },
      'knode_app_manual': (source) {
        // No Placeholders
        return l10n.knode_app_manual;
      },
      'knode_app_manual_operation': (source) {
        // No Placeholders
        return l10n.knode_app_manual_operation;
      },
      'knode_app_manual_operations': (source) {
        // No Placeholders
        return l10n.knode_app_manual_operations;
      },
      'knode_app_migrate_and_change': (source) {
        // No Placeholders
        return l10n.knode_app_migrate_and_change;
      },
      'knode_app_migrate_files_confirm': (source) {
        // Has Placeholders
        var index = 0;
        String path = source.arguments[index];
        index++;
        return l10n.knode_app_migrate_files_confirm(path);
      },
      'knode_app_migrated_n_files': (source) {
        // Has Placeholders
        var index = 0;
        String n = source.arguments[index];
        index++;
        return l10n.knode_app_migrated_n_files(n);
      },
      'knode_app_migration_failed': (source) {
        // No Placeholders
        return l10n.knode_app_migration_failed;
      },
      'knode_app_mirror_not_found': (source) {
        // Has Placeholders
        var index = 0;
        String key = source.arguments[index];
        index++;
        return l10n.knode_app_mirror_not_found(key);
      },
      'knode_app_model_card': (source) {
        // No Placeholders
        return l10n.knode_app_model_card;
      },
      'knode_app_model_download': (source) {
        // No Placeholders
        return l10n.knode_app_model_download;
      },
      'knode_app_model_label': (source) {
        // No Placeholders
        return l10n.knode_app_model_label;
      },
      'knode_app_model_name_label': (source) {
        // No Placeholders
        return l10n.knode_app_model_name_label;
      },
      'knode_app_model_repo_url': (source) {
        // No Placeholders
        return l10n.knode_app_model_repo_url;
      },
      'knode_app_model_repo_url_label': (source) {
        // No Placeholders
        return l10n.knode_app_model_repo_url_label;
      },
      'knode_app_modify_storage_path': (source) {
        // No Placeholders
        return l10n.knode_app_modify_storage_path;
      },
      'knode_app_module_settings': (source) {
        // No Placeholders
        return l10n.knode_app_module_settings;
      },
      'knode_app_multiple_choice_suffix': (source) {
        // No Placeholders
        return l10n.knode_app_multiple_choice_suffix;
      },
      'knode_app_night_mode': (source) {
        // No Placeholders
        return l10n.knode_app_night_mode;
      },
      'knode_app_no_backups': (source) {
        // No Placeholders
        return l10n.knode_app_no_backups;
      },
      'knode_app_no_backups_available': (source) {
        // No Placeholders
        return l10n.knode_app_no_backups_available;
      },
      'knode_app_no_cleanup': (source) {
        // No Placeholders
        return l10n.knode_app_no_cleanup;
      },
      'knode_app_no_custom_templates': (source) {
        // No Placeholders
        return l10n.knode_app_no_custom_templates;
      },
      'knode_app_no_download_source': (source) {
        // No Placeholders
        return l10n.knode_app_no_download_source;
      },
      'knode_app_no_exam_records': (source) {
        // No Placeholders
        return l10n.knode_app_no_exam_records;
      },
      'knode_app_no_key_hint': (source) {
        // No Placeholders
        return l10n.knode_app_no_key_hint;
      },
      'knode_app_no_local_backup': (source) {
        // No Placeholders
        return l10n.knode_app_no_local_backup;
      },
      'knode_app_no_models': (source) {
        // No Placeholders
        return l10n.knode_app_no_models;
      },
      'knode_app_no_templates': (source) {
        // No Placeholders
        return l10n.knode_app_no_templates;
      },
      'knode_app_no_webdav_backup': (source) {
        // No Placeholders
        return l10n.knode_app_no_webdav_backup;
      },
      'knode_app_no_wrong_cards': (source) {
        // No Placeholders
        return l10n.knode_app_no_wrong_cards;
      },
      'knode_app_not_answered': (source) {
        // No Placeholders
        return l10n.knode_app_not_answered;
      },
      'knode_app_notification': (source) {
        // No Placeholders
        return l10n.knode_app_notification;
      },
      'knode_app_options_label': (source) {
        // No Placeholders
        return l10n.knode_app_options_label;
      },
      'knode_app_original_template': (source) {
        // No Placeholders
        return l10n.knode_app_original_template;
      },
      'knode_app_original_template_changed': (source) {
        // No Placeholders
        return l10n.knode_app_original_template_changed;
      },
      'knode_app_packing_files': (source) {
        // No Placeholders
        return l10n.knode_app_packing_files;
      },
      'knode_app_password': (source) {
        // No Placeholders
        return l10n.knode_app_password;
      },
      'knode_app_path_only': (source) {
        // No Placeholders
        return l10n.knode_app_path_only;
      },
      'knode_app_personal_drawer': (source) {
        // No Placeholders
        return l10n.knode_app_personal_drawer;
      },
      'knode_app_port': (source) {
        // No Placeholders
        return l10n.knode_app_port;
      },
      'knode_app_privacy_policy': (source) {
        // No Placeholders
        return l10n.knode_app_privacy_policy;
      },
      'knode_app_profile': (source) {
        // No Placeholders
        return l10n.knode_app_profile;
      },
      'knode_app_progress_backup_complete': (source) {
        // No Placeholders
        return l10n.knode_app_progress_backup_complete;
      },
      'knode_app_progress_decompressing': (source) {
        // No Placeholders
        return l10n.knode_app_progress_decompressing;
      },
      'knode_app_progress_downloading': (source) {
        // No Placeholders
        return l10n.knode_app_progress_downloading;
      },
      'knode_app_progress_packing': (source) {
        // No Placeholders
        return l10n.knode_app_progress_packing;
      },
      'knode_app_progress_restore_complete': (source) {
        // No Placeholders
        return l10n.knode_app_progress_restore_complete;
      },
      'knode_app_progress_uploading': (source) {
        // No Placeholders
        return l10n.knode_app_progress_uploading;
      },
      'knode_app_prompt_edit_hint': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_edit_hint;
      },
      'knode_app_prompt_grader': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_grader;
      },
      'knode_app_prompt_intent': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_intent;
      },
      'knode_app_prompt_management': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_management;
      },
      'knode_app_prompt_management_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_management_subtitle;
      },
      'knode_app_prompt_periodic_exam': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_periodic_exam;
      },
      'knode_app_prompt_question_variant': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_question_variant;
      },
      'knode_app_prompt_quiz_gen': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_quiz_gen;
      },
      'knode_app_prompt_rag_qa': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_rag_qa;
      },
      'knode_app_prompt_search': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_search;
      },
      'knode_app_prompt_summary': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_summary;
      },
      'knode_app_prompt_tag_gen': (source) {
        // No Placeholders
        return l10n.knode_app_prompt_tag_gen;
      },
      'knode_app_quick_card': (source) {
        // No Placeholders
        return l10n.knode_app_quick_card;
      },
      'knode_app_quiz_due_review': (source) {
        // No Placeholders
        return l10n.knode_app_quiz_due_review;
      },
      'knode_app_quiz_settings': (source) {
        // No Placeholders
        return l10n.knode_app_quiz_settings;
      },
      'knode_app_quiz_started_switch_tab': (source) {
        // No Placeholders
        return l10n.knode_app_quiz_started_switch_tab;
      },
      'knode_app_rate_us': (source) {
        // No Placeholders
        return l10n.knode_app_rate_us;
      },
      'knode_app_reset_all': (source) {
        // No Placeholders
        return l10n.knode_app_reset_all;
      },
      'knode_app_reset_all_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_reset_all_confirm;
      },
      'knode_app_reset_override': (source) {
        // No Placeholders
        return l10n.knode_app_reset_override;
      },
      'knode_app_reset_single_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_reset_single_confirm;
      },
      'knode_app_reset_success': (source) {
        // No Placeholders
        return l10n.knode_app_reset_success;
      },
      'knode_app_restore': (source) {
        // No Placeholders
        return l10n.knode_app_restore;
      },
      'knode_app_restore_btn': (source) {
        // No Placeholders
        return l10n.knode_app_restore_btn;
      },
      'knode_app_restore_complete': (source) {
        // No Placeholders
        return l10n.knode_app_restore_complete;
      },
      'knode_app_restore_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_restore_confirm;
      },
      'knode_app_restore_confirm_msg': (source) {
        // No Placeholders
        return l10n.knode_app_restore_confirm_msg;
      },
      'knode_app_restore_data': (source) {
        // No Placeholders
        return l10n.knode_app_restore_data;
      },
      'knode_app_restore_failed': (source) {
        // No Placeholders
        return l10n.knode_app_restore_failed;
      },
      'knode_app_retry': (source) {
        // No Placeholders
        return l10n.knode_app_retry;
      },
      'knode_app_save': (source) {
        // No Placeholders
        return l10n.knode_app_save;
      },
      'knode_app_save_success': (source) {
        // No Placeholders
        return l10n.knode_app_save_success;
      },
      'knode_app_score_card': (source) {
        // No Placeholders
        return l10n.knode_app_score_card;
      },
      'knode_app_score_n_points': (source) {
        // Has Placeholders
        var index = 0;
        String n = source.arguments[index];
        index++;
        return l10n.knode_app_score_n_points(n);
      },
      'knode_app_search_api_key': (source) {
        // No Placeholders
        return l10n.knode_app_search_api_key;
      },
      'knode_app_select_restore_source': (source) {
        // No Placeholders
        return l10n.knode_app_select_restore_source;
      },
      'knode_app_select_restore_version': (source) {
        // No Placeholders
        return l10n.knode_app_select_restore_version;
      },
      'knode_app_select_search_provider': (source) {
        // No Placeholders
        return l10n.knode_app_select_search_provider;
      },
      'knode_app_server_settings': (source) {
        // No Placeholders
        return l10n.knode_app_server_settings;
      },
      'knode_app_service_provider': (source) {
        // No Placeholders
        return l10n.knode_app_service_provider;
      },
      'knode_app_session_n_messages': (source) {
        // Has Placeholders
        var index = 0;
        String n = source.arguments[index];
        index++;
        return l10n.knode_app_session_n_messages(n);
      },
      'knode_app_settings': (source) {
        // No Placeholders
        return l10n.knode_app_settings;
      },
      'knode_app_share': (source) {
        // No Placeholders
        return l10n.knode_app_share;
      },
      'knode_app_share_logs_subject': (source) {
        // No Placeholders
        return l10n.knode_app_share_logs_subject;
      },
      'knode_app_skip_memory_check': (source) {
        // No Placeholders
        return l10n.knode_app_skip_memory_check;
      },
      'knode_app_skip_memory_check_desc': (source) {
        // No Placeholders
        return l10n.knode_app_skip_memory_check_desc;
      },
      'knode_app_sound': (source) {
        // No Placeholders
        return l10n.knode_app_sound;
      },
      'knode_app_source_not_found': (source) {
        // Has Placeholders
        var index = 0;
        String path = source.arguments[index];
        index++;
        return l10n.knode_app_source_not_found(path);
      },
      'knode_app_start_practice': (source) {
        // No Placeholders
        return l10n.knode_app_start_practice;
      },
      'knode_app_storage_migration_hint_1': (source) {
        // No Placeholders
        return l10n.knode_app_storage_migration_hint_1;
      },
      'knode_app_storage_migration_hint_2': (source) {
        // No Placeholders
        return l10n.knode_app_storage_migration_hint_2;
      },
      'knode_app_storage_migration_hint_3': (source) {
        // No Placeholders
        return l10n.knode_app_storage_migration_hint_3;
      },
      'knode_app_storage_path': (source) {
        // No Placeholders
        return l10n.knode_app_storage_path;
      },
      'knode_app_storage_path_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_storage_path_subtitle;
      },
      'knode_app_storage_path_updated': (source) {
        // No Placeholders
        return l10n.knode_app_storage_path_updated;
      },
      'knode_app_storage_settings': (source) {
        // No Placeholders
        return l10n.knode_app_storage_settings;
      },
      'knode_app_storage_space': (source) {
        // No Placeholders
        return l10n.knode_app_storage_space;
      },
      'knode_app_storage_usage': (source) {
        // No Placeholders
        return l10n.knode_app_storage_usage;
      },
      'knode_app_success': (source) {
        // No Placeholders
        return l10n.knode_app_success;
      },
      'knode_app_switch_to_quiz_tab': (source) {
        // No Placeholders
        return l10n.knode_app_switch_to_quiz_tab;
      },
      'knode_app_system_default': (source) {
        // No Placeholders
        return l10n.knode_app_system_default;
      },
      'knode_app_tap_to_start': (source) {
        // No Placeholders
        return l10n.knode_app_tap_to_start;
      },
      'knode_app_test_connection': (source) {
        // No Placeholders
        return l10n.knode_app_test_connection;
      },
      'knode_app_testing': (source) {
        // No Placeholders
        return l10n.knode_app_testing;
      },
      'knode_app_theme': (source) {
        // No Placeholders
        return l10n.knode_app_theme;
      },
      'knode_app_unnamed_document': (source) {
        // No Placeholders
        return l10n.knode_app_unnamed_document;
      },
      'knode_app_upload_failed': (source) {
        // No Placeholders
        return l10n.knode_app_upload_failed;
      },
      'knode_app_uploading': (source) {
        // No Placeholders
        return l10n.knode_app_uploading;
      },
      'knode_app_user': (source) {
        // No Placeholders
        return l10n.knode_app_user;
      },
      'knode_app_user_label': (source) {
        // No Placeholders
        return l10n.knode_app_user_label;
      },
      'knode_app_variables': (source) {
        // No Placeholders
        return l10n.knode_app_variables;
      },
      'knode_app_version': (source) {
        // No Placeholders
        return l10n.knode_app_version;
      },
      'knode_app_vibration': (source) {
        // No Placeholders
        return l10n.knode_app_vibration;
      },
      'knode_app_view_logs': (source) {
        // No Placeholders
        return l10n.knode_app_view_logs;
      },
      'knode_app_view_operation_logs_and_error_records': (source) {
        // No Placeholders
        return l10n.knode_app_view_operation_logs_and_error_records;
      },
      'knode_app_view_source': (source) {
        // No Placeholders
        return l10n.knode_app_view_source;
      },
      'knode_app_web_search': (source) {
        // No Placeholders
        return l10n.knode_app_web_search;
      },
      'knode_app_web_search_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_web_search_subtitle;
      },
      'knode_app_webdav': (source) {
        // No Placeholders
        return l10n.knode_app_webdav;
      },
      'knode_app_webdav_last_backup': (source) {
        // Has Placeholders
        var index = 0;
        String time = source.arguments[index];
        index++;
        return l10n.knode_app_webdav_last_backup(time);
      },
      'knode_app_webdav_not_configured': (source) {
        // No Placeholders
        return l10n.knode_app_webdav_not_configured;
      },
      'knode_app_webdav_restore': (source) {
        // No Placeholders
        return l10n.knode_app_webdav_restore;
      },
      'knode_app_webdav_server': (source) {
        // No Placeholders
        return l10n.knode_app_webdav_server;
      },
      'knode_app_webdav_subtitle': (source) {
        // No Placeholders
        return l10n.knode_app_webdav_subtitle;
      },
      'knode_app_weekly': (source) {
        // No Placeholders
        return l10n.knode_app_weekly;
      },
      'knode_app_weekly_label': (source) {
        // No Placeholders
        return l10n.knode_app_weekly_label;
      },
      'knode_app_welcome_back': (source) {
        // No Placeholders
        return l10n.knode_app_welcome_back;
      },
      'knode_app_wiki_settings': (source) {
        // No Placeholders
        return l10n.knode_app_wiki_settings;
      },
      'knode_app_wrong_card': (source) {
        // No Placeholders
        return l10n.knode_app_wrong_card;
      },
      'micro_server_answer_submission_failed': (source) {
        // No Placeholders
        return l10n.micro_server_answer_submission_failed;
      },
      'micro_server_cors_preflight_request': (source) {
        // No Placeholders
        return l10n.micro_server_cors_preflight_request;
      },
      'micro_server_document_does_not_exist': (source) {
        // No Placeholders
        return l10n.micro_server_document_does_not_exist;
      },
      'micro_server_document_list_retrieval_failed': (source) {
        // No Placeholders
        return l10n.micro_server_document_list_retrieval_failed;
      },
      'micro_server_document_retrieval_failed': (source) {
        // No Placeholders
        return l10n.micro_server_document_retrieval_failed;
      },
      'micro_server_download_failed': (source) {
        // No Placeholders
        return l10n.micro_server_download_failed;
      },
      'micro_server_file_list_retrieval_failed': (source) {
        // No Placeholders
        return l10n.micro_server_file_list_retrieval_failed;
      },
      'micro_server_file_not_found': (source) {
        // No Placeholders
        return l10n.micro_server_file_not_found;
      },
      'micro_server_internal_server_error': (source) {
        // No Placeholders
        return l10n.micro_server_internal_server_error;
      },
      'micro_server_invalid_document_id': (source) {
        // No Placeholders
        return l10n.micro_server_invalid_document_id;
      },
      'micro_server_invalid_request': (source) {
        // No Placeholders
        return l10n.micro_server_invalid_request;
      },
      'micro_server_missing_questionId': (source) {
        // No Placeholders
        return l10n.micro_server_missing_questionId;
      },
      'micro_server_not_found': (source) {
        // No Placeholders
        return l10n.micro_server_not_found;
      },
      'micro_server_port': (source) {
        // No Placeholders
        return l10n.micro_server_port;
      },
      'micro_server_question_does_not_exist': (source) {
        // No Placeholders
        return l10n.micro_server_question_does_not_exist;
      },
      'micro_server_question_retrieval_failed': (source) {
        // No Placeholders
        return l10n.micro_server_question_retrieval_failed;
      },
      'micro_server_request_body_empty': (source) {
        // No Placeholders
        return l10n.micro_server_request_body_empty;
      },
      'micro_server_server_address': (source) {
        // No Placeholders
        return l10n.micro_server_server_address;
      },
      'micro_server_server_already_running': (source) {
        // No Placeholders
        return l10n.micro_server_server_already_running;
      },
      'micro_server_server_not_running': (source) {
        // No Placeholders
        return l10n.micro_server_server_not_running;
      },
      'micro_server_server_started_on_port': (source) {
        // No Placeholders
        return l10n.micro_server_server_started_on_port;
      },
      'micro_server_server_stopped': (source) {
        // No Placeholders
        return l10n.micro_server_server_stopped;
      },
      'micro_server_starting_server': (source) {
        // No Placeholders
        return l10n.micro_server_starting_server;
      },
      'micro_server_stopping_server': (source) {
        // No Placeholders
        return l10n.micro_server_stopping_server;
      },
      'micro_server_upload_confirmed': (source) {
        // No Placeholders
        return l10n.micro_server_upload_confirmed;
      },
      'micro_server_upload_failed': (source) {
        // No Placeholders
        return l10n.micro_server_upload_failed;
      },
      'micro_server_upload_pending_confirmation': (source) {
        // No Placeholders
        return l10n.micro_server_upload_pending_confirmation;
      },
      'micro_server_upload_rejected': (source) {
        // No Placeholders
        return l10n.micro_server_upload_rejected;
      },
      'micro_server_waiting_for_device_confirmation': (source) {
        // No Placeholders
        return l10n.micro_server_waiting_for_device_confirmation;
      },
      'quiz_accuracy': (source) {
        // No Placeholders
        return l10n.quiz_accuracy;
      },
      'quiz_add_note': (source) {
        // No Placeholders
        return l10n.quiz_add_note;
      },
      'quiz_ai_enabled': (source) {
        // No Placeholders
        return l10n.quiz_ai_enabled;
      },
      'quiz_ai_explanation': (source) {
        // No Placeholders
        return l10n.quiz_ai_explanation;
      },
      'quiz_ai_fixed_ratio': (source) {
        // No Placeholders
        return l10n.quiz_ai_fixed_ratio;
      },
      'quiz_ai_ratio_fixed': (source) {
        // No Placeholders
        return l10n.quiz_ai_ratio_fixed;
      },
      'quiz_ai_ratio_label': (source) {
        // Has Placeholders
        var index = 0;
        String percent = source.arguments[index];
        index++;
        return l10n.quiz_ai_ratio_label(percent);
      },
      'quiz_ai_ratio_mode': (source) {
        // No Placeholders
        return l10n.quiz_ai_ratio_mode;
      },
      'quiz_ai_ratio_smart': (source) {
        // No Placeholders
        return l10n.quiz_ai_ratio_smart;
      },
      'quiz_all_knowledge_base': (source) {
        // No Placeholders
        return l10n.quiz_all_knowledge_base;
      },
      'quiz_answer': (source) {
        // No Placeholders
        return l10n.quiz_answer;
      },
      'quiz_answered_n_of_m': (source) {
        // Has Placeholders
        var index = 0;
        String current = source.arguments[index];
        index++;
        String total = source.arguments[index];
        index++;
        return l10n.quiz_answered_n_of_m(current, total);
      },
      'quiz_completed': (source) {
        // No Placeholders
        return l10n.quiz_completed;
      },
      'quiz_confirm_submit': (source) {
        // No Placeholders
        return l10n.quiz_confirm_submit;
      },
      'quiz_congratulations_passed': (source) {
        // No Placeholders
        return l10n.quiz_congratulations_passed;
      },
      'quiz_consolidate_weak_knowledge_points': (source) {
        // No Placeholders
        return l10n.quiz_consolidate_weak_knowledge_points;
      },
      'quiz_continue_answering': (source) {
        // No Placeholders
        return l10n.quiz_continue_answering;
      },
      'quiz_correct': (source) {
        // No Placeholders
        return l10n.quiz_correct;
      },
      'quiz_correct_answer': (source) {
        // No Placeholders
        return l10n.quiz_correct_answer;
      },
      'quiz_create_exam_failed': (source) {
        // No Placeholders
        return l10n.quiz_create_exam_failed;
      },
      'quiz_daily_count': (source) {
        // No Placeholders
        return l10n.quiz_daily_count;
      },
      'quiz_daily_quiz': (source) {
        // No Placeholders
        return l10n.quiz_daily_quiz;
      },
      'quiz_daily_quiz_not_enabled': (source) {
        // No Placeholders
        return l10n.quiz_daily_quiz_not_enabled;
      },
      'quiz_daily_quiz_settings': (source) {
        // No Placeholders
        return l10n.quiz_daily_quiz_settings;
      },
      'quiz_daily_quiz_started': (source) {
        // No Placeholders
        return l10n.quiz_daily_quiz_started;
      },
      'quiz_daily_scope': (source) {
        // No Placeholders
        return l10n.quiz_daily_scope;
      },
      'quiz_easy': (source) {
        // No Placeholders
        return l10n.quiz_easy;
      },
      'quiz_enable_daily_quiz': (source) {
        // No Placeholders
        return l10n.quiz_enable_daily_quiz;
      },
      'quiz_exam': (source) {
        // No Placeholders
        return l10n.quiz_exam;
      },
      'quiz_exam_generated': (source) {
        // No Placeholders
        return l10n.quiz_exam_generated;
      },
      'quiz_exam_history': (source) {
        // No Placeholders
        return l10n.quiz_exam_history;
      },
      'quiz_exam_not_found': (source) {
        // No Placeholders
        return l10n.quiz_exam_not_found;
      },
      'quiz_exam_result': (source) {
        // No Placeholders
        return l10n.quiz_exam_result;
      },
      'quiz_explanation': (source) {
        // No Placeholders
        return l10n.quiz_explanation;
      },
      'quiz_feedback': (source) {
        // No Placeholders
        return l10n.quiz_feedback;
      },
      'quiz_fill_in_the_blank': (source) {
        // No Placeholders
        return l10n.quiz_fill_in_the_blank;
      },
      'quiz_generate_quiz_questions_daily': (source) {
        // No Placeholders
        return l10n.quiz_generate_quiz_questions_daily;
      },
      'quiz_hard': (source) {
        // No Placeholders
        return l10n.quiz_hard;
      },
      'quiz_input_answer': (source) {
        // No Placeholders
        return l10n.quiz_input_answer;
      },
      'quiz_input_your_answer': (source) {
        // No Placeholders
        return l10n.quiz_input_your_answer;
      },
      'quiz_keep_going': (source) {
        // No Placeholders
        return l10n.quiz_keep_going;
      },
      'quiz_load_failed': (source) {
        // No Placeholders
        return l10n.quiz_load_failed;
      },
      'quiz_loading': (source) {
        // No Placeholders
        return l10n.quiz_loading;
      },
      'quiz_makeup_deadline': (source) {
        // No Placeholders
        return l10n.quiz_makeup_deadline;
      },
      'quiz_makeup_exam': (source) {
        // No Placeholders
        return l10n.quiz_makeup_exam;
      },
      'quiz_mark_as_mastered': (source) {
        // No Placeholders
        return l10n.quiz_mark_as_mastered;
      },
      'quiz_mastered': (source) {
        // No Placeholders
        return l10n.quiz_mastered;
      },
      'quiz_mastered_will_no_longer_appear': (source) {
        // No Placeholders
        return l10n.quiz_mastered_will_no_longer_appear;
      },
      'quiz_medium': (source) {
        // No Placeholders
        return l10n.quiz_medium;
      },
      'quiz_missed_exam': (source) {
        // No Placeholders
        return l10n.quiz_missed_exam;
      },
      'quiz_monthly_comprehensive_quiz': (source) {
        // No Placeholders
        return l10n.quiz_monthly_comprehensive_quiz;
      },
      'quiz_monthly_count': (source) {
        // No Placeholders
        return l10n.quiz_monthly_count;
      },
      'quiz_monthly_exam': (source) {
        // No Placeholders
        return l10n.quiz_monthly_exam;
      },
      'quiz_monthly_exam_2': (source) {
        // No Placeholders
        return l10n.quiz_monthly_exam_2;
      },
      'quiz_multiple_choice': (source) {
        // No Placeholders
        return l10n.quiz_multiple_choice;
      },
      'quiz_next_question': (source) {
        // No Placeholders
        return l10n.quiz_next_question;
      },
      'quiz_no_associated_document': (source) {
        // No Placeholders
        return l10n.quiz_no_associated_document;
      },
      'quiz_no_exam_records': (source) {
        // No Placeholders
        return l10n.quiz_no_exam_records;
      },
      'quiz_no_wrong_questions_keep_it_up': (source) {
        // No Placeholders
        return l10n.quiz_no_wrong_questions_keep_it_up;
      },
      'quiz_not_answered': (source) {
        // No Placeholders
        return l10n.quiz_not_answered;
      },
      'quiz_note_input_hint': (source) {
        // No Placeholders
        return l10n.quiz_note_input_hint;
      },
      'quiz_options': (source) {
        // No Placeholders
        return l10n.quiz_options;
      },
      'quiz_options_label': (source) {
        // No Placeholders
        return l10n.quiz_options_label;
      },
      'quiz_please_override_in_main_dart': (source) {
        // No Placeholders
        return l10n.quiz_please_override_in_main_dart;
      },
      'quiz_please_switch_to_quiz_tab': (source) {
        // No Placeholders
        return l10n.quiz_please_switch_to_quiz_tab;
      },
      'quiz_practice': (source) {
        // No Placeholders
        return l10n.quiz_practice;
      },
      'quiz_previous_question': (source) {
        // No Placeholders
        return l10n.quiz_previous_question;
      },
      'quiz_quarterly_comprehensive_quiz': (source) {
        // No Placeholders
        return l10n.quiz_quarterly_comprehensive_quiz;
      },
      'quiz_quarterly_count': (source) {
        // No Placeholders
        return l10n.quiz_quarterly_count;
      },
      'quiz_quarterly_exam': (source) {
        // No Placeholders
        return l10n.quiz_quarterly_exam;
      },
      'quiz_quarterly_exam_2': (source) {
        // No Placeholders
        return l10n.quiz_quarterly_exam_2;
      },
      'quiz_question': (source) {
        // No Placeholders
        return l10n.quiz_question;
      },
      'quiz_question_count': (source) {
        // No Placeholders
        return l10n.quiz_question_count;
      },
      'quiz_question_n_of_m': (source) {
        // Has Placeholders
        var index = 0;
        String current = source.arguments[index];
        index++;
        String total = source.arguments[index];
        index++;
        return l10n.quiz_question_n_of_m(current, total);
      },
      'quiz_question_scope': (source) {
        // No Placeholders
        return l10n.quiz_question_scope;
      },
      'quiz_questions': (source) {
        // No Placeholders
        return l10n.quiz_questions;
      },
      'quiz_quick_quiz_started': (source) {
        // No Placeholders
        return l10n.quiz_quick_quiz_started;
      },
      'quiz_quiz': (source) {
        // No Placeholders
        return l10n.quiz_quiz;
      },
      'quiz_quiz_config': (source) {
        // No Placeholders
        return l10n.quiz_quiz_config;
      },
      'quiz_quiz_types': (source) {
        // No Placeholders
        return l10n.quiz_quiz_types;
      },
      'quiz_random_count': (source) {
        // No Placeholders
        return l10n.quiz_random_count;
      },
      'quiz_random_days': (source) {
        // No Placeholders
        return l10n.quiz_random_days;
      },
      'quiz_random_quick_review': (source) {
        // No Placeholders
        return l10n.quiz_random_quick_review;
      },
      'quiz_random_quiz': (source) {
        // No Placeholders
        return l10n.quiz_random_quiz;
      },
      'quiz_ready_with_n_questions': (source) {
        // Has Placeholders
        var index = 0;
        String count = source.arguments[index];
        index++;
        return l10n.quiz_ready_with_n_questions(count);
      },
      'quiz_recent_reading_documents': (source) {
        // No Placeholders
        return l10n.quiz_recent_reading_documents;
      },
      'quiz_reminder_hour': (source) {
        // No Placeholders
        return l10n.quiz_reminder_hour;
      },
      'quiz_reminder_time': (source) {
        // No Placeholders
        return l10n.quiz_reminder_time;
      },
      'quiz_return': (source) {
        // No Placeholders
        return l10n.quiz_return;
      },
      'quiz_review_count': (source) {
        // No Placeholders
        return l10n.quiz_review_count;
      },
      'quiz_review_wrong_ratio': (source) {
        // No Placeholders
        return l10n.quiz_review_wrong_ratio;
      },
      'quiz_save': (source) {
        // No Placeholders
        return l10n.quiz_save;
      },
      'quiz_save_settings': (source) {
        // No Placeholders
        return l10n.quiz_save_settings;
      },
      'quiz_scope_all': (source) {
        // No Placeholders
        return l10n.quiz_scope_all;
      },
      'quiz_scope_category': (source) {
        // No Placeholders
        return l10n.quiz_scope_category;
      },
      'quiz_scope_days': (source) {
        // No Placeholders
        return l10n.quiz_scope_days;
      },
      'quiz_score': (source) {
        // No Placeholders
        return l10n.quiz_score;
      },
      'quiz_settings_saved': (source) {
        // No Placeholders
        return l10n.quiz_settings_saved;
      },
      'quiz_short_answer': (source) {
        // No Placeholders
        return l10n.quiz_short_answer;
      },
      'quiz_single_choice': (source) {
        // No Placeholders
        return l10n.quiz_single_choice;
      },
      'quiz_skip': (source) {
        // No Placeholders
        return l10n.quiz_skip;
      },
      'quiz_sort_by_difficulty': (source) {
        // No Placeholders
        return l10n.quiz_sort_by_difficulty;
      },
      'quiz_sort_by_wrong_count': (source) {
        // No Placeholders
        return l10n.quiz_sort_by_wrong_count;
      },
      'quiz_specific_category': (source) {
        // No Placeholders
        return l10n.quiz_specific_category;
      },
      'quiz_streak_days': (source) {
        // No Placeholders
        return l10n.quiz_streak_days;
      },
      'quiz_submit_exam': (source) {
        // No Placeholders
        return l10n.quiz_submit_exam;
      },
      'quiz_tap_to_start': (source) {
        // No Placeholders
        return l10n.quiz_tap_to_start;
      },
      'quiz_ten_questions_per_day': (source) {
        // No Placeholders
        return l10n.quiz_ten_questions_per_day;
      },
      'quiz_today_n_questions_tap_to_start': (source) {
        // Has Placeholders
        var index = 0;
        String count = source.arguments[index];
        index++;
        return l10n.quiz_today_n_questions_tap_to_start(count);
      },
      'quiz_true_false': (source) {
        // No Placeholders
        return l10n.quiz_true_false;
      },
      'quiz_unknown': (source) {
        // No Placeholders
        return l10n.quiz_unknown;
      },
      'quiz_variant_enabled': (source) {
        // No Placeholders
        return l10n.quiz_variant_enabled;
      },
      'quiz_view_source_document': (source) {
        // No Placeholders
        return l10n.quiz_view_source_document;
      },
      'quiz_wrong': (source) {
        // No Placeholders
        return l10n.quiz_wrong;
      },
      'quiz_wrong_question_detail': (source) {
        // No Placeholders
        return l10n.quiz_wrong_question_detail;
      },
      'quiz_wrong_question_review': (source) {
        // No Placeholders
        return l10n.quiz_wrong_question_review;
      },
      'quiz_wrong_questions': (source) {
        // No Placeholders
        return l10n.quiz_wrong_questions;
      },
      'quiz_yearly_comprehensive_quiz': (source) {
        // No Placeholders
        return l10n.quiz_yearly_comprehensive_quiz;
      },
      'quiz_yearly_count': (source) {
        // No Placeholders
        return l10n.quiz_yearly_count;
      },
      'quiz_yearly_exam': (source) {
        // No Placeholders
        return l10n.quiz_yearly_exam;
      },
      'quiz_yearly_exam_2': (source) {
        // No Placeholders
        return l10n.quiz_yearly_exam_2;
      },
      'quiz_your_answer': (source) {
        // No Placeholders
        return l10n.quiz_your_answer;
      },
      'wiki_add_bookmark': (source) {
        // No Placeholders
        return l10n.wiki_add_bookmark;
      },
      'wiki_add_category': (source) {
        // No Placeholders
        return l10n.wiki_add_category;
      },
      'wiki_add_category_in_dev': (source) {
        // No Placeholders
        return l10n.wiki_add_category_in_dev;
      },
      'wiki_add_citation': (source) {
        // No Placeholders
        return l10n.wiki_add_citation;
      },
      'wiki_add_highlight': (source) {
        // No Placeholders
        return l10n.wiki_add_highlight;
      },
      'wiki_add_note': (source) {
        // No Placeholders
        return l10n.wiki_add_note;
      },
      'wiki_add_tag': (source) {
        // No Placeholders
        return l10n.wiki_add_tag;
      },
      'wiki_ai_explanation': (source) {
        // No Placeholders
        return l10n.wiki_ai_explanation;
      },
      'wiki_ai_explanation_failed': (source) {
        // No Placeholders
        return l10n.wiki_ai_explanation_failed;
      },
      'wiki_all_documents': (source) {
        // No Placeholders
        return l10n.wiki_all_documents;
      },
      'wiki_all_knowledge': (source) {
        // No Placeholders
        return l10n.wiki_all_knowledge;
      },
      'wiki_answer_correct_n': (source) {
        // No Placeholders
        return l10n.wiki_answer_correct_n;
      },
      'wiki_ask_ai': (source) {
        // No Placeholders
        return l10n.wiki_ask_ai;
      },
      'wiki_auto_generate_tags': (source) {
        // No Placeholders
        return l10n.wiki_auto_generate_tags;
      },
      'wiki_auto_saved': (source) {
        // No Placeholders
        return l10n.wiki_auto_saved;
      },
      'wiki_background': (source) {
        // No Placeholders
        return l10n.wiki_background;
      },
      'wiki_bookmark': (source) {
        // No Placeholders
        return l10n.wiki_bookmark;
      },
      'wiki_browser_search': (source) {
        // No Placeholders
        return l10n.wiki_browser_search;
      },
      'wiki_cancel': (source) {
        // No Placeholders
        return l10n.wiki_cancel;
      },
      'wiki_category': (source) {
        // No Placeholders
        return l10n.wiki_category;
      },
      'wiki_category_name': (source) {
        // No Placeholders
        return l10n.wiki_category_name;
      },
      'wiki_category_panel': (source) {
        // No Placeholders
        return l10n.wiki_category_panel;
      },
      'wiki_category_tree': (source) {
        // No Placeholders
        return l10n.wiki_category_tree;
      },
      'wiki_citation': (source) {
        // No Placeholders
        return l10n.wiki_citation;
      },
      'wiki_citation_popup': (source) {
        // No Placeholders
        return l10n.wiki_citation_popup;
      },
      'wiki_close': (source) {
        // No Placeholders
        return l10n.wiki_close;
      },
      'wiki_confirm': (source) {
        // No Placeholders
        return l10n.wiki_confirm;
      },
      'wiki_copied_to_clipboard': (source) {
        // No Placeholders
        return l10n.wiki_copied_to_clipboard;
      },
      'wiki_copy': (source) {
        // No Placeholders
        return l10n.wiki_copy;
      },
      'wiki_create_node': (source) {
        // No Placeholders
        return l10n.wiki_create_node;
      },
      'wiki_dark': (source) {
        // No Placeholders
        return l10n.wiki_dark;
      },
      'wiki_delete': (source) {
        // No Placeholders
        return l10n.wiki_delete;
      },
      'wiki_delete_category': (source) {
        // No Placeholders
        return l10n.wiki_delete_category;
      },
      'wiki_delete_category_confirm': (source) {
        // Has Placeholders
        var index = 0;
        String name = source.arguments[index];
        index++;
        return l10n.wiki_delete_category_confirm(name);
      },
      'wiki_delete_document': (source) {
        // No Placeholders
        return l10n.wiki_delete_document;
      },
      'wiki_document': (source) {
        // No Placeholders
        return l10n.wiki_document;
      },
      'wiki_document_name': (source) {
        // No Placeholders
        return l10n.wiki_document_name;
      },
      'wiki_document_title': (source) {
        // No Placeholders
        return l10n.wiki_document_title;
      },
      'wiki_edit_category': (source) {
        // No Placeholders
        return l10n.wiki_edit_category;
      },
      'wiki_edit_category_in_dev': (source) {
        // No Placeholders
        return l10n.wiki_edit_category_in_dev;
      },
      'wiki_edit_document': (source) {
        // No Placeholders
        return l10n.wiki_edit_document;
      },
      'wiki_edit_tags': (source) {
        // No Placeholders
        return l10n.wiki_edit_tags;
      },
      'wiki_editor': (source) {
        // No Placeholders
        return l10n.wiki_editor;
      },
      'wiki_error': (source) {
        // No Placeholders
        return l10n.wiki_error;
      },
      'wiki_explain_text': (source) {
        // No Placeholders
        return l10n.wiki_explain_text;
      },
      'wiki_export': (source) {
        // No Placeholders
        return l10n.wiki_export;
      },
      'wiki_export_document': (source) {
        // No Placeholders
        return l10n.wiki_export_document;
      },
      'wiki_eye_care': (source) {
        // No Placeholders
        return l10n.wiki_eye_care;
      },
      'wiki_feature_development': (source) {
        // No Placeholders
        return l10n.wiki_feature_development;
      },
      'wiki_feature_in_development': (source) {
        // No Placeholders
        return l10n.wiki_feature_in_development;
      },
      'wiki_font_size': (source) {
        // No Placeholders
        return l10n.wiki_font_size;
      },
      'wiki_fulltext_search': (source) {
        // No Placeholders
        return l10n.wiki_fulltext_search;
      },
      'wiki_generate_based': (source) {
        // No Placeholders
        return l10n.wiki_generate_based;
      },
      'wiki_generate_question': (source) {
        // No Placeholders
        return l10n.wiki_generate_question;
      },
      'wiki_generated_questions': (source) {
        // No Placeholders
        return l10n.wiki_generated_questions;
      },
      'wiki_generating_ai_explanation': (source) {
        // No Placeholders
        return l10n.wiki_generating_ai_explanation;
      },
      'wiki_generating_questions': (source) {
        // No Placeholders
        return l10n.wiki_generating_questions;
      },
      'wiki_graph_canvas': (source) {
        // No Placeholders
        return l10n.wiki_graph_canvas;
      },
      'wiki_graph_canvas_pending': (source) {
        // No Placeholders
        return l10n.wiki_graph_canvas_pending;
      },
      'wiki_graph_controller': (source) {
        // No Placeholders
        return l10n.wiki_graph_controller;
      },
      'wiki_graph_edge': (source) {
        // No Placeholders
        return l10n.wiki_graph_edge;
      },
      'wiki_graph_node': (source) {
        // No Placeholders
        return l10n.wiki_graph_node;
      },
      'wiki_highlight': (source) {
        // No Placeholders
        return l10n.wiki_highlight;
      },
      'wiki_ideas': (source) {
        // No Placeholders
        return l10n.wiki_ideas;
      },
      'wiki_import': (source) {
        // No Placeholders
        return l10n.wiki_import;
      },
      'wiki_import_document': (source) {
        // No Placeholders
        return l10n.wiki_import_document;
      },
      'wiki_input_answer': (source) {
        // No Placeholders
        return l10n.wiki_input_answer;
      },
      'wiki_input_word_hint': (source) {
        // No Placeholders
        return l10n.wiki_input_word_hint;
      },
      'wiki_input_your_answer': (source) {
        // No Placeholders
        return l10n.wiki_input_your_answer;
      },
      'wiki_knowledge_graph': (source) {
        // No Placeholders
        return l10n.wiki_knowledge_graph;
      },
      'wiki_knowledge_map': (source) {
        // No Placeholders
        return l10n.wiki_knowledge_map;
      },
      'wiki_knowledge_search': (source) {
        // No Placeholders
        return l10n.wiki_knowledge_search;
      },
      'wiki_light': (source) {
        // No Placeholders
        return l10n.wiki_light;
      },
      'wiki_line_spacing': (source) {
        // No Placeholders
        return l10n.wiki_line_spacing;
      },
      'wiki_loading': (source) {
        // No Placeholders
        return l10n.wiki_loading;
      },
      'wiki_manage_categories': (source) {
        // No Placeholders
        return l10n.wiki_manage_categories;
      },
      'wiki_margin': (source) {
        // No Placeholders
        return l10n.wiki_margin;
      },
      'wiki_markdown_source': (source) {
        // No Placeholders
        return l10n.wiki_markdown_source;
      },
      'wiki_min': (source) {
        // No Placeholders
        return l10n.wiki_min;
      },
      'wiki_move_to': (source) {
        // No Placeholders
        return l10n.wiki_move_to;
      },
      'wiki_new_document': (source) {
        // No Placeholders
        return l10n.wiki_new_document;
      },
      'wiki_next_match': (source) {
        // No Placeholders
        return l10n.wiki_next_match;
      },
      'wiki_night_mode': (source) {
        // No Placeholders
        return l10n.wiki_night_mode;
      },
      'wiki_no_bookmarks': (source) {
        // No Placeholders
        return l10n.wiki_no_bookmarks;
      },
      'wiki_no_categories': (source) {
        // No Placeholders
        return l10n.wiki_no_categories;
      },
      'wiki_no_documents': (source) {
        // No Placeholders
        return l10n.wiki_no_documents;
      },
      'wiki_no_docx_text': (source) {
        // No Placeholders
        return l10n.wiki_no_docx_text;
      },
      'wiki_no_headings': (source) {
        // No Placeholders
        return l10n.wiki_no_headings;
      },
      'wiki_no_highlights': (source) {
        // No Placeholders
        return l10n.wiki_no_highlights;
      },
      'wiki_no_tags': (source) {
        // No Placeholders
        return l10n.wiki_no_tags;
      },
      'wiki_no_text_content': (source) {
        // No Placeholders
        return l10n.wiki_no_text_content;
      },
      'wiki_no_titles': (source) {
        // No Placeholders
        return l10n.wiki_no_titles;
      },
      'wiki_node_name': (source) {
        // No Placeholders
        return l10n.wiki_node_name;
      },
      'wiki_note': (source) {
        // No Placeholders
        return l10n.wiki_note;
      },
      'wiki_note_document': (source) {
        // No Placeholders
        return l10n.wiki_note_document;
      },
      'wiki_note_input_hint': (source) {
        // No Placeholders
        return l10n.wiki_note_input_hint;
      },
      'wiki_note_saved': (source) {
        // No Placeholders
        return l10n.wiki_note_saved;
      },
      'wiki_notes': (source) {
        // No Placeholders
        return l10n.wiki_notes;
      },
      'wiki_outline': (source) {
        // No Placeholders
        return l10n.wiki_outline;
      },
      'wiki_page': (source) {
        // No Placeholders
        return l10n.wiki_page;
      },
      'wiki_pdf_export': (source) {
        // No Placeholders
        return l10n.wiki_pdf_export;
      },
      'wiki_please_explain': (source) {
        // No Placeholders
        return l10n.wiki_please_explain;
      },
      'wiki_prev_match': (source) {
        // No Placeholders
        return l10n.wiki_prev_match;
      },
      'wiki_question_generation_failed': (source) {
        // No Placeholders
        return l10n.wiki_question_generation_failed;
      },
      'wiki_read_aloud': (source) {
        // No Placeholders
        return l10n.wiki_read_aloud;
      },
      'wiki_reader': (source) {
        // No Placeholders
        return l10n.wiki_reader;
      },
      'wiki_reader_ask_ai': (source) {
        // No Placeholders
        return l10n.wiki_reader_ask_ai;
      },
      'wiki_reader_bookmark': (source) {
        // No Placeholders
        return l10n.wiki_reader_bookmark;
      },
      'wiki_reader_browser_search': (source) {
        // No Placeholders
        return l10n.wiki_reader_browser_search;
      },
      'wiki_reader_copy': (source) {
        // No Placeholders
        return l10n.wiki_reader_copy;
      },
      'wiki_reader_dictionary': (source) {
        // No Placeholders
        return l10n.wiki_reader_dictionary;
      },
      'wiki_reader_full_text_search': (source) {
        // No Placeholders
        return l10n.wiki_reader_full_text_search;
      },
      'wiki_reader_highlight_note': (source) {
        // No Placeholders
        return l10n.wiki_reader_highlight_note;
      },
      'wiki_reader_kb_search': (source) {
        // No Placeholders
        return l10n.wiki_reader_kb_search;
      },
      'wiki_reader_read_aloud': (source) {
        // No Placeholders
        return l10n.wiki_reader_read_aloud;
      },
      'wiki_reader_toolbar': (source) {
        // No Placeholders
        return l10n.wiki_reader_toolbar;
      },
      'wiki_reading_settings': (source) {
        // No Placeholders
        return l10n.wiki_reading_settings;
      },
      'wiki_rename': (source) {
        // No Placeholders
        return l10n.wiki_rename;
      },
      'wiki_rename_category': (source) {
        // No Placeholders
        return l10n.wiki_rename_category;
      },
      'wiki_reset_tags': (source) {
        // No Placeholders
        return l10n.wiki_reset_tags;
      },
      'wiki_reset_tags_confirm': (source) {
        // No Placeholders
        return l10n.wiki_reset_tags_confirm;
      },
      'wiki_root_directory': (source) {
        // No Placeholders
        return l10n.wiki_root_directory;
      },
      'wiki_save': (source) {
        // No Placeholders
        return l10n.wiki_save;
      },
      'wiki_score_suffix': (source) {
        // No Placeholders
        return l10n.wiki_score_suffix;
      },
      'wiki_search': (source) {
        // No Placeholders
        return l10n.wiki_search;
      },
      'wiki_search_document': (source) {
        // No Placeholders
        return l10n.wiki_search_document;
      },
      'wiki_search_word': (source) {
        // No Placeholders
        return l10n.wiki_search_word;
      },
      'wiki_skip': (source) {
        // No Placeholders
        return l10n.wiki_skip;
      },
      'wiki_study_materials': (source) {
        // No Placeholders
        return l10n.wiki_study_materials;
      },
      'wiki_style': (source) {
        // No Placeholders
        return l10n.wiki_style;
      },
      'wiki_summarize': (source) {
        // No Placeholders
        return l10n.wiki_summarize;
      },
      'wiki_summarizer': (source) {
        // No Placeholders
        return l10n.wiki_summarizer;
      },
      'wiki_summary': (source) {
        // No Placeholders
        return l10n.wiki_summary;
      },
      'wiki_switch_to_rich': (source) {
        // No Placeholders
        return l10n.wiki_switch_to_rich;
      },
      'wiki_switch_to_source': (source) {
        // No Placeholders
        return l10n.wiki_switch_to_source;
      },
      'wiki_system_prompt_explain': (source) {
        // No Placeholders
        return l10n.wiki_system_prompt_explain;
      },
      'wiki_tag_generated': (source) {
        // No Placeholders
        return l10n.wiki_tag_generated;
      },
      'wiki_tag_generation_failed': (source) {
        // No Placeholders
        return l10n.wiki_tag_generation_failed;
      },
      'wiki_tags': (source) {
        // No Placeholders
        return l10n.wiki_tags;
      },
      'wiki_tap_to_select': (source) {
        // No Placeholders
        return l10n.wiki_tap_to_select;
      },
      'wiki_text_to_speech': (source) {
        // No Placeholders
        return l10n.wiki_text_to_speech;
      },
      'wiki_theme': (source) {
        // No Placeholders
        return l10n.wiki_theme;
      },
      'wiki_toc': (source) {
        // No Placeholders
        return l10n.wiki_toc;
      },
      'wiki_today_reading': (source) {
        // No Placeholders
        return l10n.wiki_today_reading;
      },
      'wiki_total_reading': (source) {
        // No Placeholders
        return l10n.wiki_total_reading;
      },
      'wiki_tts': (source) {
        // No Placeholders
        return l10n.wiki_tts;
      },
      'wiki_underline': (source) {
        // No Placeholders
        return l10n.wiki_underline;
      },
      'wiki_view_source': (source) {
        // No Placeholders
        return l10n.wiki_view_source;
      },
      'wiki_wiki': (source) {
        // No Placeholders
        return l10n.wiki_wiki;
      },
      'wiki_work': (source) {
        // No Placeholders
        return l10n.wiki_work;
      },
      'wiki_zoom_in': (source) {
        // No Placeholders
        return l10n.wiki_zoom_in;
      },
      'wiki_zoom_out': (source) {
        // No Placeholders
        return l10n.wiki_zoom_out;
      },
    };

    LocalizeStringDelegate.delegate = (source) {
      final id = source.id;
      final func = table[id]!;
      return func(source);
    };
  }
}

class _L10nHelperDelegate implements LocalizationsDelegate<L10n> {
  final delegate = L10n.delegate;

  const _L10nHelperDelegate();

  @override
  Type get type => delegate.type;

  @override
  bool isSupported(Locale locale) => delegate.isSupported(locale);

  @override
  Future<L10n> load(Locale locale) async {
    final result = await delegate.load(locale);
    L10nHelper.configure(result);
    return result;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<L10n> old) => false;
}
