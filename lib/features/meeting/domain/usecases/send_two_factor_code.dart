import '../repositories/auth_repository.dart';

class SendTwoFactorCode {
  final AuthRepository repository;
  const SendTwoFactorCode(this.repository);

  Future<void> call() => repository.sendTwoFactorCode();
}