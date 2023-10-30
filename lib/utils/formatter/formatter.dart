import 'package:intl/intl.dart';

class MyOgaFormatter{
  static String dateFormatter(DateTime? date){
    date ??= DateTime.now();
    return DateFormat('dd-MM-yyyy hh:mm a').format(date);
  }

  static String currencyFormatter(double amount){
    return NumberFormat.currency(locale: 'en_NGN', symbol: '₦ ', decimalDigits: 0).format(amount);
  }

}