import 'package:flutter/material.dart';
import 'package:hentaiz_viewer/models/hentai_display_model.dart';
import 'package:hentaiz_viewer/view_models/main_page_view_model.dart';
import 'package:hentaiz_viewer/views/components/account_bar.dart';
import 'package:hentaiz_viewer/views/components/hentai_card.dart';
import 'package:hentaiz_viewer/views/components/search_action.dart';
import 'package:hentaiz_viewer/views/watch_video.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainPageViewModel(),
      child: Scaffold(
        appBar: const MainPageAppBar(),
        body: const MainPageBody(),
      ),
    );
  }
}

/// ---------------- AppBar ----------------
class MainPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Hentai List"),
      actions: const [SearchAction(),AccountAction()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// ---------------- Body ----------------
class MainPageBody extends StatelessWidget {
  const MainPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewModel>(
      builder: (context, vm, _) => Column(
        children: [
          Expanded(child: HentaiGrid(vm: vm)),
          PaginationBar(vm: vm),
        ],
      ),
    );
  }
}

/// ---------------- Hentai Grid ----------------
class HentaiGrid extends StatelessWidget {
  final MainPageViewModel vm;
  const HentaiGrid({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HentaiDisplayModel>>(
      future: vm.hentaiListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No videos found"));
        }

        final list = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.65,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return HentaiCard(
              item: item,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoWatchPage(videoId: item.id, videoTitle: item.title),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// ---------------- Pagination ----------------
class PaginationBar extends StatelessWidget {
  final MainPageViewModel vm;
  const PaginationBar({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: vm.currentPage > 1
                ? () => vm.changePage(vm.currentPage - 1)
                : null,
          ),
          Text("Page ${vm.currentPage}"),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => vm.changePage(vm.currentPage + 1),
          ),
        ],
      ),
    );
  }
}
