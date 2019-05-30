



exports.addTransfer = functions.https.onCall((data, context) => {
    const users = admin.firestore().collection('Transfer');
    return users.add({
        RefNum: data["RefNum"],
        address: data["address"],
        price: data["price"],
        progress: "0",
    });
});

exports.addUser = functions.https.onCall((data, context) => {
    const users = admin.firestore().collection('user');
    return users.document(data["IDNumber"]).add({
        Email: data["Email"],
        FirstName: data["FirstName"],
        IDNumber: data["IDNumber"],
        LastName: data["LastName"],
        Number: data["Number"],
        userID: data["userID"],
        progress: "0",
    });
});