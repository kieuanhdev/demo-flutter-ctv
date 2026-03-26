import '../repository/products_repository.dart';

class DeleteProductUsecase {
  final ProductsRepository repository;
  DeleteProductUsecase(this.repository);
  Future<void> call({required int id}) {
    return repository.deleteProduct(id: id);
  }
}
