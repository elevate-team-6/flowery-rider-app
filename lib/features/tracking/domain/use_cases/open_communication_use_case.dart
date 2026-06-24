import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

enum CommunicationType { phone, whatsapp }

@injectable
class OpenCommunicationUseCase {
  Future<bool> call(String phone, CommunicationType type) async {
    Uri uri;
    if (type == CommunicationType.phone) {
      uri = Uri.parse('tel:$phone');
    } else {
      // WhatsApp format: https://wa.me/<number>
      // Remove any non-digit characters except for a leading plus
      String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
      uri = Uri.parse('https://wa.me/$cleanPhone');
    }

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      return false;
    }
  }
}
