import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vacancy_model.dart';
import '../services/vacancy_service.dart';

final vacancyServiceProvider = Provider<VacancyService>((ref) => VacancyService());

class VacancyFilterState {
  final String keyword;
  final String lokasi;
  final String bidang;
  final String sistemKerja;

  VacancyFilterState({
    this.keyword = '',
    this.lokasi = 'Semua',
    this.bidang = 'Semua',
    this.sistemKerja = 'Semua',
  });

  VacancyFilterState copyWith({
    String? keyword,
    String? lokasi,
    String? bidang,
    String? sistemKerja,
  }) {
    return VacancyFilterState(
      keyword: keyword ?? this.keyword,
      lokasi: lokasi ?? this.lokasi,
      bidang: bidang ?? this.bidang,
      sistemKerja: sistemKerja ?? this.sistemKerja,
    );
  }
}

final vacancyFilterProvider = StateProvider<VacancyFilterState>((ref) => VacancyFilterState());

final vacancyListProvider = FutureProvider<List<VacancyModel>>((ref) async {
  final service = ref.watch(vacancyServiceProvider);
  final filter = ref.watch(vacancyFilterProvider);

  return service.getVacancies(
    keyword: filter.keyword,
    lokasi: filter.lokasi,
    bidang: filter.bidang,
    sistemKerja: filter.sistemKerja,
  );
});

final vacancyDetailProvider = FutureProvider.family<VacancyModel?, String>((ref, id) async {
  final service = ref.watch(vacancyServiceProvider);
  return service.getVacancyById(id);
});
