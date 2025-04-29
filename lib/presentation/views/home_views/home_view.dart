import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/assets/images.dart';
import 'package:meter_app/presentation/widgets/bottom_sheet/measurements_bottom_sheet.dart';
import 'package:meter_app/presentation/widgets/cards/shortcut_card.dart';
import 'package:meter_app/presentation/widgets/carousels/carousel_cards_articles.dart';

import '../../../config/constants/constants.dart';
import '../../blocs/home/inicio/measurement_bloc.dart';
import '../../widgets/widgets.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    context.read<MeasurementBloc>().add(LoadMeasurementItems());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryMetraShop,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: 'METRA', style: TextStyle(color: AppColors.white)),
              TextSpan(text: 'SHOP', style: TextStyle(color: AppColors.blueMetraShop)),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<MeasurementBloc, MeasurementState> (
        listener: (context, state) {
          if (state is MeasurementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (BuildContext context, MeasurementState state) {
            if (state is MeasurementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MeasurementLoaded) {
              final items = state.items;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 35),
                    const Padding(
                      padding: EdgeInsets.only(right: 24, left: 24),
                      child: Text(
                        '¿Qué medición deseas hacer?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryMetraShop),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(right: 0, left: 0),
                      child: MeasurementSection(items: items.take(3).toList()),
                    ),
                    TextButton(
                      onPressed: () {
                        showMeasurementsSheet(context, items);
                        /*showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => MeasurementItemsBottomSheet(items: items),
                        );*/
                      },
                      child: const Text('Ver más', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
                    ),
                    const _HomeScreenView(),
                  ],
                ),
              );
            } else if (state is MeasurementError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No items found.'));
            }
          },
        ),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        //  MeasurementSection(),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.only(right: 24, left: 24),
            child: Text(
              'Te puede interesar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryMetraShop),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 24, left: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed('home-to-provider');
                      },
                      child: const ShortcutCard(
                          title: 'Proveedores',
                          imageAssetPath: AppImages.proveedoresHomeCardImg
                      ),
                    )
                ),
                const SizedBox(height: 20),
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed('home-to-test');
                      },
                      child: const ShortcutCard(
                          title: 'Materiales',
                          imageAssetPath: AppImages.materialesHomeCardImg
                      ),
                    )
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.only(right: 24, left: 24),
            child: Text(
              'Expande tus conocimientos',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.leadTextColor
              ),
            ),
          ),
          const SizedBox(height: 20),
          const CarouselCardsArticles(),
          const SizedBox(height: 40),
        ],
    );
  }
}
