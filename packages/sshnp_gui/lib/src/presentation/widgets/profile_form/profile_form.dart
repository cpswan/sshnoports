import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sshnoports/sshnp/sshnp.dart';
import 'package:sshnp_gui/src/controllers/navigation_rail_controller.dart';
import 'package:sshnp_gui/src/controllers/config_controller.dart';
import 'package:sshnp_gui/src/presentation/widgets/profile_form/custom_text_form_field.dart';
import 'package:sshnp_gui/src/controllers/navigation_controller.dart';
import 'package:sshnp_gui/src/utility/sizes.dart';
import 'package:sshnp_gui/src/utility/form_validator.dart';

class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key});

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late CurrentConfigState currentProfile;
  SSHNPPartialParams newConfig = SSHNPPartialParams.empty();
  @override
  void initState() {
    super.initState();
  }

  void onSubmit(SSHNPParams oldConfig, SSHNPPartialParams newConfig) async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      final controller = ref.read(configFamilyController(newConfig.profileName ?? oldConfig.profileName!).notifier);
      bool overwrite = currentProfile.configFileWriteState == ConfigFileWriteState.update;
      bool rename = newConfig.profileName.isNotNull &&
          newConfig.profileName!.isNotEmpty &&
          oldConfig.profileName.isNotNull &&
          oldConfig.profileName!.isNotEmpty &&
          newConfig.profileName != oldConfig.profileName;
      SSHNPParams config = SSHNPParams.merge(oldConfig, newConfig);
      if (rename) {
        // delete old config file and write the new one
        await ref.read(configFamilyController(oldConfig.profileName!).notifier).deleteConfig();
        await controller.createConfig(config);
      } else if (overwrite) {
        // overwrite the existing file
        await controller.updateConfig(config);
      } else {
        // create new config file
        await controller.createConfig(config);
      }
      if (context.mounted) {
        ref.read(navigationRailController.notifier).setRoute(AppRoute.home);
        context.pushReplacementNamed(AppRoute.home.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    currentProfile = ref.watch(currentConfigController);

    final asyncOldConfig = ref.watch(configFamilyController(currentProfile.profileName));
    return asyncOldConfig.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (oldConfig) {
          return SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomTextFormField(
                        initialValue: oldConfig.profileName,
                        labelText: strings.profileName,
                        onChanged: (value) {
                          newConfig = SSHNPPartialParams.merge(
                            newConfig,
                            SSHNPPartialParams(profileName: value),
                          );
                        },
                        validator: FormValidator.validateRequiredField,
                      ),
                      gapW8,
                      CustomTextFormField(
                        initialValue: oldConfig.params.device,
                        labelText: strings.device,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(device: value),
                        ),
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    children: [
                      CustomTextFormField(
                        initialValue: oldConfig.params.sshnpdAtSign ?? '',
                        labelText: strings.sshnpdAtSign,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(sshnpdAtSign: value),
                        ),
                        validator: FormValidator.validateAtsignField,
                      ),
                      gapW8,
                      CustomTextFormField(
                        initialValue: oldConfig.params.host ?? '',
                        labelText: strings.host,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(host: value),
                        ),
                        validator: FormValidator.validateRequiredField,
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    children: [
                      CustomTextFormField(
                        initialValue: oldConfig.params.sendSshPublicKey,
                        labelText: strings.sendSshPublicKey,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(sendSshPublicKey: value),
                        ),
                        validator: FormValidator.validateRequiredField,
                      ),
                      gapW8,
                      Row(
                        children: [
                          Text(strings.rsa),
                          gapW8,
                          Switch(
                              value: newConfig.rsa ?? oldConfig.params.rsa,
                              onChanged: (newValue) {
                                setState(() {
                                  newConfig = SSHNPPartialParams.merge(
                                    newConfig,
                                    SSHNPPartialParams(rsa: newValue),
                                  );
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    children: [
                      CustomTextFormField(
                          initialValue: oldConfig.params.remoteUsername ?? '',
                          labelText: strings.remoteUserName,
                          onChanged: (value) {
                            newConfig = SSHNPPartialParams.merge(
                              newConfig,
                              SSHNPPartialParams(remoteUsername: value),
                            );
                          }),
                      gapW8,
                      CustomTextFormField(
                        initialValue: oldConfig.params.port.toString(),
                        labelText: strings.port,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(port: int.tryParse(value)),
                        ),
                        validator: FormValidator.validateRequiredField,
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    children: [
                      CustomTextFormField(
                        initialValue: oldConfig.params.localPort.toString(),
                        labelText: strings.localPort,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(localPort: int.tryParse(value)),
                        ),
                      ),
                      gapW8,
                      CustomTextFormField(
                        initialValue: oldConfig.params.localSshdPort.toString(),
                        labelText: strings.localSshdPort,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(localSshdPort: int.tryParse(value)),
                        ),
                      ),
                    ],
                  ),
                  gapH10,
                  CustomTextFormField(
                    initialValue: oldConfig.params.localSshOptions.join(','),
                    hintText: strings.localSshOptionsHint,
                    labelText: strings.localSshOptions,
                    width: 192 * 2 + 10,
                    onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                      newConfig,
                      SSHNPPartialParams(localSshOptions: value.split(',')),
                    ),
                  ),
                  gapH10,
                  Row(
                    children: [
                      CustomTextFormField(
                        initialValue: oldConfig.params.atKeysFilePath,
                        labelText: strings.atKeysFilePath,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(atKeysFilePath: value),
                        ),
                      ),
                      gapW8,
                      CustomTextFormField(
                        initialValue: oldConfig.params.rootDomain,
                        labelText: strings.rootDomain,
                        onChanged: (value) => newConfig = SSHNPPartialParams.merge(
                          newConfig,
                          SSHNPPartialParams(rootDomain: value),
                        ),
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    children: [
                      Text(strings.verbose),
                      gapW8,
                      Switch(
                          value: newConfig.verbose ?? oldConfig.params.verbose,
                          onChanged: (newValue) {
                            setState(() {
                              newConfig = SSHNPPartialParams.merge(
                                newConfig,
                                SSHNPPartialParams(verbose: newValue),
                              );
                            });
                          }),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => onSubmit(oldConfig.params, newConfig),
                        child: Text(strings.submit),
                      ),
                      gapW8,
                      TextButton(
                        onPressed: () {
                          ref.read(navigationRailController.notifier).setRoute(AppRoute.home);
                          context.pushReplacementNamed(AppRoute.home.name);
                        },
                        child: Text(strings.cancel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
