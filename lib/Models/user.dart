class userData {
  String name;
  String email;
  String password;
  bool isLoading;

  userData({
    required this.name,
    required this.email,
    required this.password,
    this.isLoading =false,
  });
}
