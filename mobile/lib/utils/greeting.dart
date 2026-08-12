/// Time-of-day greeting — "Good Morning" before noon, "Good Afternoon"
/// before 5pm, "Good Evening" after. Shared so every home/dashboard
/// screen reflects the device's actual clock instead of a static string.
String timeBasedGreeting([DateTime? at]) {
  final hour = (at ?? DateTime.now()).hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}
