/// 知维 Wiki 模块 - 文档管理、知识图谱
///
/// 此文件作为 barrel export，导出 wiki 包的所有公共 API。
library wiki;

// ── Screens ──
export 'screens/wiki_page.dart';
export 'screens/editor_page.dart';
export 'screens/quill_editor.dart';
export 'screens/reader_page.dart';
export 'screens/reader_toolbar.dart';
export 'screens/citation_popup.dart';
export 'screens/category_tree.dart';
export 'screens/category_panel.dart';

// ── Providers ──
export 'providers/category_provider.dart';
export 'providers/document_provider.dart';
export 'providers/graph_provider.dart';
export 'providers/tag_provider.dart';
export 'providers/reader_provider.dart';

// ── Widgets ──
export 'widgets/graph_canvas.dart' hide GraphNode, GraphEdge;
export 'widgets/graph_edge.dart';
export 'widgets/graph_node.dart';
export 'widgets/node_label.dart';
export 'widgets/tag_chip_list.dart';
export 'widgets/tag_editor_dialog.dart';
export 'widgets/markdown_reader.dart';
export 'widgets/highlight_style_picker.dart';
export 'widgets/add_annotation_dialog.dart';
export 'widgets/outline_panel.dart';
export 'widgets/annotations_panel.dart';
export 'widgets/dictionary_panel.dart';
export 'widgets/reader_settings_panel.dart';
export 'widgets/context_toolbar.dart';
export 'widgets/fulltext_search_bar.dart';
export 'widgets/note_editor_sheet.dart';

// ── Utils ──
export 'utils/heading_extractor.dart';
export 'utils/highlight_applier.dart';
export 'utils/offset_calculator.dart';

// ── Graph Models ──
export 'graph/models/graph_node.dart';
export 'graph/models/graph_edge.dart';
export 'graph/models/graph_cluster.dart';
export 'graph/models/graph_camera.dart';
export 'graph/models/graph_view_state.dart';

// ── Services ──
export 'services/import_service.dart';
export 'services/export_service.dart';
export 'services/graph_service.dart';

// ── Agents ──
export 'agents/summarizer_agent.dart';
export 'agents/tag_generator_agent.dart';
