import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_social_chat/core/interfaces/i_connectivity_repository.dart';

// It works well on the real devices, but
// there is a known issue that the package is not working properly in the simulators.

// "On iOS, the connectivity status might not update when WiFi status changes, this is a known issue that only affects simulators
// For details see https://github.com/fluttercommunity/plus_plugins/issues/479."

class ConnectivityRepository implements IConnectivityRepository {
  final Connectivity _connectivity;

  ConnectivityRepository(this._connectivity);

  @override
  Stream<ConnectivityResult> get connectivityStateChanges {
    return _connectivity.onConnectivityChanged.map((connectivityResult) {
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return ConnectivityResult.mobile;
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return ConnectivityResult.wifi;
      } else {
        return ConnectivityResult.none;
      }
    });
  }
}
