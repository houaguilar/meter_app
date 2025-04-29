import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:meter_app/domain/usecases/home/inicio/get_articles_usecase.dart';

import '../../../../domain/entities/entities.dart';

part 'article_event.dart';
part 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetArticlesUseCase getArticlesUseCase;

  ArticleBloc({
    required GetArticlesUseCase getArticlesUseCase,
  }) : getArticlesUseCase = getArticlesUseCase,
        super(ArticleInitial()) {
    on<FetchArticles>((event, emit) async {
      emit(ArticleLoading());
      final result = await getArticlesUseCase.execute();
      result.fold(
            (failure) => emit(ArticleError(failure.message)),
            (articles) => emit(ArticleLoaded(articles)),
      );
    });
  }
}
