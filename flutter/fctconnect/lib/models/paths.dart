class Paths {
  static String login = '/login';

  static String signUp = '/signUp';

  static String homePage = '/';

  static String myProfile = '/profile';

  static String noticias= '/news';

    static String noticia= '/:id';
  static String otherProfile = '/otherProfile';

  static String mapas = '/mapas';

  static String post = '/post';

  static String events = '/events';

  static String report = '/report';

  static String reportedPosts =  '/reportPosts';

  static String listReports = "${Paths.report}/list";

  static String editProfile  = '$myProfile/edit';

  static String calendar = '/calendar';

  static String event = '/event';

  static String createEvent = '$events/newEvent';

  static var splash = '/splash';

  static String welcome = '/welcome';

  static String createPost = '$post/create';

  static String nucleos = '/nucleos';

  static String criarNucleo = '$nucleos/create';

  static String pomodoro = '/pomodoro';

}