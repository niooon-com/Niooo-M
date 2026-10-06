class CastMember {
  final String name;
  final String role;
  final String avatarUrl;

  const CastMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });
}

class MovieReview {
  final String id;
  final String authorName;
  final String authorHandle;
  final double rating;
  final String comment;
  final String timeAgo;

  const MovieReview({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });
}

class MovieItem {
  final String id;
  final String title;
  final String tagline;
  final String synopsis;
  final String posterUrl;
  final String backdropUrl;
  final String videoStreamUrl;
  final double rating;
  final int releaseYear;
  final String duration;
  final String maturityRating;
  final String qualityBadge; // e.g. "4K HDR · Dolby Atmos"
  final List<String> genres;
  final String director;
  final List<CastMember> cast;
  final bool isFeatured;
  final bool isTrending;
  final bool isNewRelease;
  final double watchProgress; // 0.0 to 1.0 for Continue Watching
  final List<MovieReview> reviews;

  const MovieItem({
    required this.id,
    required this.title,
    required this.tagline,
    required this.synopsis,
    required this.posterUrl,
    required this.backdropUrl,
    required this.videoStreamUrl,
    required this.rating,
    required this.releaseYear,
    required this.duration,
    required this.maturityRating,
    required this.qualityBadge,
    required this.genres,
    required this.director,
    required this.cast,
    this.isFeatured = false,
    this.isTrending = false,
    this.isNewRelease = false,
    this.watchProgress = 0.0,
    this.reviews = const [],
  });

  MovieItem copyWith({
    double? watchProgress,
    List<MovieReview>? reviews,
    double? rating,
  }) {
    return MovieItem(
      id: id,
      title: title,
      tagline: tagline,
      synopsis: synopsis,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      videoStreamUrl: videoStreamUrl,
      rating: rating ?? this.rating,
      releaseYear: releaseYear,
      duration: duration,
      maturityRating: maturityRating,
      qualityBadge: qualityBadge,
      genres: genres,
      director: director,
      cast: cast,
      isFeatured: isFeatured,
      isTrending: isTrending,
      isNewRelease: isNewRelease,
      watchProgress: watchProgress ?? this.watchProgress,
      reviews: reviews ?? this.reviews,
    );
  }
}

