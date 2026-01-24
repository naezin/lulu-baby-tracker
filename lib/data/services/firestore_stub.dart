/// Firestore stub for web compatibility
/// This file provides minimal stubs for Firestore types when Firebase is disabled

class Timestamp {
  final DateTime _dateTime;

  Timestamp(this._dateTime);

  static Timestamp fromDate(DateTime dateTime) {
    return Timestamp(dateTime);
  }

  DateTime toDate() {
    return _dateTime;
  }
}

class FirebaseFirestore {
  static FirebaseFirestore get instance => FirebaseFirestore();

  CollectionReference collection(String path) => CollectionReference();
}

class CollectionReference {
  DocumentReference doc([String? id]) => DocumentReference();
  Future<DocumentReference> add(Map<String, dynamic> data) async => DocumentReference();
  Future<QuerySnapshot> get() async => QuerySnapshot();
  Query where(String field, {dynamic isEqualTo, dynamic isGreaterThan, dynamic isLessThan}) => Query();
  Query orderBy(String field, {bool descending = false}) => Query();
  Query limit(int count) => Query();
  Stream<QuerySnapshot> snapshots() => Stream.value(QuerySnapshot());
}

class DocumentReference {
  String get id => 'demo-id';
  Future<DocumentSnapshot> get() async => DocumentSnapshot();
  Future<void> set(Map<String, dynamic> data) async {}
  Future<void> update(Map<String, dynamic> data) async {}
  Future<void> delete() async {}
  CollectionReference collection(String path) => CollectionReference();
}

class DocumentSnapshot {
  bool get exists => false;
  String get id => '';
  Map<String, dynamic> data() => {};
}

class Query {
  DocumentReference doc([String? id]) => DocumentReference();
  Future<QuerySnapshot> get() async => QuerySnapshot();
  Query where(String field, {dynamic isEqualTo, dynamic isGreaterThan, dynamic isLessThan}) => this;
  Query orderBy(String field, {bool descending = false}) => this;
  Query limit(int count) => this;
  Stream<QuerySnapshot> snapshots() => Stream.value(QuerySnapshot());
}

class QuerySnapshot {
  List<QueryDocumentSnapshot> get docs => [];
}

class QueryDocumentSnapshot {
  String get id => '';
  Map<String, dynamic> data() => {};
}

class AdditionalUserInfo {
  final bool isNewUser;
  AdditionalUserInfo({this.isNewUser = false});
}

class User {
  final String? uid;
  final String? email;
  final String? displayName;

  User({this.uid, this.email, this.displayName});

  Future<void> delete() async {}
  Future<void> updateDisplayName(String? displayName) async {}
}

class UserCredential {
  final User? user;
  final AdditionalUserInfo? additionalUserInfo;
  UserCredential({this.user, this.additionalUserInfo});
}

class FirebaseAuth {
  static FirebaseAuth get instance => FirebaseAuth();

  User? get currentUser => null;

  Stream<User?> authStateChanges() => Stream.value(null);

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return UserCredential(user: User(uid: 'demo', email: email));
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return UserCredential(user: User(uid: 'demo', email: email), additionalUserInfo: AdditionalUserInfo(isNewUser: true));
  }

  Future<UserCredential> signInWithCredential(dynamic credential) async {
    return UserCredential(user: User(uid: 'demo'));
  }

  Future<UserCredential> signInWithProvider(dynamic provider) async {
    return UserCredential(user: User(uid: 'demo'));
  }

  Future<UserCredential> signInAnonymously() async {
    return UserCredential(user: User(uid: 'anonymous'));
  }

  Future<void> sendPasswordResetEmail({required String email}) async {}

  Future<void> signOut() async {}
}

class FirebaseAuthException implements Exception {
  final String code;
  final String? message;

  FirebaseAuthException({required this.code, this.message});

  @override
  String toString() => 'FirebaseAuthException($code): $message';
}

class GoogleSignInAccount {
  final String? email;
  final String? displayName;

  GoogleSignInAccount({this.email, this.displayName});

  Future<GoogleSignInAuthentication> get authentication async {
    return GoogleSignInAuthentication(accessToken: 'demo', idToken: 'demo');
  }
}

class GoogleSignInAuthentication {
  final String? accessToken;
  final String? idToken;

  GoogleSignInAuthentication({this.accessToken, this.idToken});
}

class GoogleSignIn {
  Future<GoogleSignInAccount?> signIn() async => null;
  Future<void> signOut() async {}
}

class GoogleAuthProvider {
  static dynamic credential({String? accessToken, String? idToken}) {
    return null;
  }
}

class AppleAuthProvider {
  AppleAuthProvider();

  void addScope(String scope) {}
}
