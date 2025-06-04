// authstate
// class AuthLayout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: authService,
//       builder: (context, authService, child) {
//         return  StreamBuilder(stream: authService.authStateChanges, builder: (context, snapshot) {
//           Widget widget;
//           if(snapshot.connectionState == ConnectionState.waiting) {
//             widget = LoadingPage();
//           } else if(snapshot.hasData) {
//             widget = const HomePage();
//           } else {
//             widget = pageIsNotConnected ?? const GetStartedPage();
//           }
//         });  
//       },
//     );
//   }
// }

// logout
// void logout() async {
//   try {
//     await authService.value.signOut();
//   } on FirebaseAuthException catch(e) {
//     print(e.message);
//   }
// }

// resetPassworda


// update pass
// void updatePassword = () async {
//   try {
//     await authService.value.resetPasswordFromCurrentPass(currentPassword: currentPassContr, newPassword: newPassContr, email: email)
//   } on FirebaseAuthException catch (e) {
//     setState(() {
//       errorMessage = e.message;
//     })
//   }
// }

// void updateUsername() async {
//   try {
//     await authService.value.updateUsername(username: usernameController.text);
//   } on FirebaseAuthException catch(e) {
//     setState(() {
//       errorMesasage = e.message;
//     })
//   } 
// }

// void deleteAcc () async {
//   try {
//     await authService.value.deleteAccount(email: email, password: password)
//   }
// }