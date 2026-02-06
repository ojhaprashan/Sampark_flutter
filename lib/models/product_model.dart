class Product {
  final String id;
  final String name;
  final List<ProductVariant> variants;
  final double rating;
  final int totalRatings;
  final int totalReviews;
  final List<String> images;
  final List<String> offers;
  final List<ProductHighlight> highlights;
  final List<ProductReview> reviews;

  Product({
    required this.id,
    required this.name,
    required this.variants,
    required this.rating,
    required this.totalRatings,
    required this.totalReviews,
    required this.images,
    required this.offers,
    required this.highlights,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      variants: (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList(),
      rating: json['rating'].toDouble(),
      totalRatings: json['totalRatings'],
      totalReviews: json['totalReviews'],
      images: List<String>.from(json['images']),
      offers: List<String>.from(json['offers']),
      highlights: (json['highlights'] as List)
          .map((h) => ProductHighlight.fromJson(h))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((r) => ProductReview.fromJson(r))
          .toList(),
    );
  }
}

class ProductVariant {
  final String name;
  final int price;
  final int originalPrice;
  final int discountPercent;
  final List<ProductSpec> specifications;
  final List<String> features;

  ProductVariant({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.specifications,
    required this.features,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      name: json['name'],
      price: json['price'],
      originalPrice: json['originalPrice'],
      discountPercent: json['discountPercent'],
      specifications: (json['specifications'] as List)
          .map((s) => ProductSpec.fromJson(s))
          .toList(),
      features: List<String>.from(json['features']),
    );
  }
}

class ProductSpec {
  final String label;
  final String value;

  ProductSpec({required this.label, required this.value});

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      label: json['label'],
      value: json['value'],
    );
  }
}

class ProductHighlight {
  final String icon;
  final String text;

  ProductHighlight({required this.icon, required this.text});

  factory ProductHighlight.fromJson(Map<String, dynamic> json) {
    return ProductHighlight(
      icon: json['icon'],
      text: json['text'],
    );
  }
}

class ProductReview {
  final String name;
  final int rating;
  final String title;
  final String review;
  final bool verified;

  ProductReview({
    required this.name,
    required this.rating,
    required this.title,
    required this.review,
    this.verified = false,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      name: json['name'],
      rating: json['rating'],
      title: json['title'],
      review: json['review'],
      verified: json['verified'] ?? false,
    );
  }
}
