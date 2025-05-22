import 'package:flutter/material.dart';
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';

import '../../../config/theme/theme.dart';
import '../bottom_sheet/wall_material_detail_sheet.dart';

class WallMaterialCard extends StatelessWidget {
  final WallMaterial material;
  final VoidCallback onTap;

  const WallMaterialCard({super.key, required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Card(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  children: [
                    Image.asset(material.image, fit: BoxFit.scaleDown, height: 65, width: 65,),
                    const SizedBox(height: 5,),
                    Text(material.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryMetraShop),),
                    const SizedBox(height: 5,),
                    Text(material.size, style: const TextStyle(fontSize: 7, color: AppColors.primaryMetraShop),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialDetails(BuildContext context, WallMaterial material) {
    showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return WallMaterialDetailSheet(material: material, scrollController: scrollController);
        },
      ),
    );
  }
}
