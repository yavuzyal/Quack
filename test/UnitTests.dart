import 'package:cs308_project/screens/LoginScreen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:email_validator/email_validator.dart';

bool taxIDValidator(String tax)
{
  if (tax.isEmpty) {
    return false;
  }
  else if (int.tryParse(tax) == null || tax[0] == '0' || tax.length != 11)
  {
    return false;
  }
  return true;
}

void main() {
  group('Password Validation', () {
    test('Empty password', () {
      expect(
          validatePassword(""),
          false);
    });

    test('Not at least length of 8', () {
      expect(
          validatePassword("Cs308"),
          false);
    });

    test('No number', () {
      expect(
          validatePassword("Csucyuzsekiz"),
          false);
    });

    test('No uppercase character', () {
      expect(
          validatePassword("csucyuz888"),
          false);
    });

    test('No lowercase character', () {
      expect(
          validatePassword("CSUCYUZ888"),
          false);
    });

    test('Valid password', () {
      expect(
          validatePassword("CsUcYuzSekiz8"),
          true);
    });
  });

  group('Email Validation', () {
    test('Empty email', () {
      expect(
          EmailValidator.validate(""),
          false);
    });

    test('No @ character', () {
      expect(
          EmailValidator.validate("cs308sabanciuniv.edu"),
          false);
    });

    test('No domain name', () {
      expect(
          EmailValidator.validate("cs308@"),
          false);
    });

    test('No email identifier', () {
      expect(
          EmailValidator.validate("@sabanciuniv.edu"),
          false);
    });

    test('Valid email', () {
      expect(
          EmailValidator.validate("cs308@sabanciuniv.edu"),
          true);
    });

    test('Valid email random domain', () {
      expect(
          EmailValidator.validate("cs308@example.com"),
          true);
    });
  });

  group('Tax ID Validation', () {
    test('Empty tax id', () {
      expect(
          taxIDValidator(""),
          false);
    });

    test('Alphabetic tax id', () {
      expect(
          taxIDValidator("aaaaaaaaaaa"),
          false);
    });

    test('Alphanumeric tax id', () {
      expect(
          taxIDValidator("a2a2a2a2a2a"),
          false);
    });

    test('Short and alphanumeric tax id', () {
      expect(
          taxIDValidator("a2a2"),
          false);
    });

    test('Short but numeric tax id', () {
      expect(
          taxIDValidator("123"),
          false);
    });

    test('Long but numeric tax id', () {
      expect(
          taxIDValidator("123123123123123"),
          false);
    });

    test('Id starting with 0', () {
      expect(
          taxIDValidator("011111111111"),
          false);
    });

    test('Valid tax ID 1', () {
      expect(
          taxIDValidator("11111111111"),
          true);
    });

    test('Valid tax ID 2', () {
      expect(
          taxIDValidator("45312376531"),
          true);
    });
  });

}