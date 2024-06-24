import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocument extends StatefulWidget {
  const UploadDocument({Key? key, required this.onImageSelected}) : super(key: key);

  final Function onImageSelected;

  @override
  State<UploadDocument> createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> {

  List<File> selectedImage = [];
  final ImagePicker _picker = ImagePicker();

  getImage() async {
    final List<XFile> image = await _picker.pickMultiImage();
    for (var element in image) {
      selectedImage.add(File(element.path));
    }
    widget.onImageSelected(selectedImage);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Text('Upload Documents (License and Vehicle Papers)',style: Theme.of(context).textTheme.headlineSmall,),

        const SizedBox(height: 15,),


        GestureDetector(
          onTap: (){
            getImage();
          },
          child: Container(
            width: Get.width,
            height: Get.height*0.25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffE3E3E3).withOpacity(0.4),
                border: Border.all(color: const Color(0xff2FB654).withOpacity(0.26),width: 1)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload,size: 40,color: Color(0xff7D7D7D),),
                Text(selectedImage.isEmpty?'Tap here to upload ': 'Document is selected.',style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Color(0xff7D7D7D)),),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30,),
        SizedBox(
          width: Get.width,
          height: 130,
          child: selectedImage.isEmpty
              ? const Center(
                  child: Text("No image found"),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImage.length,
                  itemBuilder: (ctx, i){
                    return Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.file(
                        selectedImage[i],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
          ),
        )


      ],
    );
  }
}
