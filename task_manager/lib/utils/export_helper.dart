import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task_model.dart';

class ExportHelper {
  // Export tasks to CSV, return file path
  static Future<String> exportToCSV(List<Task> tasks) async {
    final rows = <List<dynamic>>[];
    rows.add(['id', 'title', 'description', 'dueDate', 'isCompleted', 'repeat']);
    for (var t in tasks) {
      rows.add([t.id ?? '', t.title, t.description ?? '', t.dueDate?.toIso8601String() ?? '', t.isCompleted ? 1 : 0, t.repeat]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tasks_export.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  // Export to PDF bytes
  static Future<Uint8List> exportToPDFBytes(List<Task> tasks) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(build: (context) {
      return [
        pw.Header(level: 0, child: pw.Text('Tasks Export')),
        ...tasks.map((t) {
          return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Title: ${t.title}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            if (t.description != null) pw.Text('Desc: ${t.description}'),
            pw.Text('Due: ${t.dueDate?.toString() ?? '-'}'),
            pw.Text('Completed: ${t.isCompleted ? 'Yes' : 'No'}'),
            pw.SizedBox(height: 8),
          ]);
        })
      ];
    }));
    return pdf.save();
  }

  // Share PDF (invokes platform share sheet)
  static Future<void> sharePDF(List<Task> tasks) async {
    final bytes = await exportToPDFBytes(tasks);
    await Printing.sharePdf(bytes: bytes, filename: 'tasks_export.pdf');
  }

  // Export CSV and share via email/share sheet
  static Future<void> exportCSVToEmail(List<Task> tasks) async {
    final csvPath = await exportToCSV(tasks);
    final file = XFile(csvPath);
    await Share.shareXFiles(
      [file],
      subject: 'Task Manager Export - CSV',
      text: 'Please find attached the exported tasks from Task Manager.',
    );
  }

  // Export PDF and share via email/share sheet
  static Future<void> exportPDFToEmail(List<Task> tasks) async {
    final bytes = await exportToPDFBytes(tasks);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tasks_export.pdf');
    await file.writeAsBytes(bytes);
    final xFile = XFile(file.path);
    await Share.shareXFiles(
      [xFile],
      subject: 'Task Manager Export - PDF',
      text: 'Please find attached the exported tasks from Task Manager.',
    );
  }
}
