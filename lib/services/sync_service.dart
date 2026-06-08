import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'supabase_service.dart';

class SyncService {
  static final Connectivity _connectivity = Connectivity();
  static ValueNotifier<bool> isOnline = ValueNotifier(true);
  static ValueNotifier<bool> isSyncing = ValueNotifier(false);
  
  static void startMonitoring() {
    _connectivity.onConnectivityChanged.listen((result) {
      isOnline.value = (result != ConnectivityResult.none);
      
      if (isOnline.value) {
        syncData();
      }
    });
  }
  
  static Future<void> syncData() async {
    if (!isOnline.value) return;
    
    isSyncing.value = true;
    
    try {
      // Sync with Supabase if available
      if (SupabaseService.isAvailable) {
        await SupabaseService.syncLocalToCloud();
        await SupabaseService.pullFromCloud();
      }
      
      print('✅ Sync completed at ${DateTime.now()}');
    } catch (e) {
      print('❌ Sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }
  
  static Widget connectivityStatusBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: isOnline,
      builder: (context, online, child) {
        if (online) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          color: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Offline Mode - Changes will sync when online',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              if (isSyncing.value) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}