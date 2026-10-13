class Formatters {
  /// Format speed in bits per second or bytes per second to readable text e.g., 446 Kb/s or 36 Mb/s
  static String formatSpeed(num bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 Kb/s';
    
    // Convert to bits per second
    double bitsPerSecond = bytesPerSecond * 8;
    
    if (bitsPerSecond < 1000) {
      return '${bitsPerSecond.toStringAsFixed(0)} b/s';
    } else if (bitsPerSecond < 1000000) {
      return '${(bitsPerSecond / 1000).toStringAsFixed(0)} Kb/s';
    } else if (bitsPerSecond < 1000000000) {
      return '${(bitsPerSecond / 1000000).toStringAsFixed(1)} Mb/s';
    } else {
      return '${(bitsPerSecond / 1000000000).toStringAsFixed(2)} Gb/s';
    }
  }

  /// Format speed directly from Kbps / Mbps
  static String formatMbps(double mbps) {
    if (mbps < 1.0) {
      return '${(mbps * 1000).toStringAsFixed(0)} Kbps';
    } else {
      return '${mbps.toStringAsFixed(1)} Mbps';
    }
  }

  /// Format duration into HH:MM:SS format
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Format total bytes to human readable e.g., 1.2 MB or 450 KB
  static String formatBytes(num bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
