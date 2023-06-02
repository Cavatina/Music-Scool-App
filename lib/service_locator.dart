/* Music'scool App - Copyright (C) 2020  Music'scool DK

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>. */

import 'package:get_it/get_it.dart';
import 'services/remote_notifications.dart';
import 'services/api.dart';
import 'services/api_service.dart';
import 'services/intl_service.dart';
import 'services/local_notifications.dart';
import 'viewmodels/auth.dart';

GetIt locator = GetIt.instance;

void setupServiceLocator() {
  locator.registerSingleton<Api>(ApiService());
  locator.registerSingletonAsync<LocalNotifications>(
      () async => LocalNotifications().init());
  locator.registerSingletonAsync<RemoteNotifications>(
      () async => RemoteNotifications().init(),
      dependsOn: [LocalNotifications]);
  locator.registerSingletonAsync<IntlService>(() async => IntlService().init());
  locator.registerSingletonAsync<AuthModel>(
      () async => AuthModel(locator<Api>()).init(),
      dependsOn: [RemoteNotifications, LocalNotifications]);
}
