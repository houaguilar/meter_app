
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/assets/icons.dart';

import '../../../config/constants/constants.dart';
import '../../../domain/entities/entities.dart';

class ArticleCard extends StatelessWidget {
  final ArticleEntity article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24),
      child: GestureDetector(
        child: Container(
          width: 300,
        //  margin: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            border: const Border(
              bottom: BorderSide(
                color: AppColors.bottomBorderSideWelcomeColor,
                width: 2,
              ),
            ),
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage(article.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.black.withOpacity(0.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  article.description,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14.0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    onPressed: () {
                      context.pushNamed('home-to-detail', pathParameters: {
                        'id': article.id,
                        'title': article.title,
                        'videoId': article.videoId
                      });
                    },
                    label: const Text(
                      'Ingresar',
                      style: TextStyle(color: AppColors.yellowMetraShop),
                    ),
                    icon: SvgPicture.asset(AppIcons.arrowRightYellowIcon),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
