import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Setting Screen/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back(closeOverlays: true);
            },
            icon: const Icon(
              CupertinoIcons.back,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(
                transition: Transition.rightToLeftWithFade,
                const SettingPage(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserProfileHeader(),
            UserActions(),
            MyStories(),
            Countdowns(),
            FriendsSection(),
            CommunitiesSection(),
            SpotlightSection(),
            SnapMapSection(),
            CameosSection(),
          ],
        ),
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          child: Icon(
            Icons.person,
            size: 50,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'DEVIL 😈',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'senjaliyanaamit',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.snapchat,
              color: Colors.yellow,
            ),
            const Text(
              '165,968',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 80),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Join College'),
            ),
          ],
        ),
      ],
    );
  }
}

class UserActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.star, color: Colors.white),
            title: Text(
              'Try Snapchat+ for ₹41.58 / month',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'See what time your friends are viewing your Stories',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
          ListTile(
            leading: Icon(Icons.public, color: Colors.white),
            title: Text(
              'My Public Profile',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class MyStories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Stories',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.add, color: Colors.white),
            title:
                Text('Add to My Story', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.add, color: Colors.white),
            title:
                Text('Add to BFF Story', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class Countdowns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.timer, color: Colors.white),
        title: Text('Create a new Countdown!',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class FriendsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.person_add, color: Colors.white),
            title: Text('Add Friends', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.white),
            title: Text('My Friends', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CommunitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.school, color: Colors.white),
        title: Text('Add School', style: TextStyle(color: Colors.white)),
        subtitle: Text('Meet new friends and view your Community Story!',
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class SpotlightSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.highlight, color: Colors.white),
        title: Text('Add to Spotlight', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class SnapMapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Snap Map',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.map, color: Colors.white),
            title: Text('Tap to explore Snap Map',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CameosSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cameos',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.face, color: Colors.white),
            title: Text('Create Cameos Selfie',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
