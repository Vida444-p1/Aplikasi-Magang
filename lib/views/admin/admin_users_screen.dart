import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Manajemen Pengguna',
      currentRoute: '/admin/users',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Pengguna Sistem',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Direktori lengkap mahasiswa pendaftar magang dan entitas perusahaan mitra kampus.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context), height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 15, color: AppTheme.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'Akses: Administrator Kampus',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.primaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab bar container
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.mutedText(context),
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(LucideIcons.graduationCap, size: 18),
                    text: 'Daftar Mahasiswa (Peserta)',
                  ),
                  Tab(
                    icon: Icon(LucideIcons.building, size: 18),
                    text: 'Daftar Perusahaan Mitra',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama, NIM, atau universitas/perusahaan...',
                prefixIcon: Icon(LucideIcons.search, size: 18, color: AppTheme.mutedText(context)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppTheme.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.border(context)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tab content
            SizedBox(
              height: 520,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPesertaList(),
                  _buildPerusahaanList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesertaList() {
    final list = [
      {'nama': 'Vida Rizki Prasetyo', 'nim': '25523013', 'prodi': 'Teknik Informatika', 'univ': 'Universitas Islam Indonesia', 'status': 'aktif'},
      {'nama': 'Ahmad Fauzi', 'nim': '22523044', 'prodi': 'Sistem Informasi', 'univ': 'Universitas Gadjah Mada', 'status': 'aktif'},
      {'nama': 'Siti Nurhaliza', 'nim': '23523102', 'prodi': 'Teknik Informatika', 'univ': 'Universitas Islam Indonesia', 'status': 'aktif'},
      {'nama': 'Budi Santoso', 'nim': '22523091', 'prodi': 'Teknik Elektro', 'univ': 'Institut Teknologi Bandung', 'status': 'aktif'},
    ];

    final filtered = list.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item['nama']!.toLowerCase().contains(_searchQuery) ||
          item['nim']!.toLowerCase().contains(_searchQuery) ||
          item['prodi']!.toLowerCase().contains(_searchQuery) ||
          item['univ']!.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final firstLetter = item['nama']!.isNotEmpty ? item['nama']![0] : 'P';

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border(context)),
            boxShadow: AppTheme.getCardShadow(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryLight, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppTheme.text(context))),
                      const SizedBox(height: 2),
                      Text('NIM: ${item['nim']} • ${item['prodi']} • ${item['univ']}', style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context))),
                    ],
                  ),
                ),
                StatusBadge(status: item['status']!),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Detail', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerusahaanList() {
    final list = [
      {'nama': 'PT Teknologi Nusantara Digital', 'industri': 'Software House & Mobile Dev', 'lokasi': 'Yogyakarta', 'lowongan': '3 Lowongan'},
      {'nama': 'Inovasi Kreatif Studio', 'industri': 'UI/UX & Product Design', 'lokasi': 'Jakarta Selatan', 'lowongan': '1 Lowongan'},
      {'nama': 'PT Solusi Data Dinamis', 'industri': 'Cloud & Enterprise Architecture', 'lokasi': 'Bandung', 'lowongan': '2 Lowongan'},
    ];

    final filtered = list.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item['nama']!.toLowerCase().contains(_searchQuery) ||
          item['industri']!.toLowerCase().contains(_searchQuery) ||
          item['lokasi']!.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border(context)),
            boxShadow: AppTheme.getCardShadow(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.building, color: AppTheme.info, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppTheme.text(context))),
                      const SizedBox(height: 2),
                      Text('${item['industri']} • ${item['lokasi']} • ${item['lowongan']}', style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.badgeCheck, size: 12, color: AppTheme.success),
                      SizedBox(width: 4),
                      Text('Mitra Resmi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Detail', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