class MovieCatalogData {
  static final List<MovieItem> initialMovies = [
    MovieItem(
      id: "mov_solaris_protocol",
      title: "Solaris Protocol: Eclipse",
      tagline: "Beyond the event horizon lies the final transmission.",
      synopsis:
          "In 2094, Commander Aria Vance leads a deep-space reconnaissance crew aboard the vessel Hyperion to investigate a quantum signal originating from a Dyson swarm around a dying star. What they uncover challenges the foundation of human consciousness.",
      posterUrl:
          "https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
      rating: 9.4,
      releaseYear: 2026,
      duration: "2h 28m",
      maturityRating: "PG-13",
      qualityBadge: "4K IMAX · Dolby Atmos",
      genres: ["Sci-Fi", "Thriller", "Action"],
      director: "Denis V. Kurosawa",
      isFeatured: true,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.64,
      cast: const [
        CastMember(
          name: "Elena Rostova",
          role: "Cmdr. Aria Vance",
          avatarUrl:
              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
        ),
        CastMember(
          name: "Marcus Sterling",
          role: "Dr. Kaelen Thorne",
          avatarUrl:
              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80",
        ),
        CastMember(
          name: "Kenji Takahashi",
          role: "Pilot Zero",
          avatarUrl:
              "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80",
        ),
      ],
      reviews: const [
        MovieReview(
          id: "rev_1",
          authorName: "Arif Rahman",
          authorHandle: "@arif_cinema",
          rating: 9.5,
          comment:
              "Breathtaking visual design and soundscape. The zero-gravity docking sequence is pure cinema.",
          timeAgo: "2h ago",
        ),
        MovieReview(
          id: "rev_2",
          authorName: "Sophia Lin",
          authorHandle: "@sophia_scifi",
          rating: 9.2,
          comment:
              "One of the best hard sci-fi thrillers of the decade. Every frame feels like a painting.",
          timeAgo: "5h ago",
        ),
      ],
    ),
    MovieItem(
      id: "mov_emerald_syndicate",
      title: "The Emerald Syndicate",
      tagline: "Every fortune leaves a digital shadow.",
      synopsis:
          "When an underground cryptographic vault in Neo-Zurich is breached during a blackout, a former intelligence architect must outmaneuver an international syndicate across Tokyo, Geneva, and Singapore before the global ledger resets.",
      posterUrl:
          "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      rating: 9.1,
      releaseYear: 2026,
      duration: "2h 14m",
      maturityRating: "R",
      qualityBadge: "4K UHD · HDR10+",
      genres: ["Action", "Crime", "Thriller"],
      director: "Julian Mercer",
      isFeatured: true,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.35,
      cast: const [
        CastMember(
          name: "Liam Vance",
          role: "Julian Cross",
          avatarUrl:
              "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80",
        ),
        CastMember(
          name: "Nadia Al-Mansoor",
          role: "Cipher",
          avatarUrl:
              "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80",
        ),
      ],
      reviews: const [
        MovieReview(
          id: "rev_3",
          authorName: "Tanvir Hasan",
          authorHandle: "@tanvir_reviews",
          rating: 9.0,
          comment:
              "Non-stop adrenaline from the opening heist in Zurich to the rooftop chase in Tokyo!",
          timeAgo: "1d ago",
        ),
      ],
    ),
    MovieItem(
      id: "mov_chronicles_of_aeloria",
      title: "Kingdom of Aeloria",
      tagline: "A crown forged in starlight. A realm divided by fire.",
      synopsis:
          "Across the shattered floating continents of Aeloria, a young cartographer discovers an ancient astrolabe capable of awakening the slumbering Leviathans of the Sky.",
      posterUrl:
          "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      rating: 8.9,
      releaseYear: 2025,
      duration: "2h 42m",
      maturityRating: "PG-13",
      qualityBadge: "4K Dolby Vision",
      genres: ["Fantasy", "Adventure", "Drama"],
      director: "Clara Lindqvist",
      isFeatured: true,
      isTrending: true,
      isNewRelease: false,
      watchProgress: 0.0,
      cast: const [
        CastMember(
          name: "Freya Lind",
          role: "Lyra of the Reach",
          avatarUrl:
              "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80",
        ),
        CastMember(
          name: "Arthur Pendelton",
          role: "Lord Valerius",
          avatarUrl:
              "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=300&q=80",
        ),
      ],
    ),
    MovieItem(
      id: "mov_cyber_ronin",
      title: "Neon Ronin 2099",
      tagline: "Honor has no firmware update.",
      synopsis:
          "In rain-drenched Neo-Osaka, an augmented swordsman protects a runaway synthetic prodigy whose neural core holds the key to liberating sentient machines.",
      posterUrl:
          "https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      rating: 9.3,
      releaseYear: 2026,
      duration: "1h 58m",
      maturityRating: "R",
      qualityBadge: "4K 60FPS · HDR",
      genres: ["Sci-Fi", "Action", "Anime"],
      director: "Hiroshi Sato",
      isFeatured: false,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.82,
      cast: const [
        CastMember(
          name: "Renji Ito",
          role: "Kenshin-X",
          avatarUrl:
              "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80",
        ),
      ],
    ),
    MovieItem(
      id: "mov_velvet_nocturne",
      title: "Velvet Nocturne",
      tagline: "Every note hides a confession.",
      synopsis:
          "During a snowy winter in Paris, a virtuoso cellist and a restorative art detective uncover a century-old mystery hidden inside an unpublished manuscript.",
      posterUrl:
          "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1514306191717-452ec28c7814?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      rating: 8.7,
      releaseYear: 2025,
      duration: "2h 06m",
      maturityRating: "PG-13",
      qualityBadge: "4K UHD · Lossless Audio",
      genres: ["Drama", "Mystery", "Romance"],
      director: "Camille Moreau",
      isFeatured: false,
      isTrending: false,
      isNewRelease: true,
      watchProgress: 0.0,
      cast: const [
        CastMember(
          name: "Claire Dubois",
          role: "Élise Laurent",
          avatarUrl:
              "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
        ),
      ],
    ),
    MovieItem(
      id: "mov_apex_velocity",
      title: "Apex Velocity",
      tagline: "Zero brakes. 380 kilometers per hour.",
      synopsis:
          "An underdog engineering team enters the Hyper-GT World Championship with an experimental hydrogen-plasma prototype, facing off against reigning factory dynasties on the streets of Monaco and Monza.",
      posterUrl:
          "https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      rating: 8.8,
      releaseYear: 2026,
      duration: "2h 19m",
      maturityRating: "PG-13",
      qualityBadge: "4K IMAX · Dolby Atmos",
      genres: ["Action", "Drama", "Sports"],
      director: "Marco Bellini",
      isFeatured: false,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.0,
      cast: const [
        CastMember(
          name: "Matteo Rossi",
          role: "Luca Conti",
          avatarUrl:
              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80",
        ),
      ],
    ),
    MovieItem(
      id: "mov_abyssal_echo",
      title: "Abyssal Echo",
      tagline: "11,000 meters down, the ocean remembers.",
      synopsis:
          "A deep-sea drilling station in the Mariana Trench loses contact after breaching a subterranean thermal cavern teeming with bioluminescent megafauna.",
      posterUrl:
          "https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      rating: 8.6,
      releaseYear: 2025,
      duration: "1h 54m",
      maturityRating: "R",
      qualityBadge: "4K HDR10",
      genres: ["Thriller", "Sci-Fi", "Horror"],
      director: "Jonas Lindholm",
      isFeatured: false,
      isTrending: false,
      isNewRelease: false,
      watchProgress: 0.0,
      cast: const [
        CastMember(
          name: "Hannah Volkov",
          role: "Dr. Vera Lind",
          avatarUrl:
              "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80",
        ),
      ],
    ),
    MovieItem(
      id: "mov_quantum_heist",
      title: "Zero-Day Mirage",
      tagline: "Steal the future before it compiles.",
      synopsis:
          "A crew of rogue quantum cryptographers attempts an impossible mid-air data extraction aboard a stratospheric server airship.",
      posterUrl:
          "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=900&q=85",
      backdropUrl:
          "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=1600&q=85",
      videoStreamUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoy.mp4",
      rating: 9.0,
      releaseYear: 2026,
      duration: "2h 09m",
      maturityRating: "PG-13",
      qualityBadge: "4K Dolby Vision",
      genres: ["Action", "Sci-Fi", "Crime"],
      director: "Zackery Chen",
      isFeatured: false,
      isTrending: true,
      isNewRelease: true,
      watchProgress: 0.0,
      cast: const [
        CastMember(
          name: "Devon Brooks",
          role: "Cole",
          avatarUrl:
              "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80",
        ),
      ],
    ),
  ];
}
