import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monaymanagment/core/constants/color_constants.dart';
import 'package:monaymanagment/core/constants/size_constatnts.dart';

class TextStyles {
  static bodyText({double? size, FontWeight? weight, Color? color}) {
      return GoogleFonts.poppins(color: color ?? ColorTheme.mainColor, fontSize: size ?? SizeConstants.font(4),fontWeight: weight ?? FontWeight.w900,);

      
    }
    static smallText({double? size, FontWeight? weight, Color? color}) {
      return GoogleFonts.poppins(color: color ?? ColorTheme.mainColor, fontSize: size ?? SizeConstants.font(3),fontWeight: weight ?? FontWeight.normal,);

      
    }
   static buttonText({double? size, FontWeight? weight, Color? color}) {
    return GoogleFonts.poppins(
         letterSpacing: 1.2,
      color: color ?? ColorTheme.mainColor2,
      fontSize: size ?? SizeConstants.font(4),
      fontWeight: weight ?? FontWeight.bold,
    );
  }
  } 