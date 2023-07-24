//
//  Constants.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 17.07.23.
//

import Foundation

struct Constants {
    
    struct Alert {
        struct Titles {
            static let errorLogin = "Could not Log In"
            static let errorResetPassword = "Could not Reset Password"
            static let errorDeleteUser = "Could not Delete User"
            static let errorCreateUser = "Could not Create User"
            static let successCreateUser = "User created successfully"
            static let success = "Success"
        }
        
        struct Messages {
            static let invalidEmail = "This does not look like a valid email. Check and try again."
            static let successResetPassword = "Password reset email sent successfully."
            static let successCreateUser = "Please check your email inbox. We've sent a verification link to your email address. You need to click this link to verify your email and complete the registration process. If you can't find the email, please check your spam or junk folder. Thank you for your understanding."
            static let verifyEmail = "Please verify your email before logging in."
            static let successLogin = "Login successful."
            static let successDeleteUser = "User deleted successfully."
            static let noUser = "No current user."
        }
    }
    
    struct ButtonTitles {
        static let okTitle = "Ok"
        static let login = "Log In"
        static let logOut = "Log Out"
        static let forgotPassword = "Forgot Password?"
        static let createAccount = "Create Account"
        static let resetPassword = "Reset Password"
    }
    
    struct MainScreen {
        static let title = "Authorization"
    }
    
    struct LoginScreen {
        static let title = "Log In"
        static let emailPlaceholder = "Email"
        static let passwordPlaceholder = "Password"
    }
    
    struct CreateAccountScreen {
        static let title = "New Account"
    }
    
    struct ResetPasswordScreen {
        static let title = "Reset Password"
    }
    
    struct HomeScreen {
        static let title = "Home"
    }
}
