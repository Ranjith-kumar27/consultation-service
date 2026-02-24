const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Trigger for new Chat Messages
exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const messageData = snap.data();

    const senderId = messageData.senderId;
    const receiverId = messageData.receiverId;
    const text = messageData.text;

    // We don't want to send notifications to ourselves
    if (senderId === receiverId) {
      return null;
    }

    try {
      // 1. Fetch recipient user data to get FCM Token
      const receiverDoc = await admin
        .firestore()
        .collection("users")
        .doc(receiverId)
        .get();

      if (!receiverDoc.exists) {
        console.log(`No user found for receiver ID: ${receiverId}`);
        return null;
      }

      const receiverData = receiverDoc.data();
      const fcmToken = receiverData.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token available for user ${receiverId}`);
        return null;
      }

      // 2. Fetch sender user data to get their name
      const senderDoc = await admin
        .firestore()
        .collection("users")
        .doc(senderId)
        .get();
      
      let senderName = "Someone";
      if (senderDoc.exists) {
         senderName = senderDoc.data().name || "Someone";
      }

      // 3. Construct Payload
      const payload = {
        notification: {
          title: `New message from ${senderName}`,
          body: text.length > 50 ? text.substring(0, 50) + "..." : text,
          sound: "default",
        },
        data: {
          type: "chat",
          senderId: senderId,
          chatId: context.params.chatId,
        },
        token: fcmToken,
      };

      // 4. Send Notification
      const response = await admin.messaging().send(payload);
      console.log("Successfully sent chat message:", response);
      return response;

    } catch (error) {
      console.error("Error sending chat notification:", error);
      return null;
    }
  });

// Trigger for new Video Calls
exports.sendCallNotification = functions.firestore
  .document("calls/{callId}")
  .onCreate(async (snap, context) => {
    const callData = snap.data();

    const callerId = callData.callerId;
    const receiverId = callData.receiverId;
    const channelName = callData.channelName;
    
    try {
       // 1. Fetch recipient user data
       const receiverDoc = await admin
       .firestore()
       .collection("users")
       .doc(receiverId)
       .get();

     if (!receiverDoc.exists) {
       console.log(`No user found for receiver ID: ${receiverId}`);
       return null;
     }

     const receiverData = receiverDoc.data();
     const fcmToken = receiverData.fcmToken;

     if (!fcmToken) {
       console.log(`No FCM token available for user ${receiverId}`);
       return null;
     }

     // 2. Fetch caller user data
     const callerDoc = await admin
       .firestore()
       .collection("users")
       .doc(callerId)
       .get();
     
     let callerName = "Someone";
     if (callerDoc.exists) {
        callerName = callerDoc.data().name || "Someone";
     }

     // 3. Construct Payload
     const payload = {
       notification: {
         title: `Incoming Video Call`,
         body: `${callerName} is calling you...`,
         sound: "default", // You might want a ringing sound here ideally
       },
       data: {
         type: "call",
         callerId: callerId,
         channelName: channelName,
         callId: context.params.callId
       },
       token: fcmToken,
     };

     // 4. Send Notification
     const response = await admin.messaging().send(payload);
     console.log("Successfully sent call notification:", response);
     return response;

    } catch (error) {
        console.error("Error sending call notification:", error);
        return null;
    }
  });
