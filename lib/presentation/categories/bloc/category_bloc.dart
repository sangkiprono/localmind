import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<CreateCategory>(_onCreate);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _repository.createCategory(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _repository.updateCategory(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _repository.deleteCategory(event.id);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}