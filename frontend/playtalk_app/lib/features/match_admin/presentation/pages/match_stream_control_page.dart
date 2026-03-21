import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/match_admin/data/datasources/match_stream_datasource.dart';

class MatchStreamControlPage extends StatefulWidget {
  final String matchId;
  final String tournamentId;
  final String matchName;
  final bool initialIsStreaming;
  final String initialHlsUrl;

  const MatchStreamControlPage({
    super.key,
    required this.matchId,
    required this.tournamentId,
    required this.matchName,
    required this.initialIsStreaming,
    required this.initialHlsUrl,
  });

  @override
  State<MatchStreamControlPage> createState() => _MatchStreamControlPageState();
}

class _MatchStreamControlPageState extends State<MatchStreamControlPage> {
  bool _loading = false;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _isStreaming = widget.initialIsStreaming;
  }

  // 🔥 Update this if IP changes
  static const String _serverIp = "172.70.105.138";
  static const String _baseUrl = "http://172.70.105.138:3000";
  static const String _rtmpUrl = "rtmp://172.70.105.138:1935/live";

  String get _streamKey => widget.matchId;
  String get _hlsUrl => "$_baseUrl/live/${widget.matchId}/index.m3u8";

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied")),
    );
  }

  Future<void> _updateStream(bool start) async {
    final session = context.read<SessionCubit>().state;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session missing. Please login again.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final ds = MatchStreamRemoteDatasource(
        baseUrl: _baseUrl,
        token: session.token,
      );

      await ds.updateStreamStatus(
        tournamentId: widget.tournamentId,
        matchId: widget.matchId,
        isStreaming: start,
        streamKey: _streamKey,
        hlsUrl: _hlsUrl,
      );

      if (!mounted) return;

      setState(() {
        _isStreaming = start;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            start
                ? "Stream marked LIVE. Start OBS/Larix now."
                : "Stream marked STOPPED.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stream update failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _infoTile({
    required String title,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        title: const Text(
          "Stream Control",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF151B2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isStreaming
                      ? Colors.green.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matchName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _isStreaming ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isStreaming ? "STREAMING" : "NOT STREAMING",
                        style: TextStyle(
                          color: _isStreaming ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _infoTile(
              title: "RTMP URL (use in OBS / Larix)",
              value: _rtmpUrl,
              onCopy: () => _copy(_rtmpUrl, "RTMP URL"),
            ),
            _infoTile(
              title: "Stream Key (IMPORTANT)",
              value: _streamKey,
              onCopy: () => _copy(_streamKey, "Stream Key"),
            ),
            _infoTile(
              title: "HLS Playback URL",
              value: _hlsUrl,
              onCopy: () => _copy(_hlsUrl, "HLS URL"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _loading || _isStreaming ? null : () => _updateStream(true),
                icon: const Icon(Icons.videocam),
                label: Text(_loading ? "Please wait..." : "Start Stream"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading || !_isStreaming
                    ? null
                    : () => _updateStream(false),
                icon: const Icon(Icons.stop_circle),
                label: Text(_loading ? "Please wait..." : "Stop Stream"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              child: const Text(
                "Steps:\n"
                "1. Tap Start Stream\n"
                "2. Open OBS / Larix Broadcaster\n"
                "3. Set RTMP URL and Stream Key exactly as above\n"
                "4. Start broadcasting\n"
                "5. Users can then watch the HLS URL",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
