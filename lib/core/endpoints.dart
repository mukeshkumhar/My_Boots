class Endpoints {
  // Auth
  static const login = '/user/login'; // { email, passkey }
  static const register = '/user/register'; // { name, email, passkey }
  static const verify = '/user/verify-user';

  // Products (example)
  static const products = '/products';
  static String productById(String id) => '/products/$id';
}
