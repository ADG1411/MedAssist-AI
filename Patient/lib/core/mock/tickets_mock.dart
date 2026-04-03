class TicketsMock {
  static const List<Map<String, dynamic>> tickets = [
    {
      'id': 'tk_123',
      'title': 'Persistent Chest Pain',
      'status': 'Open',
      'urgency': 'High',
      'assignedDoctor': 'Dr. Sarah Connor',
      'symptomSummary': 'Dull ache radiating to left arm.',
      'createdAt': '2023-11-01T10:00:00Z',
      'progress': 0.25,
    },
    {
      'id': 'tk_124',
      'title': 'Mild Headache',
      'status': 'Resolved',
      'urgency': 'Low',
      'assignedDoctor': 'Dr. Kyle Reese',
      'symptomSummary': 'Throbbing headache for 2 days.',
      'createdAt': '2023-10-25T14:30:00Z',
      'progress': 1.0,
    },
  ];
}

