import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ShopProduct {
  final int id;
  final String name;
  final String shortTitle;
  final int price;
  final int mrp;
  final String imageUrl;
  final String productUrl;
  final bool isInCart;

  ShopProduct({
    required this.id,
    required this.name,
    required this.shortTitle,
    required this.price,
    required this.mrp,
    required this.imageUrl,
    required this.productUrl,
    required this.isInCart,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      shortTitle: json['short_title'] as String,
      price: json['price'] as int,
      mrp: json['mrp'] as int,
      imageUrl: json['image_url'] as String,
      productUrl: json['product_url'] as String,
      isInCart: json['is_in_cart'] as bool? ?? false,
    );
  }
}

// Product Details Model
class ProductDetails {
  final int id;
  final String name;
  final String shortTitle;
  final String description;
  final String howToUse;
  final int price;
  final int mrp;
  final String imageUrl;
  final String productUrl;
  final List<String> images;
  final String warranty;
  final bool codAvailable;

  ProductDetails({
    required this.id,
    required this.name,
    required this.shortTitle,
    required this.description,
    required this.howToUse,
    required this.price,
    required this.mrp,
    required this.imageUrl,
    required this.productUrl,
    required this.images,
    required this.warranty,
    required this.codAvailable,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    // Parse images from gallery field - FIXED: gallery is array of strings
    List<String> imagesList = [];
    if (json['gallery'] != null) {
      try {
        final gallery = json['gallery'] as List<dynamic>;
        // FIXED: Direct string mapping, not object mapping
        imagesList = gallery
            .map((item) => item as String)
            .toList();
      } catch (e) {
        print('Error parsing gallery: $e');
      }
    }
    
    // Add main image first if available
    if (json['main_image'] != null && json['main_image'].toString().isNotEmpty) {
      imagesList.insert(0, json['main_image'] as String);
    }
    
    // Fallback if no images
    if (imagesList.isEmpty) {
      imagesList.add('https://via.placeholder.com/400x300?text=No+Image');
    }

    return ProductDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      shortTitle: '', // Not in API, using empty string
      description: json['description'] as String? ?? '',
      howToUse: json['how_to_use'] as String? ?? '',
      price: json['price'] as int,
      mrp: json['mrp'] as int,
      imageUrl: json['main_image'] as String? ?? '', // Changed from image_url
      productUrl: json['amazon_link'] as String? ?? json['flipkart_link'] as String? ?? '',
      images: imagesList,
      warranty: json['warranty'] as String? ?? '',
      codAvailable: json['cod_available'] as bool? ?? false,
    );
  }

  int get discountPercent {
    if (mrp <= 0) return 0;
    return (((mrp - price) / mrp) * 100).toInt();
  }
}

class ShopService {
  static const String _baseUrl = 'https://app.ngf132.com/app_api/get_products_api';
  static const String _productDetailsUrl = 'https://app.ngf132.com/app_api/get_full_product_details_api';

  // Existing method for fetching products list
  static Future<List<ShopProduct>> fetchProducts({
    required String smValue,
    required String dgValue,
  }) async {
    try {
      // Check internet connectivity first
      print('🔍 Checking internet connectivity...');
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception('No internet connection');
        }
        print('✅ Internet connection available');
      } on SocketException catch (_) {
        throw Exception('No internet connection. Please check your network settings.');
      }

      final body = {
        'sm': smValue,
        '6s888iop': '6s888iop',
        'dg': dgValue,
      };

      print('🔵 Making request to: $_baseUrl');
      print('🔵 Body parameters: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout after 30 seconds');
        },
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['status'] != 'success') {
          throw Exception('API returned non-success status: ${jsonData['status']}');
        }

        final List<dynamic> productsData = jsonData['data'] as List<dynamic>;
        
        return productsData
            .map((product) => ShopProduct.fromJson(product as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Network error: Cannot connect to server. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception('Connection failed: Please check your internet connection.');
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      throw Exception('Invalid response from server');
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Error: $e');
    }
  }

  // Fetch product details
  static Future<ProductDetails> fetchProductDetails({
    required String productId,
    required String smValue,
    required String dgValue,
  }) async {
    try {
      print('🔵 Fetching product details for ID: $productId');

      // Build URL with query parameters
      final uri = Uri.parse(_productDetailsUrl).replace(queryParameters: {
        'pid': productId,
      });

      print('🔵 Request URL: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'sm': smValue,
          '6s888iop': '6s888iop',
          'dg': dgValue,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout after 30 seconds'),
      );

      print('✅ Product Details Response status: ${response.statusCode}');
      print('✅ Product Details Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['status'] != 'success') {
          throw Exception('API returned non-success status: ${jsonData['status']}');
        }

        final productData = jsonData['data'] as Map<String, dynamic>;
        
        return ProductDetails.fromJson(productData);
      } else {
        throw Exception('Failed to load product details. Status code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Network error: Please check your internet connection');
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception('Connection failed: Please check your internet connection.');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error fetching product details: $e');
    }
  }
}
