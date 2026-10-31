import '../../../core/view_models/public_list_view_model.dart';

class FavoritesViewModel extends PublicListViewModel {
  FavoritesViewModel(super.animals, super.favorites, super.photos)
    : super(favoritesOnly: true);
}
