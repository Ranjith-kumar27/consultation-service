import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/di/injection_container.dart';

class RecentChatsPage extends StatefulWidget {
  const RecentChatsPage({super.key});

  @override
  State<RecentChatsPage> createState() => _RecentChatsPageState();
}

class _RecentChatsPageState extends State<RecentChatsPage> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserAndChats();
  }

  Future<void> _loadUserAndChats() async {
    final result = await sl<AuthRepository>().getCurrentUser();
    if (mounted) {
      setState(() {
        currentUserId = result.fold((l) => null, (r) => r.uid);
      });
      context.read<ChatBloc>().add(LoadRecentChatsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Chats')),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading || currentUserId == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecentChatsLoaded) {
            if (state.chats.isEmpty) {
              return const Center(child: Text('No recent chats found.'));
            }
            return ListView.separated(
              itemCount: state.chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final participants = chat['participants'] as List<dynamic>;
                final otherUserId = participants.firstWhere(
                  (id) => id != currentUserId,
                  orElse: () => '',
                );

                // Here we might need the name of the other user.
                // For now, using the chatId as a placeholder or a default name.
                // In a production app, we would fetch user details.
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text('Chat with $otherUserId'), // Placeholder
                  subtitle: const Text('Tap to open conversation'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    context.push('/chat/$otherUserId/User');
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
