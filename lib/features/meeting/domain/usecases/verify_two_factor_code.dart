import '../repositories/auth_repository.dart';

class VerifyTwoFactorCode {
  final AuthRepository repository;
  const VerifyTwoFactorCode(this.repository);

  Future<bool> call(String code) => repository.verifyTwoFactorCode(code);
}