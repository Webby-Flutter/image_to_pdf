// pagination_model.dart
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool hasMore;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.hasMore,
  });
}