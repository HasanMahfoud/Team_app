import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImgBBService {
  
  Future<String?> uploadToImgBB(File file) async {
    const apiKey = "0422eba03214310e16579862bc665e41";
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    try {
      final request = http.MultipartRequest("POST", url);
      request.files.add(await http.MultipartFile.fromPath("image", file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (data["success"] == true) {
        return data["data"]["url"];
      } else {
        debugPrint("Upload failed: $data");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

   //  اختيار ورفع عدة صور مع إظهار مؤشر تحميل
  
  Future<List<String>> pickAndUploadImages(Function(bool) setDialogLoading) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if ( pickedFiles.isEmpty) return [];

    setDialogLoading(true);
    List<String> urls = [];

    for (var picked in pickedFiles) {
      final file = File(picked.path);
      final url = await uploadToImgBB(file);
      if (url != null) urls.add(url);
    }

    setDialogLoading(false);
    return urls;
  }


}