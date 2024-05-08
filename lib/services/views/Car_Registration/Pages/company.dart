import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/profile_controller.dart';
import '../../../model/companyModel.dart';


class SelectCompany extends StatefulWidget {
  const SelectCompany({Key? key, required this.onSelect,required this.selectedCompany}) : super(key: key);

  final String selectedCompany;
  final Function onSelect;

  @override
  State<SelectCompany> createState() => _SelectCompanyState();
}

class _SelectCompanyState extends State<SelectCompany> {

  final ProfileController _pController = Get.put(ProfileController());
  late Future<List<CompanyModel>?> companyFuture;

  Future<List<CompanyModel>?> _getCompanies() async {
    return await _pController.getAllCompany();
  }

 @override
  void initState() {
    super.initState();
    companyFuture = _getCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Select your registered company", style: Theme.of(context).textTheme.headlineSmall,),
        const SizedBox(height: 10.0,),

        Flexible(
          child: FutureBuilder<List<CompanyModel>?>(
            future: companyFuture,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                if(snapshot.hasData){

                  return ListView.builder(
                    itemBuilder: (ctx,i){
                      return ListTile(
                        onTap: () => widget.onSelect(snapshot.data![i].name),
                        title: Text(snapshot.data![i].name ?? ""),
                        trailing: widget.selectedCompany == snapshot.data![i].name ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.check, color: Colors.white, size: 15,),
                          ),
                        ) : const SizedBox.shrink(),
                      );
                    }, itemCount: snapshot.data!.length,shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }

              } else {
                return const Center(
                    child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}
