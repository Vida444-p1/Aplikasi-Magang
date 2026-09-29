import 'package:go_router/go_router.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/peserta/peserta_dashboard_screen.dart';
import '../../views/peserta/vacancy_list_screen.dart';
import '../../views/peserta/vacancy_detail_screen.dart';
import '../../views/peserta/apply_screen.dart';
import '../../views/peserta/my_applications_screen.dart';
import '../../views/peserta/logbook_screen.dart';
import '../../views/peserta/peserta_profile_screen.dart';
import '../../views/perusahaan/perusahaan_dashboard_screen.dart';
import '../../views/perusahaan/manage_vacancies_screen.dart';
import '../../views/perusahaan/vacancy_form_screen.dart';
import '../../views/perusahaan/applicants_screen.dart';
import '../../views/perusahaan/applicant_detail_screen.dart';
import '../../views/perusahaan/intern_monitoring_screen.dart';
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/admin_users_screen.dart';
import '../../views/admin/admin_vacancies_screen.dart';
import '../../views/admin/admin_monitoring_screen.dart';
import '../../views/common/notifications_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Peserta Routes
    GoRoute(
      path: '/peserta/dashboard',
      builder: (context, state) => const PesertaDashboardScreen(),
    ),
    GoRoute(
      path: '/peserta/lowongan',
      builder: (context, state) => const VacancyListScreen(),
    ),
    GoRoute(
      path: '/peserta/lowongan/:id',
      builder: (context, state) => VacancyDetailScreen(
        vacancyId: state.pathParameters['id'] ?? 'vac-1',
      ),
    ),
    GoRoute(
      path: '/peserta/daftar/:id',
      builder: (context, state) => ApplyScreen(
        vacancyId: state.pathParameters['id'] ?? 'vac-1',
      ),
    ),
    GoRoute(
      path: '/peserta/pendaftaran',
      builder: (context, state) => const MyApplicationsScreen(),
    ),
    GoRoute(
      path: '/peserta/kegiatan',
      builder: (context, state) => const LogbookScreen(),
    ),
    GoRoute(
      path: '/peserta/profil',
      builder: (context, state) => const PesertaProfileScreen(),
    ),

    // Perusahaan Routes
    GoRoute(
      path: '/perusahaan/dashboard',
      builder: (context, state) => const PerusahaanDashboardScreen(),
    ),
    GoRoute(
      path: '/perusahaan/lowongan',
      builder: (context, state) => const ManageVacanciesScreen(),
    ),
    GoRoute(
      path: '/perusahaan/lowongan/tambah',
      builder: (context, state) => const VacancyFormScreen(),
    ),
    GoRoute(
      path: '/perusahaan/pelamar',
      builder: (context, state) => const ApplicantsScreen(),
    ),
    GoRoute(
      path: '/perusahaan/pelamar/:id',
      builder: (context, state) => ApplicantDetailScreen(
        applicantId: state.pathParameters['id'] ?? 'app-1',
      ),
    ),
    GoRoute(
      path: '/perusahaan/monitoring',
      builder: (context, state) => const InternMonitoringScreen(),
    ),

    // Admin Routes
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: '/admin/lowongan',
      builder: (context, state) => const AdminVacanciesScreen(),
    ),
    GoRoute(
      path: '/admin/monitoring',
      builder: (context, state) => const AdminMonitoringScreen(),
    ),

    // Common
    GoRoute(
      path: '/notifikasi',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);
