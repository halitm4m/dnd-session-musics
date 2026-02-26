import 'package:dnd_session_musics/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:dnd_session_musics/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:dnd_session_musics/ui/views/home/home_view.dart';
import 'package:dnd_session_musics/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:dnd_session_musics/services/playlist_storage_service.dart';
import 'package:dnd_session_musics/services/spotify_remote_service.dart';
import 'package:stacked_services/stacked_services.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SpotifyRemoteService),
    LazySingleton(classType: PlaylistStorageService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
