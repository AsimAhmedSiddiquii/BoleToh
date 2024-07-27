import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptDecrypt {
  // Define a specific key and IV for consistency
  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows!');
  static final iv = encrypt.IV.fromUtf8('my16lengthiviviv');

  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptMessage(String plainMessageText) {
    final encrypted = encrypter.encrypt(plainMessageText, iv: iv);
    return encrypted.base64;
  }

  static String decryptMessage(String encryptedMessageText) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedMessageText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
