class UserProfile {
  final String id;
  final String email;
  final String namaLengkap;
  final String role; // 'peserta', 'perusahaan', 'admin'
  final String? nomorTelepon;
  final String? avatarUrl;
  final PesertaProfile? pesertaDetails;
  final PerusahaanProfile? perusahaanDetails;

  UserProfile({
    required this.id,
    required this.email,
    required this.namaLengkap,
    required this.role,
    this.nomorTelepon,
    this.avatarUrl,
    this.pesertaDetails,
    this.perusahaanDetails,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      role: json['role'] as String? ?? 'peserta',
      nomorTelepon: json['nomor_telepon'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      pesertaDetails: json['peserta_details'] != null
          ? (json['peserta_details'] is List
              ? ((json['peserta_details'] as List).isNotEmpty
                  ? PesertaProfile.fromJson((json['peserta_details'] as List)[0])
                  : null)
              : (json['peserta_details'] is Map
                  ? PesertaProfile.fromJson(json['peserta_details'] as Map<String, dynamic>)
                  : null))
          : null,
      perusahaanDetails: json['perusahaan_details'] != null
          ? (json['perusahaan_details'] is List
              ? ((json['perusahaan_details'] as List).isNotEmpty
                  ? PerusahaanProfile.fromJson((json['perusahaan_details'] as List)[0])
                  : null)
              : (json['perusahaan_details'] is Map
                  ? PerusahaanProfile.fromJson(json['perusahaan_details'] as Map<String, dynamic>)
                  : null))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama_lengkap': namaLengkap,
      'role': role,
      'nomor_telepon': nomorTelepon,
      'avatar_url': avatarUrl,
    };
  }
}

class PesertaProfile {
  final String id;
  final String userId;
  final String? nim;
  final String? programStudi;
  final String? universitas;
  final String? alamat;
  final List<String> keahlian;
  final String? cvUrl;

  PesertaProfile({
    required this.id,
    required this.userId,
    this.nim,
    this.programStudi,
    this.universitas,
    this.alamat,
    this.keahlian = const [],
    this.cvUrl,
  });

  factory PesertaProfile.fromJson(Map<String, dynamic> json) {
    return PesertaProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nim: json['nim'] as String?,
      programStudi: json['program_studi'] as String?,
      universitas: json['universitas'] as String?,
      alamat: json['alamat'] as String?,
      keahlian: (json['keahlian'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      cvUrl: json['cv_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nim': nim,
      'program_studi': programStudi,
      'universitas': universitas,
      'alamat': alamat,
      'keahlian': keahlian,
      'cv_url': cvUrl,
    };
  }
}

class PerusahaanProfile {
  final String id;
  final String userId;
  final String namaPerusahaan;
  final String? industri;
  final String? alamat;
  final String? website;
  final String? deskripsi;

  PerusahaanProfile({
    required this.id,
    required this.userId,
    required this.namaPerusahaan,
    this.industri,
    this.alamat,
    this.website,
    this.deskripsi,
  });

  factory PerusahaanProfile.fromJson(Map<String, dynamic> json) {
    return PerusahaanProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      namaPerusahaan: json['nama_perusahaan'] as String? ?? '',
      industri: json['industri'] as String?,
      alamat: json['alamat'] as String?,
      website: json['website'] as String?,
      deskripsi: json['deskripsi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_perusahaan': namaPerusahaan,
      'industri': industri,
      'alamat': alamat,
      'website': website,
      'deskripsi': deskripsi,
    };
  }
}
