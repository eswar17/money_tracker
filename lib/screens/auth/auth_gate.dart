import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../services/auth/user_service.dart';
import '../../main.dart';
import 'login_screen.dart';
import 'workspace_setup_screen.dart';

import '../../services/workspace/workspace_context.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: UserService.hasWorkspace(user.uid),
          builder: (context, workspaceSnapshot) {
            if (workspaceSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasWorkspace = workspaceSnapshot.data ?? false;

            if (!hasWorkspace) {
              return const WorkspaceSetupScreen();
            }

            return FutureBuilder<String?>(
              future: UserService.getWorkspaceId(user.uid),

              builder: (context, workspaceIdSnapshot) {
                if (workspaceIdSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                WorkspaceContext.currentWorkspaceId = workspaceIdSnapshot.data;

                print(
                  'WORKSPACE Eswar CONTEXT: ${WorkspaceContext.currentWorkspaceId}',
                );

                return const MainNavigationScreen();
              },
            );
          },
        );
      },
    );
  }
}
