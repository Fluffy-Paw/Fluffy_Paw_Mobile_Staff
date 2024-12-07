import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
 final FirebaseAuth _auth = FirebaseAuth.instance;
 String? verificationId;

 Future<Map<String, dynamic>> verifyPhoneNumber(String phoneNumber) async {
   final completer = Completer<Map<String, dynamic>>();
   
   try {
     await _auth.verifyPhoneNumber(
       phoneNumber: phoneNumber,
       verificationCompleted: (PhoneAuthCredential credential) async {
         await _auth.signInWithCredential(credential);
         completer.complete({
           'success': true,
           'message': 'Auto verification completed' 
         });
       },
       verificationFailed: (FirebaseAuthException e) {
         completer.complete({
           'success': false,
           'message': e.message ?? 'Verification failed'
         });
       },
       codeSent: (String vId, int? resendToken) {
         verificationId = vId;
         completer.complete({
           'success': true,
           'message': 'OTP sent successfully'
         });
       },
       codeAutoRetrievalTimeout: (String vId) {
         verificationId = vId;
         if (!completer.isCompleted) {
           completer.complete({
             'success': false, 
             'message': 'Code auto retrieval timeout'
           });
         }
       },
       timeout: const Duration(seconds: 60),
     );
     
     return completer.future;
     
   } catch (e) {
     return {
       'success': false,
       'message': e.toString()
     };
   }
 }

 Future<Map<String, dynamic>> verifyOTP(String otp) async {
   try {
     if (verificationId == null) {
       return {
         'success': false,
         'message': 'Verification ID not found'
       };
     }

     final credential = PhoneAuthProvider.credential(
       verificationId: verificationId!,
       smsCode: otp,
     );

     final userCredential = await _auth.signInWithCredential(credential);
     final idToken = await userCredential.user?.getIdToken();

     return {
       'success': true,
       'message': 'OTP verified successfully',
       'token': idToken,
     };
   } on FirebaseAuthException catch (e) {
     return {
       'success': false,
       'message': e.message ?? 'Invalid OTP'
     };
   }
 }

 Future<void> signOut() async {
   await _auth.signOut();
 }
}

final firebaseAuthService = FirebaseAuthService();