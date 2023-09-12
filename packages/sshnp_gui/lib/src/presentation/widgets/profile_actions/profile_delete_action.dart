import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sshnoports/sshnp/sshnp.dart';
import 'package:sshnp_gui/src/controllers/config_controller.dart';
import 'package:sshnp_gui/src/presentation/widgets/profile_actions/profile_action_button.dart';
import 'package:sshnp_gui/src/utility/sizes.dart';

class ProfileDeleteAction extends StatelessWidget {
  final SSHNPParams params;
  const ProfileDeleteAction(this.params, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileActionButton(
      onPressed: () async {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => DeleteAlertDialog(sshnpParams: params),
        );
      },
      icon: const Icon(Icons.delete_forever),
    );
  }
}

class DeleteAlertDialog extends ConsumerWidget {
  const DeleteAlertDialog({required this.sshnpParams, super.key});
  final SSHNPParams sshnpParams;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final strings = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Center(
        child: AlertDialog(
          title: Center(child: Text(strings.warning)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.warningMessage),
              gapH12,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: strings.note,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: strings.noteMessage,
                    ),
                  ],
                ),
              )
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancelButton,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(decoration: TextDecoration.underline)),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(configFamilyController(sshnpParams.profileName!).notifier).deleteConfig();
                if (context.mounted) Navigator.of(context).pop();
              },
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
              child: Text(
                strings.deleteButton,
                style:
                    Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
