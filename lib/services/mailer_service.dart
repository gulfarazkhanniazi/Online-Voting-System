import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MailerService {
  static Future<String?> sendContactEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final smtpEmail = dotenv.env['SMTP_EMAIL'];
      final smtpPassword = dotenv.env['SMTP_PASSWORD'];

      if (smtpEmail == null || smtpPassword == null) {
        return 'SMTP credentials are missing';
      }

      final smtpServer = gmail(smtpEmail, smtpPassword);

      final mail =
          Message()
            ..from = Address(smtpEmail, 'Voting App')
            ..recipients.add(smtpEmail)
            ..subject = 'New Contact Form Message'
            ..text = '''
Name: $name
Email: $email
Message:
$message
        ''';

      await send(mail, smtpServer);
      return null;
    } catch (e) {
      return 'Failed to send message: $e';
    }
  }
}
