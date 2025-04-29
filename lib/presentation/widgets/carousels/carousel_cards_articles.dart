import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/home/inicio/article_bloc.dart';
import '../cards/article_card.dart';

class CarouselCardsArticles extends StatelessWidget {
  const CarouselCardsArticles({super.key});


  @override
  Widget build(BuildContext context) {

    context.read<ArticleBloc>().add(FetchArticles());

    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading) {
          return const CircularProgressIndicator();
        } else if (state is ArticleLoaded) {
          return SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                return ArticleCard(article: state.articles[index]);
              },
            ),
          );
        } else if (state is ArticleError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('No articles found'));
        }
      },
    );
  }
}
