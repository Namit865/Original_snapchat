import 'package:flutter/material.dart';

class AttachmentTray extends StatelessWidget {
  const AttachmentTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          children: [
            AttachmentOption(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () {
                // Handle camera attachment
              },
            ),
            AttachmentOption(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () {
                // Handle gallery attachment
              },
            ),
            AttachmentOption(
              icon: Icons.file_copy,
              label: 'Documents',
              onTap: () {
                // Handle documents attachment
              },
            ),
            AttachmentOption(
              icon: Icons.location_pin,
              label: 'Location',
              onTap: () {
                // Handle location attachment
              },
            ),
            AttachmentOption(
              icon: Icons.contacts,
              label: 'Contact',
              onTap: () {
                // Handle contact attachment
              },
            ),
            AttachmentOption(
              icon: Icons.event,
              label: 'Event',
              onTap: () {
                // Handle event attachment
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double height;
  final double width;

  const AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.height = 80,
    this.width = 80,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
