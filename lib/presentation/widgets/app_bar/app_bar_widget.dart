import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:meter_app/presentation/widgets/dialogs/confirm_dialog.dart';

import '../../../config/theme/theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  AppBarWidget({
    super.key,
    required this.titleAppBar,
    this.isVisibleTutorial = false,
    this.showTutorial,
  });
  final String titleAppBar;
  final bool isVisibleTutorial;
  final VoidCallback? showTutorial;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryMetraShop,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.white),
      actions: [
        Visibility(
          visible: isVisibleTutorial,
          child: IconButton(onPressed: showTutorial, icon: const Icon(Icons.info_rounded)),),
        TextButton(
            onPressed: () {
              ConfirmDialog.show(
                  context: context,
                  title: '¿Seguro que deseas salir?',
                  content: 'Si sales del resumen se perderá todo el progreso.',
                  confirmText: 'Salir',
                  cancelText: 'Cancelar',
                  onConfirm: () {context.goNamed('home');},
                  onCancel: () {context.pop();},
                  isVisible: true);
            },
            child: SvgPicture.asset(AppIcons.closeDialogIcon, width: 32, height: 32,),
        ),
      ],
      title: Text(titleAppBar, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),),
    );
  }
}