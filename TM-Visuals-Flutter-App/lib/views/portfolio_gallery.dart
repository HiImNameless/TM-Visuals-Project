import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/portfolio_gallery_viewmodel.dart';

class PortfolioGalleryScreen extends StatelessWidget {
  const PortfolioGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioGalleryViewModel()..loadGallery(),
      child: const _PortfolioGalleryContent(),
    );
  }
}

class _PortfolioGalleryContent extends StatelessWidget {
  const _PortfolioGalleryContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PortfolioGalleryViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Portfolio gallery', style: TextStyle(color: Colors.orange)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : vm.errorMessage != null
                ? Center(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  )
                : vm.items.isEmpty
                    ? const Center(
                        child: Text(
                          'No portfolio items yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: vm.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = vm.items[index];
                          return Card(
                            color: const Color(0xFF1C1C1C),
                            child: ListTile(
                              title: Text(
                                item.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                item.isVideo ? 'Video' : 'Image',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: const Icon(Icons.photo_library_outlined, color: Colors.orange),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
