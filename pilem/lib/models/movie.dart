class Movie {
  // Menyimpan id unik dari film
  final int id;

  // Menyimpan judul film
  final String title;

  // Menyimpan deskripsi / ringkasan cerita film
  final String overview;

  // Menyimpan path poster film
  final String posterPath;

  // Menyimpan path gambar backdrop / banner film
  final String backdropPath;

  // Menyimpan tanggal rilis film
  final String releaseDate;

  // Menyimpan rating film
  final double voteAverage;

  // Constructor untuk membuat object Movie
  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  // Factory constructor untuk mengubah data JSON/API menjadi object Movie
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      // Mengambil id dari JSON
      // Jika null, sebaiknya diberi nilai default 0
      id: json['id'] ?? 0,

      // Mengambil judul film dari JSON
      title: json['title'] ?? '',

      // Mengambil overview/deskripsi film
      overview: json['overview'] ?? '',

      // Mengambil path poster film
      posterPath: json['poster_path'] ?? '',

      // Mengambil path backdrop film
      backdropPath: json['backdrop_path'] ?? '',

      // Mengambil tanggal rilis film
      releaseDate: json['release_date'] ?? '',

      // Mengambil rating film
      // Karena dari API bisa berupa int atau double,
      // maka diubah dulu ke num lalu ke double
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
    );
  }

  // Method toJson digunakan untuk mengubah object Movie menjadi Map
  // Biasanya dipakai saat ingin menyimpan data ke SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
    };
  }
}
