import 'package:google_sign_in/google_sign_in.dart';
import '../app_drive_api/v3.dart' as drive;
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  static int signInAttempts = 0;

  static Future<Map<String, String>> signIn(GoogleSignInAccount gsa,
      GoogleSignInAuthentication auth, FirebaseUser user) async {
    //_googleSignIn.signIn().then((account) {
//        _googleSignInAccount = account;
//        _googleSignInAccount.authentication.then((gsa) {
//          _googleSignInAccount.authHeaders.then((headers) {
//            authHeaders = headers;

    Map<String, String> headers;
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    GoogleSignIn gsi = GoogleSignIn(scopes: <String>[
      drive.DriveApi.DriveAppdataScope,
      drive.DriveApi.DriveFileScope
    ]);
    gsi.signIn().then((account) async {
      gsa = account;
//      gsa.authentication.then((auth) async {
//        user = await firebaseAuth.signInWithGoogle(
//            idToken: auth.idToken, accessToken: auth.accessToken);
//      });
      headers = await gsa.authHeaders;
    });

    //final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//    try {
//      user = await firebaseAuth.signInWithGoogle(
//          idToken: auth.idToken, accessToken: auth.accessToken);
//    } on Exception catch (e) {
//      print(e.toString());
//    }
    return headers;
  }

  static Future<Null> signOut(GoogleSignInAccount gsa, FirebaseUser user) {
    gsa.clearAuthCache();
    user = null;
    return null;
  }
}
