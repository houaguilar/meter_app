class ArticleContentImage {
  final String imageUrl;
  final String? caption;
  final int orderIndex;

  const ArticleContentImage({
    required this.imageUrl,
    this.caption,
    required this.orderIndex,
  });
}