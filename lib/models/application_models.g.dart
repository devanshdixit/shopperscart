// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// ignore: non_constant_identifier_names
_$_User _$_$_UserFromJson(Map<String, dynamic> json) {
  return _$_User(
    id: json['id'] as String,
    email: json['email'] as String?,
    name: json['name'] as String?,
    pushToken: json['pushToken'] as String?,
    photourl: json['photourl'] as String?,
    mobileNo: json['mobileNo'] as String?,
  );
}

// ignore: non_constant_identifier_names
Map<String, dynamic> _$_$_UserToJson(_$_User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'pushToken': instance.pushToken,
      'photourl': instance.photourl,
      'mobileNo': instance.mobileNo,
    };
