import 'package:flutter/material.dart';
import '../../../core/widgets/app_back_button.dart';

const teamBrown = Color(0xFF45180D),
    teamSoft = Color(0xFFF6EAE5),
    teamMuted = Color(0xFF795C52),
    teamLine = Color(0xFFEADDD7);

class TeamHeader extends StatelessWidget implements PreferredSizeWidget {
  TeamHeader({
    required BuildContext context,
    super.key,
    required this.title,
    required this.eyebrow,
    this.enabled = true,
  }) : preferredSize = Size.fromHeight(_headerHeight(context, title, eyebrow));
  final String title, eyebrow;
  final bool enabled;
  @override
  final Size preferredSize;
  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 18),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: teamSoft,
              ),
              child: AppBackButton(enabled: enabled),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFC51D2A),
                    fontSize: 9,
                    height: 1.2,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 27,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class TeamFooter extends StatelessWidget {
  const TeamFooter({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: teamLine)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: TeamButtonTheme(child: child),
      ),
    ),
  );
}

class TeamButtonTheme extends StatelessWidget {
  const TeamButtonTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => FilledButtonTheme(
    data: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teamBrown,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 49),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    child: child,
  );
}

class TeamCallout extends StatelessWidget {
  const TeamCallout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: teamSoft,
      borderRadius: BorderRadius.circular(12),
    ),
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 12, color: teamMuted, height: 1.6),
      child: child,
    ),
  );
}

double _headerHeight(BuildContext context, String title, String eyebrow) {
  final width = MediaQuery.sizeOf(context).width - 92;
  double measure(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    return painter.height;
  }

  final content =
      measure(
        title,
        const TextStyle(
          fontFamily: 'serif',
          fontSize: 27,
          height: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ) +
      4 +
      measure(
        eyebrow.toUpperCase(),
        const TextStyle(fontSize: 9, height: 1.2, letterSpacing: 1.4),
      );
  return 33 + (content < 40 ? 40 : content);
}
