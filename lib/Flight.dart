class Flight {
  String place;
  String fromTo;
  //DateTime date;
  String date;
  String offers; // Assuming offers are a list of strings for simplicity
  String language;
  String money;

  Flight({
    required this.place,
    required this.fromTo,
    required this.date,
    required this.offers,
    required this.language,
    required this.money,
  });

  Map<String, dynamic> toJson() {
    return {
      'place': place,
      'fromTo': fromTo,
      'date': date,
      'offers': offers,
      'language': language,
      'money': money,
    };
  }

  static Flight fromJson(Map<String, dynamic> json) {
    return Flight(
      place: json['place'],
      fromTo: json['fromTo'],
      //date: DateTime.parse(json['date']),
      date: json['date'],
      offers: json['offers'],
      language: json['language'],
      money: json['money'],
    );
  }
}
