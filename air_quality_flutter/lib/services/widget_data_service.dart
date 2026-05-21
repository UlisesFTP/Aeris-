import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Servicio encargado de exportar y sincronizar los datos de calidad de aire
/// y clima más recientes con los widgets nativos de la pantalla de inicio (Android/iOS).
class WidgetDataService {
  /// App Group ID para iOS (requerido para compartir SharedPreferences entre la App y Widget extension)
  static const String _groupId = 'group.com.example.air_quality_flutter';
  
  /// Nombres de clase nativos de los proveedores del Widget
  static const String _androidWidgetName = 'AerisWidgetProvider';
  static const String _iosWidgetName = 'AerisWidget';

  /// Inicializa la configuración de widgets de pantalla de inicio.
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_groupId);
    } catch (e) {
      debugPrint('[WidgetDataService] Error al establecer App Group ID: $e');
    }
  }

  /// Guarda los datos en el almacenamiento compartido del SO y solicita un refresco visual del Widget.
  static Future<void> updateWidgetData({
    required String locationName,
    required int aqi,
    required double temp,
    required String condition,
  }) async {
    try {
      debugPrint('[WidgetDataService] Guardando datos compartidos para $locationName: '
          'AQI=$aqi, Temp=${temp.round()}°C, Condición=$condition');

      // Guardar de forma atómica en el canal nativo compartido
      await Future.wait([
        HomeWidget.saveWidgetData<String>('widget_location', locationName),
        HomeWidget.saveWidgetData<int>('widget_aqi', aqi),
        HomeWidget.saveWidgetData<double>('widget_temp', temp),
        HomeWidget.saveWidgetData<String>('widget_condition', condition),
      ]);

      // Solicitar de forma imperativa que el sistema operativo actualice el render del widget
      final bool? updated = await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );

      debugPrint('[WidgetDataService] Solicitud de actualización enviada. Éxito=$updated');
    } catch (e) {
      debugPrint('[WidgetDataService] Error al sincronizar con el Widget: $e');
    }
  }
}
