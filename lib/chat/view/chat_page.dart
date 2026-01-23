import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:august_chat/chat/bloc/chat_bloc.dart';
import '../../app/theme_provider.dart';

/// Kakao-style yellow color for sent messages.
const kakaoYellow = Color(0xFFFEE500);

/// Kakao-style background color for the chat.
const kakaoChatBg = Color(0xffbacee0);

/// Background color for incoming messages.
const kakaoIncoming = Colors.white;

/// Background color for outgoing messages.
const kakaoOutgoing = kakaoYellow;

/// Text color on yellow background.
const kakaoTextOnYellow = Color(0xFF1A1A1A);

/// Chat conversation page with Kakao-style UI.
///
/// Supports text messaging, emoji picker, stickers, and attachments.
class ChatPage extends StatefulWidget {
  /// Creates a [ChatPage] for the given room.
  const ChatPage({super.key, required this.roomId, this.title});

  /// The ID of the chat room.
  final String roomId;

  /// Optional title for the app bar.
  final String? title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

/// Types of input panels that can be shown above the composer.
enum InputPanel {
  /// No panel shown.
  none,

  /// Emoji picker panel.
  emoji,

  /// Sticker selection panel.
  sticker,

  /// Attachment options panel.
  attach,
}

class _ChatPageState extends State<ChatPage> {  
  ChatBloc? _bloc;

  final _composerController = TextEditingController();
  final _composerFocus = FocusNode();    
  InputPanel _panel = InputPanel.none;

  @override
  Widget build(BuildContext context) {
    ChatTheme kakaoTheme = ChatTheme.dark();

    if(context.watch<ThemeProvider>().themeMode == ThemeMode.light) {

      kakaoTheme = ChatTheme.light().copyWith(
        // overall background
        // This controls the main chat background in v2
        colors: ChatTheme.light().colors.copyWith(
          surface: kakaoChatBg,
          surfaceContainer: kakaoChatBg,
          primary: kakaoYellow,
        ),

        // Bubble shape (Kakao-like)
        shape: const BorderRadius.all(Radius.circular(10)),
      );
    }        

    return BlocProvider(
      create: (_) => ChatBloc(roomId: widget.roomId)..add(ChatStartEvent()),
      child: Builder(builder: (context) {
        final bloc = context.read<ChatBloc>();
        _bloc = bloc;

        return Scaffold(
          appBar: AppBar(title: Text(widget.title ?? '')),
          body: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.status == ChatStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Chat error'));
              }
              if (state.status == ChatStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Message list
              return Column(
                children: [
                  Expanded(
                    child: Chat(
                      chatController: bloc.chatController,
                      currentUserId: bloc.currentUserId,
                      resolveUser: bloc.resolveUser,
                      onMessageSend: (_) {},
                      
                      theme: kakaoTheme,
                      timeFormat: DateFormat.jm(),
                      builders: Builders(

                        // Hide default composer
                        composerBuilder: (context) => const SizedBox.shrink(),
                        
                        // Bubble styling
                        textMessageBuilder: (context, message, index, {required isSentByMe, groupStatus}) {
                          return SimpleTextMessage(
                            message: message, // <-- TextMessage type here
                            index: index,
                            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                            sentBackgroundColor: kakaoYellow,
                            receivedBackgroundColor: Colors.white,
                            //timeAndStatusPosition: TimeAndStatusPosition.inline,
                            //timeAndStatusPositionInlineInsets: EdgeInsets.only(right: 20.0),
                            timeStyle: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 9,
                            ),
                            sentTextStyle: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 13,
                              height: 1.1,
                            ),
                            receivedTextStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              height: 1.1,
                            ),
                          );
                        },                               
                    
                        // Avatar / grouping wrapper
                        chatMessageBuilder: (context, message, index, animation, child, {required bool isSentByMe, MessageGroupStatus? groupStatus, bool? isRemoved}) {                    
                          final showAvatar = !isSentByMe && (groupStatus == null || groupStatus.isFirst);
                    
                          return GestureDetector(
                            onLongPress: () => _showReactionPicker(message.id),
                            child: ChatMessage(
                              message: message,
                              index: index,
                              animation: animation,
                              groupStatus: groupStatus,
                              isRemoved: isRemoved,
                              //verticalPadding: 20,                  
                              verticalGroupedPadding: 5,
                              leadingWidget: showAvatar
                                ? Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Avatar(
                                    userId: message.authorId,
                                    foregroundColor: Colors.black87,
                                    backgroundColor: Colors.white,
                                    size: 40
                                  ),
                                )
                              : const SizedBox(width: 50),
                              child: child, // keeps alignment when avatar hidden,
                              
                            ),
                          );
                        },


                      ),
                    ),
                  ),

                  // Bottom area: emoji on top and input below
                  SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Your emoji panel (example placeholder)
                        _buildBottomPanel(),
              
                        Container(
                          //color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _togglePanel(InputPanel.attach),
                              ),
                              IconButton(
                                icon: const Icon(Icons.emoji_emotions_outlined),
                                onPressed: () => _togglePanel(InputPanel.emoji),
                              ),
                              IconButton(
                                icon: const Icon(Icons.sticky_note_2_outlined),
                                onPressed: () => _togglePanel(InputPanel.sticker),
                              ),
                              
                              Expanded(
                                child: TextField(
                                  controller: _composerController,
                                  focusNode: _composerFocus,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    border: InputBorder.none,
                                  ),
                                  onTap: () {
                                    // Opening keyboard should hide emoji panel
                                    if (_panel != InputPanel.none) {
                                      setState(() => _panel = InputPanel.none);
                                    }
                                  },
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _send(),
                                ),
                              ),
                              
                              if (_composerController.text.trim().isEmpty)
                                IconButton(
                                  icon: const Icon(Icons.mic),
                                  onPressed: _startVoiceRecord, // TODO
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _send,
                                ),
                            ],
                          ),
                        ),                        
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  void _togglePanel(InputPanel p) {
    if (_panel == p) {
      // closing emoji -> open keyboard
      setState(() => _panel = InputPanel.none);
      _composerFocus.requestFocus();
    } else {
      // opening emoji -> hide keyboard
      _composerFocus.unfocus();
      setState(() => _panel = p);
    }
  }

