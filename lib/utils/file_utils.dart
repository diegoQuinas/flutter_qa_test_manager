import 'dart:io';
import 'package:flutter/material.dart';

class FileUtils {
  /// Abre un archivo con la aplicación predeterminada del sistema
  static Future<bool> openFile(File file) async {
    try {
      if (!await file.exists()) {
        return false;
      }

      final String path = file.path;
      
      if (Platform.isWindows) {
        return Process.run('start', [path], runInShell: true)
            .then((result) => result.exitCode == 0);
      } else if (Platform.isMacOS) {
        return Process.run('open', [path])
            .then((result) => result.exitCode == 0);
      } else if (Platform.isLinux) {
        return Process.run('xdg-open', [path])
            .then((result) => result.exitCode == 0);
      }
      return false;
    } catch (e) {
      print('Error al abrir archivo: $e');
      return false;
    }
  }

  /// Abre el directorio que contiene un archivo
  static Future<bool> openDirectory(File file) async {
    try {
      final String dirPath = file.parent.path;
      
      if (Platform.isWindows) {
        return Process.run('explorer', [dirPath], runInShell: true)
            .then((result) => result.exitCode == 0);
      } else if (Platform.isMacOS) {
        return Process.run('open', [dirPath])
            .then((result) => result.exitCode == 0);
      } else if (Platform.isLinux) {
        return Process.run('xdg-open', [dirPath])
            .then((result) => result.exitCode == 0);
      }
      return false;
    } catch (e) {
      print('Error al abrir directorio: $e');
      return false;
    }
  }

  /// Muestra un diálogo con la información del archivo y opciones para abrirlo
  static Future<void> showFileInfoDialog(BuildContext context, File file, {String title = 'Archivo guardado'}) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final directory = file.parent.path;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El archivo ha sido guardado en:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: $fileName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Ruta: $directory', 
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              openFile(file);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('ABRIR ARCHIVO'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              openDirectory(file);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('ABRIR CARPETA'),
          ),
        ],
      ),
    );
  }
}