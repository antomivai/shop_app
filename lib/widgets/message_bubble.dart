import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Key? key;
  final String message;
  final String userId;
  final String avatarUrl;
  final bool isMyMessage;

  MessageBubble(this.userId, this.message, this.avatarUrl, this.isMyMessage,
      {this.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment:
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              children: [
                isMyMessage
                    ? Text('')
                    : Row(
                        children: [
                          Text(
                            userId,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 8),
                          ),
                        ],
                      ),
                Container(
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? Colors.grey
                        : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: !isMyMessage
                          ? Radius.circular(0)
                          : Radius.circular(12),
                      bottomRight: !isMyMessage
                          ? Radius.circular(12)
                          : Radius.circular(0),
                    ),
                  ),
                  width: 140,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    message,
                    style: TextStyle(
                        color: isMyMessage
                            ? Colors.black
                            : Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isMyMessage)
          Positioned(
            top: 2,
            left: 140,
            child: CircleAvatar(
              radius: 11,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ),
      ],
      clipBehavior: Clip.none,
    );
  }
}