  Widget _buildBottomPanel() {
    switch (_panel) {
      case InputPanel.emoji:
        return SizedBox(
          height: 280,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) => _insertEmoji(emoji.emoji),
          ),
        );

      case InputPanel.sticker:
        return SizedBox(
          height: 280,
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              _sticker('🐱'),
              _sticker('🐶'),
              _sticker('😂'),
              _sticker('🔥'),
            ],
          ),
        );

      case InputPanel.attach:
        return SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              _attachButton(Icons.image, 'Gallery'),
              _attachButton(Icons.camera_alt, 'Camera'),
              _attachButton(Icons.insert_drive_file, 'File'),
              _attachButton(Icons.location_on, 'Location'),
            ],
          ),
        );

      case InputPanel.none:
        return const SizedBox.shrink();
    }
  }

  Widget _sticker(String emoji) {
    return InkWell(
      onTap: () => _sendSticker(emoji),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
    );
  }

  Widget _attachButton(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _startVoiceRecord() {
    // TODO: Integrate record package for voice messages
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording not yet implemented')),
    );
  }

  Future<void> _sendSticker(String sticker) async {
    final bloc = _bloc;
    if (bloc == null) return;
    // TODO: Implement sticker sending
    // await bloc.sendSticker(sticker);
  }

  void _showReactionPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['👍','❤️','😂','😮','😢','🙏'].map((e) {
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              //_bloc!.addReaction(messageId, e);
            },
            child: Text(e, style: const TextStyle(fontSize: 32)),
          );
        }).toList(),
      ),
    );
  }

  void _insertEmoji(String emoji) {
    final c = _composerController;
    final text = c.text;
    final sel = c.selection;

    final start = sel.start >= 0 ? sel.start : text.length;
    final end = sel.end >= 0 ? sel.end : text.length;

    final newText = text.replaceRange(start, end, emoji);
    c.text = newText;
    c.selection = TextSelection.collapsed(offset: start + emoji.length);
    setState(() {}); // refresh send button state if needed
  }

  Future<void> _send() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;    

    await _bloc!.sendText(text);
    _composerController.clear();

    // keep keyboard open after sending (Kakao-ish)
    _composerFocus.requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    _composerController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }
}
