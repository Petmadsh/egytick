import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:egytick/components/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/custombuttonauth.dart';
import '../components/customlogoauth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();


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
                  Text("Register",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  Container(
                    height: 10,
                  ),
                  Text(
                    "Registre to continue using the app",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                  Container(
                    height: 20,
                  ),
                  Text(
                    "Username",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    height: 10,
                  ),
                  CustomTextFormField(
                      hinttext: "Enter Your Username", mycontroller: username, validator: (val) {
                    if(val == ""){
                      return "Can't be empty";
                    }
                  }),
                  Container(
                    height: 10,
                  ),
                  Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    height: 10,
                  ),
                  CustomTextFormField(
                      hinttext: "Enter Your Email", mycontroller: email, validator: (val) {
                    if(val == ""){
                      return "Can't be empty";
                    }
                  }),
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
                      hinttext: "Enter Your Password", mycontroller: password, validator: (val) {
                    if(val == ""){
                      return "Can't be empty";
                    }
                  }, isPassword: true,),
                  Container(
                    height: 10,
                  ),



                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 30),
                  ),
                ],
              ),
            ),
            CustomButtonAuth(
              title: "Register",
              onPressed: () async {
            if (formState.currentState!.validate()){
              try {
                final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email.text,
                  password: password.text,
                );
                FirebaseAuth.instance.currentUser!.sendEmailVerification();
                Navigator.of(context).pushReplacementNamed("login");
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: 'The password provided is too weak.',

                  )..show();
                } else if (e.code == 'email-already-in-use') {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: 'The account already exists for that email.',

                  )..show();
                }
              } catch (e) {
                print(e);
              }
            }
              },
            ),
            Container(
              height: 30,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(fontSize: 15),
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed("login");
                    },
                    child: Text(
                      "Login",
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
