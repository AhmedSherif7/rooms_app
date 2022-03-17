import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String? id;
  final String? title;
  final String? category;
  final Map<String, dynamic>? createdBy;
  final Timestamp? createdOn;
  final List<dynamic>? speakers;
  final List<dynamic>? invitedSpeakers;
  final List<dynamic>? audience;
  final Timestamp? dateTime;
  final Timestamp? startedAt;
  final Timestamp? endedAt;
  final String? type;
  String? status;

  RoomModel({
    this.id,
    this.title,
    this.category,
    this.createdBy,
    this.createdOn,
    this.speakers,
    this.invitedSpeakers,
    this.audience,
    this.dateTime,
    this.startedAt,
    this.endedAt,
    this.type,
    this.status,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      createdBy: json['createdBy'] as Map<String, dynamic>?,
      createdOn: json['createdOn'] as Timestamp?,
      speakers: json['speakers'] as List<dynamic>?,
      invitedSpeakers: json['invitedSpeakers'] as List<dynamic>?,
      audience: json['audience'] as List<dynamic>?,
      dateTime: json['dateTime'] as Timestamp?,
      startedAt: json['startedAt'] as Timestamp?,
      endedAt: json['endedAt'] as Timestamp?,
      type: json['type'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'createdBy': createdBy,
      'createdOn': createdOn,
      'speakers': speakers,
      'invitedSpeakers': invitedSpeakers,
      'audience': audience,
      'dateTime': dateTime,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'type': type,
      'status': status,
    };
  }
}
