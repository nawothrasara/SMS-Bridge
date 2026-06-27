class SmsData {
  final int? id;
  final String sender;
  final String body;
  final String refNo;
  final String amount;
  final String status;

  SmsData({
    this.id,
    required this.sender,
    required this.body,
    required this.refNo,
    required this.amount,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'refNo': refNo,
      'amount': amount,
      'status': status,
    };
  }

  factory SmsData.fromMap(Map<String, dynamic> map) {
    return SmsData(
      id: map['id'],
      sender: map['sender'],
      body: map['body'],
      refNo: map['refNo'],
      amount: map['amount'],
      status: map['status'],
    );
  }
}
