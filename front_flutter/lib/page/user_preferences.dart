class UserPreferences {
  static const myUser = User(
    imagePath:
        'https://firebasestorage.googleapis.com/v0/b/flutter-4798c.appspot.com/o/test%2Fa7e3e9cf74673ec88fa38e35c7c3f5bc-sticker.png?alt=media&token=d8171b99-0ba2-4642-a421-b9396aaf529d',
    name: 'Sarah Abs',
    email: 'sarah.abs@gmail.com',
    about:
        'Certified Personal Trainer and Nutritionist with years of experience in creating effective diets and training plans focused on achieving individual customers goals in a smooth way.',
    isDarkMode: false,
  );
}

class User {
  final String imagePath;
  final String name;
  final String email;
  final String about;
  final bool isDarkMode;

  const User({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.about,
    required this.isDarkMode,
  });
}