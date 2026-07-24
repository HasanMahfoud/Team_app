import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapScreenReal extends StatefulWidget {
  const MapScreenReal({super.key});

  @override
  State<MapScreenReal> createState() => _MapScreenRealState();
}

class _MapScreenRealState extends State<MapScreenReal>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  String? _errorMessage;
  bool _isSatellite = false;
  double _currentZoom = 15.0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  StreamSubscription<Position>? _locationStream;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _initLocation();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _locationStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'خدمة الموقع معطّلة. يرجى تفعيلها.';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'تم رفض الإذن.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'تم رفض الإذن نهائياً.';
          _isLoadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _onPositionReceived(pos);

      _locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(_onPositionReceived);
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ أثناء تحديد الموقع: $e';
        _isLoadingLocation = false;
      });
    }
  }

  void _onPositionReceived(Position pos) {
    if (!mounted) return;
    setState(() {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
      _isLoadingLocation = false;
    });
  }

  void _goToMyLocation() {
    if (_currentLocation == null) return;
    _mapController.move(_currentLocation!, _currentZoom);
  }

  void _zoom(double delta) {
    final newZoom = (_currentZoom + delta).clamp(3.0, 20.0);
    setState(() => _currentZoom = newZoom);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _ErrorView(
        message: _errorMessage!,
        onRetry: _initLocation,
      );
    }

    if (_isLoadingLocation) {
      return const _LoadingView();
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation!,
            initialZoom: _currentZoom,
            onMapEvent: (event) {
              if (event is MapEventMove) {
                setState(() => _currentZoom = event.camera.zoom);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.university_guide',
              maxNativeZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 60,
                  height: 60,
                  child: _UserMarker(pulseAnim: _pulseAnim),
                ),
              ],
            ),
          ],
        ),
        SafeArea(
          child: _TopBar(
            isSatellite: _isSatellite,
            onToggle: () => setState(() => _isSatellite = !_isSatellite),
          ),
        ),
        Positioned(
          right: 16,
          top: MediaQuery.of(context).padding.top + 80,
          child: _ZoomControls(
            onZoomIn: () => _zoom(1),
            onZoomOut: () => _zoom(-1),
          ),
        ),
        const Positioned(
          left: 16,
          bottom: 110,
          child: _GpsChip(),
        ),
        Positioned(
          right: 16,
          bottom: 110,
          child: _MyLocationFab(onTap: _goToMyLocation),
        ),
      ],
    );
  }
}

// باقي الودجتس كما هي بدون أي تعديل…

class _UserMarker extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _UserMarker({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60 * pulseAnim.value,
            height: 60 * pulseAnim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6)
                  .withValues(alpha: 0.18 * pulseAnim.value),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isSatellite;
  final VoidCallback onToggle;
  const _TopBar({required this.isSatellite, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: Color(0xFF9BB0AD), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'ابحث في الحرم الجامعي...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSatellite ? const Color(0xFF0A8F6B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.layers_rounded,
                color: isSatellite ? Colors.white : const Color(0xFF5A6B69),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ZoomBtn(icon: Icons.add_rounded, onTap: onZoomIn),
          Container(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
          _ZoomBtn(icon: Icons.remove_rounded, onTap: onZoomOut),
        ],
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: const Color(0xFF0D1B1A), size: 22),
        ),
      ),
    );
  }
}

class _GpsChip extends StatelessWidget {
  const _GpsChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_fixed_rounded, color: Color(0xFF0A8F6B), size: 14),
          SizedBox(width: 6),
          Text(
            'موقعك الحالي',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1B1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationFab extends StatefulWidget {
  final VoidCallback onTap;
  const _MyLocationFab({required this.onTap});

  @override
  State<_MyLocationFab> createState() => _MyLocationFabState();
}

class _MyLocationFabState extends State<_MyLocationFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 54,
        height: 54,
        transform: Matrix4.identity()..scale(_pressed ? 0.92 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0A8F6B), Color(0xFF16C490)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A8F6B).withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF0A8F6B)),
          SizedBox(height: 20),
          Text(
            'جاري تحديد موقعك...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A6B69),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: Color(0xFFEF4444),
                size: 38,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5A6B69),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('حاول مجدداً'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A8F6B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
