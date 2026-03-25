import '../../data/models/question_model.dart';

class ResourceLink {
  const ResourceLink({required this.title, required this.url});

  final String title;
  final String url;
}

class InterviewResources {
  static const Map<QuestionCategory, List<ResourceLink>> byCategory =
      <QuestionCategory, List<ResourceLink>>{
    QuestionCategory.flutter: <ResourceLink>[
      ResourceLink(
        title: 'Flutter Interview Q&A',
        url: 'https://github.com/VincentJouanne/flutter-interview-questions',
      ),
      ResourceLink(
        title: 'Flutter Docs',
        url: 'https://docs.flutter.dev/',
      ),
      ResourceLink(
        title: 'Flutter Cookbook',
        url: 'https://docs.flutter.dev/cookbook',
      ),
    ],
    QuestionCategory.firebase: <ResourceLink>[
      ResourceLink(
        title: 'Firebase Docs',
        url: 'https://firebase.google.com/docs',
      ),
      ResourceLink(
        title: 'Firebase Auth',
        url: 'https://firebase.google.com/docs/auth',
      ),
      ResourceLink(
        title: 'Cloud Firestore',
        url: 'https://firebase.google.com/docs/firestore',
      ),
    ],
    QuestionCategory.dsa: <ResourceLink>[
      ResourceLink(
        title: 'NeetCode Roadmap',
        url: 'https://neetcode.io/roadmap',
      ),
      ResourceLink(
        title: 'LeetCode',
        url: 'https://leetcode.com/',
      ),
      ResourceLink(
        title: 'GeeksforGeeks DSA',
        url: 'https://www.geeksforgeeks.org/data-structures/',
      ),
    ],
    QuestionCategory.hr: <ResourceLink>[
      ResourceLink(
        title: 'Behavioral Qs Guide',
        url: 'https://www.themuse.com/advice/interview-questions-and-answers',
      ),
      ResourceLink(
        title: 'STAR Method',
        url: 'https://www.themuse.com/advice/star-interview-method',
      ),
      ResourceLink(
        title: 'Tell Me About Yourself',
        url: 'https://www.indeed.com/career-advice/interviewing/tell-me-about-yourself',
      ),
    ],
  };

  static const List<ResourceLink> general = <ResourceLink>[
    ResourceLink(
      title: 'Tech Interview Handbook',
      url: 'https://www.techinterviewhandbook.org/',
    ),
    ResourceLink(
      title: 'Pramp',
      url: 'https://www.pramp.com/',
    ),
    ResourceLink(
      title: 'Interviewing.io',
      url: 'https://interviewing.io/',
    ),
  ];
}
