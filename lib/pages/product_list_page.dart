/// 상품 목록 페이지
/// 
/// 당근 마켓의 상품 목록을 표시하는 화면입니다.
/// 카테고리별 필터링, 검색, 정렬 기능을 제공합니다.
/// 
/// 주요 기능:
/// - 상품 목록 표시
/// - 카테고리별 필터링
/// - 검색 기능
/// - 정렬 기능 (최신순, 가격순, 인기순)
/// - 상품 상세 페이지로 이동
/// 
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:flutter/material.dart';
import 'package:flutter_sandbox/models/product.dart';

/// 상품 목록을 표시하는 페이지
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  /// 현재 선택된 카테고리
  ProductCategory? _selectedCategory;
  
  /// 검색어
  String _searchQuery = '';
  
  /// 정렬 방식
  SortType _sortType = SortType.latest;
  
  /// 상품 목록 (임시 데이터)
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// 상품 목록을 로드하는 메서드 (임시 데이터)
  void _loadProducts() {
    // 실제로는 API에서 데이터를 가져옵니다
    _products = [
      Product(
        id: '1',
        title: '아이폰 14 Pro 256GB',
        description: '거의 새 제품입니다. 케이스와 액정보호필름 포함',
        price: 800000,
        imageUrls: ['https://example.com/iphone.jpg'],
        category: ProductCategory.digital,
        status: ProductStatus.onSale,
        sellerId: 'seller1',
        sellerNickname: '김철수',
        location: '역삼동',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        viewCount: 45,
        likeCount: 12,
      ),
      Product(
        id: '2',
        title: '맥북 에어 M2 13인치',
        description: '2023년 구매, 보증기간 남음',
        price: 1200000,
        imageUrls: ['https://example.com/macbook.jpg'],
        category: ProductCategory.digital,
        status: ProductStatus.onSale,
        sellerId: 'seller2',
        sellerNickname: '이영희',
        location: '역삼동',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        viewCount: 78,
        likeCount: 23,
      ),
      Product(
        id: '3',
        title: '나이키 에어맥스 270',
        description: '사이즈 270, 3번 정도만 신었습니다',
        price: 80000,
        imageUrls: ['https://example.com/nike.jpg'],
        category: ProductCategory.sports,
        status: ProductStatus.onSale,
        sellerId: 'seller3',
        sellerNickname: '박민수',
        location: '역삼동',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        viewCount: 32,
        likeCount: 8,
      ),
    ];
  }

  /// 필터링된 상품 목록을 반환하는 메서드
  List<Product> get _filteredProducts {
    List<Product> filtered = _products;

    // 카테고리 필터링
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // 정렬
    switch (_sortType) {
      case SortType.latest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.popular:
        filtered.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '상품 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 필터
          _buildCategoryFilter(),
          
          // 상품 목록
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductList(),
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터를 생성하는 위젯
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 전체 카테고리
          _buildCategoryChip('전체', null),
          const SizedBox(width: 8),
          
          // 각 카테고리
          ...ProductCategory.values.map((category) => 
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(_getCategoryText(category), category),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 칩을 생성하는 위젯
  Widget _buildCategoryChip(String label, ProductCategory? category) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 상품 목록을 생성하는 위젯
  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductItem(product);
      },
    );
  }

  /// 상품 아이템을 생성하는 위젯
  Widget _buildProductItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              // 상품 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              
              // 상품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 제목
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // 상품 설명
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // 가격과 위치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // 조회수와 찜 수
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${product.viewCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.favorite, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${product.likeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 상태를 표시하는 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '상품이 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 카테고리나 검색어를 시도해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 다이얼로그를 표시하는 메서드
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('상품 검색'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: '상품명을 입력하세요',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('검색'),
            ),
          ],
        );
      },
    );
  }

  /// 정렬 다이얼로그를 표시하는 메서드
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('정렬 방식'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortType.values.map((sortType) {
              return RadioListTile<SortType>(
                title: Text(sortType.displayName),
                value: sortType,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() {
                    _sortType = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// 카테고리 텍스트를 반환하는 메서드
  String _getCategoryText(ProductCategory category) {
    switch (category) {
      case ProductCategory.digital:
        return '디지털기기';
      case ProductCategory.furniture:
        return '가구/인테리어';
      case ProductCategory.kids:
        return '유아동';
      case ProductCategory.pets:
        return '반려동물';
      case ProductCategory.sports:
        return '스포츠/레저';
      case ProductCategory.womenClothing:
        return '여성의류';
      case ProductCategory.menClothing:
        return '남성의류';
      case ProductCategory.etc:
        return '기타';
    }
  }

  /// 상품 상세 페이지로 이동하는 메서드
  void _navigateToProductDetail(Product product) {
    // 상품 상세 페이지로 이동 (향후 구현)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} 상세 페이지로 이동'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// 정렬 방식을 나타내는 열거형
enum SortType {
  /// 최신순
  latest,
  /// 가격 낮은순
  priceLow,
  /// 가격 높은순
  priceHigh,
  /// 인기순
  popular,
}

/// SortType 확장 메서드
extension SortTypeExtension on SortType {
  String get displayName {
    switch (this) {
      case SortType.latest:
        return '최신순';
      case SortType.priceLow:
        return '가격 낮은순';
      case SortType.priceHigh:
        return '가격 높은순';
      case SortType.popular:
        return '인기순';
    }
  }
}
