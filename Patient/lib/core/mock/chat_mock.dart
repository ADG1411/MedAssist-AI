class ChatMock {
  static const List<Map<String, dynamic>> initialMessages = [
    {
      'id': 'msg_1',
      'role': 'ai',
      'text': 'Hi John, I see you selected your Chest. Can you describe what kind of discomfort you are feeling?',
      'timestamp': '10:00 AM',
    },
  ];

  static const List<Map<String, dynamic>> testConversation = [
    {
      'id': 'msg_2',
      'role': 'user',
      'text': 'I have a tight feeling and a dull ache.',
      'timestamp': '10:01 AM',
    },
    {
      'id': 'msg_3',
      'role': 'ai',
      'text': 'Understood. Is it radiating to your arm or jaw, and do you feel short of breath?',
      'timestamp': '10:01 AM',
    },
  ];
}

