import 'package:flutter/foundation.dart';


class Karyawan {
  final String nama;
  final String umur;
  final String alamat;
  final List<String> hobi;

    Karyawan({
    required this.nama,
    required this.umur,
    required this.alamat,
    required this.hobi,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json){
    return Karyawan(
      nama: json['nama'],
      umur: json['umur'],
      alamat: json['alamat'],
      hobi: json['hobi'],
    );
  }

}

class Alamat {
  final String jalan;
  final String kota;
  final String provinsi;

  Alamat({
    required this.jalan,
    required this.kota,
    required this.provinsi,
  });

  factory Alamat.fromJson(Map<String, dynamic> json){
    return Alamat(
      jalan: json['jalan'],
      kota: json['kota'],
      provinsi: json['provinsi'],
    );
  }
}

