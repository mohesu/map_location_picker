import 'package:flutter/material.dart';

/// Creates a variable and subscribes to it.
///
/// Whenever [ValueNotifier.value] updates, it will mark the caller [StatelessWidget]
/// as needing a build.
/// On the first call, it initializes [ValueNotifier] to [initialData]. [initialData] is ignored
/// on subsequent calls.
///
/// The following example showcases a basic counter application:
///
/// ```dart
/// class Counter extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final counter = useState(0);
///
///     return GestureDetector(
///       // automatically triggers a rebuild of the Counter widget
///       onTap: () => counter.value++,
///       child: Text(counter.value.toString()),
///     );
///   }
/// }
/// ```
///
/// See also:
///
///  * [ValueNotifier]
ValueNotifier<T> useState<T>(T initialData) {
  return ValueNotifier<T>(initialData);
}
