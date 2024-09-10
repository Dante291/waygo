class Rating {
  String id;
  String rideId;
  String raterId;
  String ratedId;
  double rating;
  String comment;
  DateTime ratingTime;

  Rating({
    required this.id,
    required this.rideId,
    required this.raterId,
    required this.ratedId,
    required this.rating,
    this.comment = '',
    required this.ratingTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideId': rideId,
      'raterId': raterId,
      'ratedId': ratedId,
      'rating': rating,
      'comment': comment,
      'ratingTime': ratingTime,
    };
  }
}
