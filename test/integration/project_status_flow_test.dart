import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scloud_desktop/features/auth/auth_cubit.dart';
import 'package:scloud_desktop/features/auth/auth_repository.dart';
import 'package:scloud_desktop/features/auth/auth_state.dart';
import 'package:scloud_desktop/features/projects/project.dart';
import 'package:scloud_desktop/features/projects/project_list_cubit.dart';
import 'package:scloud_desktop/features/projects/project_list_screen.dart';
import 'package:scloud_desktop/features/projects/project_repository.dart';
import 'package:scloud_desktop/features/status/status_cubit.dart';
import 'package:scloud_desktop/features/status/status_screen.dart';
import 'package:scloud_desktop/l10n/app_localizations.dart';
import 'package:scloud_desktop/l10n/app_localizations_en.dart'
    show AppLocalizationsEn;

/// Integration test for project list and status flow (per constitution).
void main() {
  testWidgets('Project list shows empty state when no projects', (tester) async {
    final projectRepo = _TestProjectRepository();
    final projectListCubit = ProjectListCubit(projectRepo);
    final authCubit = AuthCubit(_TestAuthRepository());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProjectListScreen(
          cubit: projectListCubit,
          authCubit: authCubit,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().projectListTitle), findsOneWidget);
    expect(find.text(AppLocalizationsEn().noProjectsYet), findsOneWidget);
  });

  testWidgets('Status screen shows no-project message', (tester) async {
    final projectRepo = _TestProjectRepository();
    final projectListCubit = ProjectListCubit(projectRepo);
    final statusCubit = StatusCubit(
      projectRepo,
      projectListCubit: projectListCubit,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatusScreen(cubit: statusCubit),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().noProjectSelected), findsOneWidget);
    expect(
      find.text(AppLocalizationsEn().chooseProjectToViewStatus),
      findsOneWidget,
    );
  });
}

class _TestAuthRepository extends AuthRepository {
  @override
  Future<AuthState> restoreSession() async =>
      const Authenticated('test@example.com');

  @override
  Future<AuthState> login() async => const Authenticated('test@example.com');

  @override
  Future<void> signOut() async {}
}

class _TestProjectRepository extends ProjectRepository {
  @override
  Future<List<Project>> fetchProjectList({String? linkedProjectDirectory}) async =>
      [];
}
