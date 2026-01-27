import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Cloud Function triggered when a new message is created in a chat room.
 * Sends push notifications to all room members except the sender.
 */
export const onNewMessage = functions.firestore
  .document("rooms/{roomId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const { roomId } = context.params;
    const messageData = snapshot.data();

    if (!messageData) {
      console.log("No message data found");
      return null;
    }

    const { authorId, text } = messageData;

    // Get the room to find members
    const roomDoc = await db.collection("rooms").doc(roomId).get();
    if (!roomDoc.exists) {
      console.log(`Room ${roomId} not found`);
      return null;
    }

    const roomData = roomDoc.data();
    const memberIds: string[] = roomData?.memberIds || [];

    // Get sender's name for the notification title
    const senderDoc = await db.collection("users").doc(authorId).get();
    const senderName = senderDoc.data()?.name || "Someone";

    // Get FCM tokens for all members except the sender
    const tokensToNotify: string[] = [];

    for (const memberId of memberIds) {
      if (memberId === authorId) {
        continue; // Don't notify the sender
      }

      // Check if user has notifications enabled
      const prefsDoc = await db
        .collection("user_preferences")
        .doc(memberId)
        .get();

      if (prefsDoc.exists && prefsDoc.data()?.notificationsEnabled === false) {
        continue; // User has disabled notifications
      }

      // Get user's FCM tokens
      const tokensSnapshot = await db
        .collection("users")
        .doc(memberId)
        .collection("fcmTokens")
        .get();

      tokensSnapshot.forEach((tokenDoc) => {
        const token = tokenDoc.data().token;
        if (token) {
          tokensToNotify.push(token);
        }
      });
    }

    if (tokensToNotify.length === 0) {
      console.log("No tokens to notify");
      return null;
    }

    // Truncate message body for notification
    const messagePreview =
      text && text.length > 100 ? text.substring(0, 100) + "..." : text || "";

    // Build notification payload
    const payload: admin.messaging.MulticastMessage = {
      tokens: tokensToNotify,
      notification: {
        title: senderName,
        body: messagePreview,
      },
      data: {
        roomId: roomId,
        messageId: snapshot.id,
        authorId: authorId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        notification: {
          channelId: "chat_messages",
          priority: "high",
          defaultSound: true,
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    // Send notifications
    try {
      const response = await messaging.sendEachForMulticast(payload);
      console.log(
        `Successfully sent ${response.successCount} notifications, ` +
          `${response.failureCount} failures`
      );

      // Clean up invalid tokens
      if (response.failureCount > 0) {
        const failedTokens: string[] = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            const errorCode = resp.error?.code;
            if (
              errorCode === "messaging/invalid-registration-token" ||
              errorCode === "messaging/registration-token-not-registered"
            ) {
              failedTokens.push(tokensToNotify[idx]);
            }
          }
        });

        // Delete invalid tokens from Firestore
        for (const token of failedTokens) {
          const tokenQuery = await db
            .collectionGroup("fcmTokens")
            .where("token", "==", token)
            .get();

          tokenQuery.forEach(async (doc) => {
            await doc.ref.delete();
            console.log(`Deleted invalid token: ${token}`);
          });
        }
      }

      // Save notification to recipient notification history
      for (const memberId of memberIds) {
        if (memberId === authorId) continue;

        await db
          .collection("users")
          .doc(memberId)
          .collection("notifications")
          .add({
            title: senderName,
            body: messagePreview,
            data: {
              roomId: roomId,
              messageId: snapshot.id,
            },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }

      return response;
    } catch (error) {
      console.error("Error sending notifications:", error);
      return null;
    }
  });
