import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/native/native_bridge.dart';
import '../../core/settings/app_settings.dart';
import '../../core/util/modem_address.dart';
import '../l10n_helpers.dart';
import 'feedback.dart';

/// Indicateur de chargement centré.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message ?? context.l10n.commonLoading, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Erreur traduite, aide Wi-Fi si le modem est injoignable, et bouton
/// « Réessayer ».
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectivity = isConnectivityError(error);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              connectivity ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              describeError(context.l10n, error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (connectivity) ...[
              const SizedBox(height: 8),
              const ConnectivityHint(),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Aide contextuelle quand le modem est injoignable : pas de Wi-Fi, Wi-Fi
/// d'un autre réseau, ou Wi-Fi « sans internet » (normal quand les données sont coupées).
class ConnectivityHint extends StatefulWidget {
  const ConnectivityHint({super.key});

  @override
  State<ConnectivityHint> createState() => _ConnectivityHintState();
}

class _ConnectivityHintState extends State<ConnectivityHint> {
  late final Future<WifiStatus> _status = context.read<NativeBridge>().wifiStatus();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final address = context.read<AppSettings>().modemAddress;
    return FutureBuilder<WifiStatus>(
      future: _status,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null || !status.supported) return const SizedBox.shrink();
        final String text;
        if (!status.wifiConnected) {
          text = l.hintWifiDisconnected;
        } else if (status.gateway != null && status.gateway != ModemAddress.hostOf(address)) {
          text = l.hintWrongWifi(status.gateway!, address);
        } else if (!status.validated) {
          text = l.hintNoInternetIsOk;
        } else {
          return const SizedBox.shrink();
        }
        return Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        );
      },
    );
  }
}

/// Charge des données une fois, affiche chargement ou erreur, puis
/// [builder] avec les données et une fonction de rechargement.
///
/// Pendant un rechargement, les données précédentes restent affichées ; un
/// échec de rechargement est signalé par un message en bas de l'écran.
class FutureLoader<T> extends StatefulWidget {
  const FutureLoader({super.key, required this.load, required this.builder, this.loadingMessage});

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data, Future<void> Function() reload) builder;
  final String? loadingMessage;

  @override
  State<FutureLoader<T>> createState() => _FutureLoaderState<T>();
}

class _FutureLoaderState<T> extends State<FutureLoader<T>> {
  late T _data;
  bool _hasData = false;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      if (!_hasData) _error = null;
    });
    try {
      final data = await widget.load();
      if (!mounted) return;
      setState(() {
        _data = data;
        _hasData = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_hasData) {
        showErrorSnack(context, e);
      } else {
        setState(() => _error = e);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) {
      if (_error != null && !_loading) return ErrorView(error: _error!, onRetry: _reload);
      return LoadingView(message: widget.loadingMessage);
    }
    return Stack(
      children: [
        widget.builder(context, _data, _reload),
        if (_loading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator()),
      ],
    );
  }
}
