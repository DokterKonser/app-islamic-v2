sed -i "s/if (mounted) {/if (!mounted) return;/g" app_islamic_v2/lib/features/jumatan/ui/jumatan_screen.dart
sed -i "s/ScaffoldMessenger.of(context).showSnackBar(/ScaffoldMessenger.of(context).showSnackBar(/g" app_islamic_v2/lib/features/jumatan/ui/jumatan_screen.dart
