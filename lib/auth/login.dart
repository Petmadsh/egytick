import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:egytick/components/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/custombuttonauth.dart';
import '../components/customlogoauth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser==null){
      return;
    }





    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context).pushNamedAndRemoveUntil("homepage", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Form(
              key: formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                  ),
                  CustomLogoAuth(),
                  Container(
                    height: 20,
                  ),
                  Text("Login",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  Container(
                    height: 10,
                  ),
                  Text(
                    "Login to continue using the app",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    height: 10,
                  ),
                  CustomTextFormField(
                    hinttext: "Enter Your Email",
                    mycontroller: email,
                    validator: (val) {
                      if (val == "") {
                        return "Can't be empty";
                      }
                    }
                  ),
                  Container(
                    height: 10,
                  ),
                  Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    height: 10,
                  ),
                  CustomTextFormField(
                      hinttext: "Enter Your Password",
                      mycontroller: password,
                      validator: (val) {
                        if (val == "") {
                          return "Can't be empty";
                        }

                      }, isPassword: true,),


                     Container(
                      margin: EdgeInsets.only(top: 15, bottom: 30),
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () async{

                          if (email.text==""){
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Please enter your Email',
                            )..show();

                            return;
                          }

                          final String useremail = email.text;

                          try{
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Success',
                              desc: 'Password reset Email sent to $useremail',
                            )..show();


                          }catch(e){
                            AwesomeDialog(
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error',
                                desc: '$useremail is not a valid Email address. Please check it and try again'
                            )..show();
                          }



                        },
                        child: Text(
                          "Forget password ?",
                          style: TextStyle(fontSize: 15,),
                        ),
                      ),
                    ),

                ],
              ),
            ),
            CustomButtonAuth(
              title: "Login",
              onPressed: () async {
                if (formState.currentState!.validate()) {
                  try {
                    final credential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email.text,
                      password: password.text,
                    );
                    if (credential.user!.emailVerified) {
                      Navigator.of(context).pushReplacementNamed("homepage");
                    } else {
                      FirebaseAuth.instance.currentUser!
                          .sendEmailVerification();

                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'Please verify your Email',
                      )..show();
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'No user found for that email.',
                      )..show();
                    } else if (e.code == 'wrong-password') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: 'Wrong password provided for that user.',
                      )..show();
                    }
                  }
                } else
                  print("Not Valid");
              },
            ),
            Container(
              height: 30,
            ),
            MaterialButton(
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () {
                signInWithGoogle();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Or Login with Google"),
                  Image.asset(
                    "images/Google_Logo.png",
                    width: 40,
                  )
                ],
              ),
              //
            ),
            Container(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 15),
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed("signup");
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xffbd75329),
                          fontWeight: FontWeight.bold),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
