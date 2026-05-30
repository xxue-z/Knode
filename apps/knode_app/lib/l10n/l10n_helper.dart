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
      'chat_confirm': (source) {
        // No Placeholders
        return l10n.chat_confirm;
      },
      'chat_copied': (source) {
        // No Placeholders
        return l10n.chat_copied;
      },
      'chat_copy': (source) {
        // No Placeholders
        return l10n.chat_copy;
      },
      'chat_delete_conversation': (source) {
        // No Placeholders
        return l10n.chat_delete_conversation;
      },
      'chat_error': (source) {
        // No Placeholders
        return l10n.chat_error;
      },
      'chat_export_chat': (source) {
        // No Placeholders
        return l10n.chat_export_chat;
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
      'chat_loading': (source) {
        // No Placeholders
        return l10n.chat_loading;
      },
      'chat_message': (source) {
        // No Placeholders
        return l10n.chat_message;
      },
      'chat_new_conversation': (source) {
        // No Placeholders
        return l10n.chat_new_conversation;
      },
      'chat_no_conversations_yet': (source) {
        // No Placeholders
        return l10n.chat_no_conversations_yet;
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
      'chat_send': (source) {
        // No Placeholders
        return l10n.chat_send;
      },
      'chat_sources': (source) {
        // No Placeholders
        return l10n.chat_sources;
      },
      'chat_token_usage': (source) {
        // No Placeholders
        return l10n.chat_token_usage;
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
      'core_conversation': (source) {
        // No Placeholders
        return l10n.core_conversation;
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
      'core_message': (source) {
        // No Placeholders
        return l10n.core_message;
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
      'core_question': (source) {
        // No Placeholders
        return l10n.core_question;
      },
      'core_quiz': (source) {
        // No Placeholders
        return l10n.core_quiz;
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
      'core_true_false': (source) {
        // No Placeholders
        return l10n.core_true_false;
      },
      'core_webdav_not_configured': (source) {
        // No Placeholders
        return l10n.core_webdav_not_configured;
      },
      'core_yes': (source) {
        // No Placeholders
        return l10n.core_yes;
      },
      'knode_app_about': (source) {
        // No Placeholders
        return l10n.knode_app_about;
      },
      'knode_app_ai_settings': (source) {
        // No Placeholders
        return l10n.knode_app_ai_settings;
      },
      'knode_app_app_shell': (source) {
        // No Placeholders
        return l10n.knode_app_app_shell;
      },
      'knode_app_auto_backup': (source) {
        // No Placeholders
        return l10n.knode_app_auto_backup;
      },
      'knode_app_backup_settings': (source) {
        // No Placeholders
        return l10n.knode_app_backup_settings;
      },
      'knode_app_bottom_navigation': (source) {
        // No Placeholders
        return l10n.knode_app_bottom_navigation;
      },
      'knode_app_cancel': (source) {
        // No Placeholders
        return l10n.knode_app_cancel;
      },
      'knode_app_clear_cache': (source) {
        // No Placeholders
        return l10n.knode_app_clear_cache;
      },
      'knode_app_cloud_config': (source) {
        // No Placeholders
        return l10n.knode_app_cloud_config;
      },
      'knode_app_confirm': (source) {
        // No Placeholders
        return l10n.knode_app_confirm;
      },
      'knode_app_daily_card': (source) {
        // No Placeholders
        return l10n.knode_app_daily_card;
      },
      'knode_app_dark_mode': (source) {
        // No Placeholders
        return l10n.knode_app_dark_mode;
      },
      'knode_app_error': (source) {
        // No Placeholders
        return l10n.knode_app_error;
      },
      'knode_app_export_data': (source) {
        // No Placeholders
        return l10n.knode_app_export_data;
      },
      'knode_app_feedback': (source) {
        // No Placeholders
        return l10n.knode_app_feedback;
      },
      'knode_app_font_size': (source) {
        // No Placeholders
        return l10n.knode_app_font_size;
      },
      'knode_app_home': (source) {
        // No Placeholders
        return l10n.knode_app_home;
      },
      'knode_app_import_data': (source) {
        // No Placeholders
        return l10n.knode_app_import_data;
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
      'knode_app_loading': (source) {
        // No Placeholders
        return l10n.knode_app_loading;
      },
      'knode_app_model_card': (source) {
        // No Placeholders
        return l10n.knode_app_model_card;
      },
      'knode_app_model_download': (source) {
        // No Placeholders
        return l10n.knode_app_model_download;
      },
      'knode_app_notification': (source) {
        // No Placeholders
        return l10n.knode_app_notification;
      },
      'knode_app_personal_drawer': (source) {
        // No Placeholders
        return l10n.knode_app_personal_drawer;
      },
      'knode_app_privacy_policy': (source) {
        // No Placeholders
        return l10n.knode_app_privacy_policy;
      },
      'knode_app_profile': (source) {
        // No Placeholders
        return l10n.knode_app_profile;
      },
      'knode_app_quick_card': (source) {
        // No Placeholders
        return l10n.knode_app_quick_card;
      },
      'knode_app_rate_us': (source) {
        // No Placeholders
        return l10n.knode_app_rate_us;
      },
      'knode_app_save': (source) {
        // No Placeholders
        return l10n.knode_app_save;
      },
      'knode_app_score_card': (source) {
        // No Placeholders
        return l10n.knode_app_score_card;
      },
      'knode_app_server_settings': (source) {
        // No Placeholders
        return l10n.knode_app_server_settings;
      },
      'knode_app_settings': (source) {
        // No Placeholders
        return l10n.knode_app_settings;
      },
      'knode_app_share': (source) {
        // No Placeholders
        return l10n.knode_app_share;
      },
      'knode_app_sound': (source) {
        // No Placeholders
        return l10n.knode_app_sound;
      },
      'knode_app_storage_settings': (source) {
        // No Placeholders
        return l10n.knode_app_storage_settings;
      },
      'knode_app_storage_usage': (source) {
        // No Placeholders
        return l10n.knode_app_storage_usage;
      },
      'knode_app_success': (source) {
        // No Placeholders
        return l10n.knode_app_success;
      },
      'knode_app_system_default': (source) {
        // No Placeholders
        return l10n.knode_app_system_default;
      },
      'knode_app_theme': (source) {
        // No Placeholders
        return l10n.knode_app_theme;
      },
      'knode_app_version': (source) {
        // No Placeholders
        return l10n.knode_app_version;
      },
      'knode_app_vibration': (source) {
        // No Placeholders
        return l10n.knode_app_vibration;
      },
      'knode_app_webdav': (source) {
        // No Placeholders
        return l10n.knode_app_webdav;
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
      'quiz_ai_explanation': (source) {
        // No Placeholders
        return l10n.quiz_ai_explanation;
      },
      'quiz_all_knowledge_base': (source) {
        // No Placeholders
        return l10n.quiz_all_knowledge_base;
      },
      'quiz_answer': (source) {
        // No Placeholders
        return l10n.quiz_answer;
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
      'quiz_monthly_comprehensive_quiz': (source) {
        // No Placeholders
        return l10n.quiz_monthly_comprehensive_quiz;
      },
      'quiz_monthly_exam': (source) {
        // No Placeholders
        return l10n.quiz_monthly_exam;
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
      'quiz_quarterly_exam': (source) {
        // No Placeholders
        return l10n.quiz_quarterly_exam;
      },
      'quiz_question': (source) {
        // No Placeholders
        return l10n.quiz_question;
      },
      'quiz_question_count': (source) {
        // No Placeholders
        return l10n.quiz_question_count;
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
      'quiz_quiz_types': (source) {
        // No Placeholders
        return l10n.quiz_quiz_types;
      },
      'quiz_random_quick_review': (source) {
        // No Placeholders
        return l10n.quiz_random_quick_review;
      },
      'quiz_random_quiz': (source) {
        // No Placeholders
        return l10n.quiz_random_quiz;
      },
      'quiz_recent_reading_documents': (source) {
        // No Placeholders
        return l10n.quiz_recent_reading_documents;
      },
      'quiz_reminder_time': (source) {
        // No Placeholders
        return l10n.quiz_reminder_time;
      },
      'quiz_return': (source) {
        // No Placeholders
        return l10n.quiz_return;
      },
      'quiz_save_settings': (source) {
        // No Placeholders
        return l10n.quiz_save_settings;
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
      'quiz_true_false': (source) {
        // No Placeholders
        return l10n.quiz_true_false;
      },
      'quiz_unknown': (source) {
        // No Placeholders
        return l10n.quiz_unknown;
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
      'quiz_yearly_exam': (source) {
        // No Placeholders
        return l10n.quiz_yearly_exam;
      },
      'quiz_your_answer': (source) {
        // No Placeholders
        return l10n.quiz_your_answer;
      },
      'wiki_add_category': (source) {
        // No Placeholders
        return l10n.wiki_add_category;
      },
      'wiki_add_citation': (source) {
        // No Placeholders
        return l10n.wiki_add_citation;
      },
      'wiki_all_knowledge': (source) {
        // No Placeholders
        return l10n.wiki_all_knowledge;
      },
      'wiki_cancel': (source) {
        // No Placeholders
        return l10n.wiki_cancel;
      },
      'wiki_category': (source) {
        // No Placeholders
        return l10n.wiki_category;
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
      'wiki_confirm': (source) {
        // No Placeholders
        return l10n.wiki_confirm;
      },
      'wiki_create_node': (source) {
        // No Placeholders
        return l10n.wiki_create_node;
      },
      'wiki_delete': (source) {
        // No Placeholders
        return l10n.wiki_delete;
      },
      'wiki_delete_document': (source) {
        // No Placeholders
        return l10n.wiki_delete_document;
      },
      'wiki_document': (source) {
        // No Placeholders
        return l10n.wiki_document;
      },
      'wiki_document_title': (source) {
        // No Placeholders
        return l10n.wiki_document_title;
      },
      'wiki_edit_category': (source) {
        // No Placeholders
        return l10n.wiki_edit_category;
      },
      'wiki_edit_document': (source) {
        // No Placeholders
        return l10n.wiki_edit_document;
      },
      'wiki_editor': (source) {
        // No Placeholders
        return l10n.wiki_editor;
      },
      'wiki_error': (source) {
        // No Placeholders
        return l10n.wiki_error;
      },
      'wiki_export': (source) {
        // No Placeholders
        return l10n.wiki_export;
      },
      'wiki_export_document': (source) {
        // No Placeholders
        return l10n.wiki_export_document;
      },
      'wiki_graph_canvas': (source) {
        // No Placeholders
        return l10n.wiki_graph_canvas;
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
      'wiki_knowledge_graph': (source) {
        // No Placeholders
        return l10n.wiki_knowledge_graph;
      },
      'wiki_knowledge_map': (source) {
        // No Placeholders
        return l10n.wiki_knowledge_map;
      },
      'wiki_loading': (source) {
        // No Placeholders
        return l10n.wiki_loading;
      },
      'wiki_manage_categories': (source) {
        // No Placeholders
        return l10n.wiki_manage_categories;
      },
      'wiki_new_document': (source) {
        // No Placeholders
        return l10n.wiki_new_document;
      },
      'wiki_no_documents': (source) {
        // No Placeholders
        return l10n.wiki_no_documents;
      },
      'wiki_node_name': (source) {
        // No Placeholders
        return l10n.wiki_node_name;
      },
      'wiki_notes': (source) {
        // No Placeholders
        return l10n.wiki_notes;
      },
      'wiki_page': (source) {
        // No Placeholders
        return l10n.wiki_page;
      },
      'wiki_pdf_export': (source) {
        // No Placeholders
        return l10n.wiki_pdf_export;
      },
      'wiki_reader': (source) {
        // No Placeholders
        return l10n.wiki_reader;
      },
      'wiki_reader_toolbar': (source) {
        // No Placeholders
        return l10n.wiki_reader_toolbar;
      },
      'wiki_save': (source) {
        // No Placeholders
        return l10n.wiki_save;
      },
      'wiki_search': (source) {
        // No Placeholders
        return l10n.wiki_search;
      },
      'wiki_study_materials': (source) {
        // No Placeholders
        return l10n.wiki_study_materials;
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
      'wiki_text_to_speech': (source) {
        // No Placeholders
        return l10n.wiki_text_to_speech;
      },
      'wiki_tts': (source) {
        // No Placeholders
        return l10n.wiki_tts;
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
      }
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
