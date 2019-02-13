import 'dart:html';
import 'dart:core';
import 'dart:math';
import 'Starship.dart';
import 'Room.dart';
import 'dart:svg';

abstract class Display {
  int getMaxValue();//maximum value the display can show
  int getValue(); //current value displayed by Display
  SvgSvgElement graphicalDisplay();

}

class NixieTube implements Display {
  int value;
  int maxValue;
  final int WIDTH_CONSTANT = 30;
  final int HEIGHT_CONSTANT = 51;

  NixieTube(int value, int maxValue) {
    this.value = value;
    this.maxValue = maxValue;
  }

  @override
  int getMaxValue() {
    return maxValue;
  }

  @override
  int getValue() {
    return value;
  }

  @override
  SvgSvgElement graphicalDisplay() {

    SvgSvgElement ret = new SvgSvgElement();

    //setup for glowing
    DefsElement defs = new DefsElement();
    FilterElement glowFilter = new FilterElement();
    glowFilter.id = "glow";

    FEGaussianBlurElement blurElement = new FEGaussianBlurElement();
    blurElement.setAttribute("stdDeviation", "3");

    glowFilter.append(blurElement);
    defs.append(glowFilter);

    FilterElement transparencyFilter = new FilterElement();
    transparencyFilter.id = "transparent";

    FEColorMatrixElement matrixElement = new FEColorMatrixElement();
    matrixElement.setAttribute("values",
        "1 0 0 0 0 "
        "0 1 0 0 0 "
        "0 0 1 0 0 "
        "0 0 0 0.5 0 ");
    transparencyFilter.append(matrixElement);
    defs.append(transparencyFilter);

    ret.append(defs);


    //determine width by how many digits
    int width = getNumOfDigits(maxValue) * WIDTH_CONSTANT;

    ret.setAttribute("width", width.toString());
    ret.setAttribute("height", HEIGHT_CONSTANT.toString());

    /*
    //draw  display cells
    for(int i = 0; i <= 9; i++) {

      for(int j = 0; j < getNumOfDigits(maxValue) - 1; j++) {
        TextElement tex = unlitSegment(i);

        tex.setAttribute("x", "${j * WIDTH_CONSTANT}");
        tex.setAttribute("y", "${HEIGHT_CONSTANT - 10}");

        ret.append(tex);
      }

    }





    //draw lit display cells
    for(int i = getNumOfDigits(value) - 1; i  >= 0; i--) {
      TextElement tex = new TextElement();
      tex.setAttribute("textLength", "${WIDTH_CONSTANT}");
      tex.setAttribute("fill", "#FF9900");
      tex.setAttribute("font-size", "45");
      tex.setAttribute("font-family", "'Nixie One', monospace");
      tex.style.textAlign = "center";
      tex.setAttribute("filter", "url(#glow)");

      tex.setAttribute("x", "${WIDTH_CONSTANT * i}");

      tex.setAttribute("y", "${HEIGHT_CONSTANT - 10}");
      if(i + 1 == getNumOfDigits(value)) {
        tex.text = "${value.toString().substring(i)}";
      } else {
        tex.text = "${value.toString().substring(i, i+1)}";
      }

      //make it glow


      ret.append(tex);
    }
    */
    //draw display cells
    // 6 7 5 8 4 3 9 2 0 1 from front (6) to back (1)
    List<int> segmentsInOrder = [1, 0, 2, 9, 3, 4, 8, 5, 7, 6];
    //print(getNumOfDigits(value));
    for(int i = 0; i < getNumOfDigits(maxValue); i++) {

      int digit = -1; //not a digit, so if the below conditions aren't met no segment will be lit
      if(getNumOfDigits(maxValue) - i > getNumOfDigits(maxValue) - getNumOfDigits(value)) {
        //print("${getNumOfDigits(maxValue)} - $i > ${getNumOfDigits(maxValue)} - ${getNumOfDigits(value)}");
        digit = int.parse(value.toString().substring(i, i + 1));
        //print(digit);
      }else if(getNumOfDigits(maxValue) - i == getNumOfDigits(maxValue) - getNumOfDigits(value) && getNumOfDigits(value) != 1){
        //print("${getNumOfDigits(maxValue)} - $i == ${getNumOfDigits(maxValue)} - ${getNumOfDigits(value)}");
        if(value == 0) {
          digit = 0;
        } else {
          digit = int.parse(value.toString().substring(0));
        }
        //print(digit);
      }

      for(int j = 0; j <= 9; j++) {
        TextElement tex;

        if(digit == segmentsInOrder[j]) {
          TextElement tube = litSegment(segmentsInOrder[j]);
          tube.setAttribute("x", "${i * WIDTH_CONSTANT}");
          tube.setAttribute("y", "${HEIGHT_CONSTANT - 10}");
          ret.append(tube);

          tex = glowSegment(segmentsInOrder[j]);
          tex.setAttribute("x", "${i * WIDTH_CONSTANT}");
          tex.setAttribute("y", "${HEIGHT_CONSTANT - 10}");
          ret.append(tex);
        } else {
          tex = unlitSegment(segmentsInOrder[j]);

          tex.setAttribute("x", "${i * WIDTH_CONSTANT}");
          tex.setAttribute("y", "${HEIGHT_CONSTANT - 10}");
          ret.append(tex);
        }




      }

    }






    return ret;

  }

  int getNumOfDigits(int number) {
    if(number ~/ 10 > 0) {
      int ret = number ~/ 10;
      return 1 + getNumOfDigits(ret);
    }
    return 1;
  }

  TextElement unlitSegment(int number) {
    TextElement tex = new TextElement();
    tex.setAttribute("textLength", "$WIDTH_CONSTANT");
    tex.setAttribute("fill", "#555555");
    tex.setAttribute("font-size", "45");
    tex.setAttribute("font-family", "'Nixie One', monospace");
    tex.style.textAlign = "center";
    tex.setAttribute("filter", "url(#transparent)");
    tex.text = number.toString();

    return tex;
  }

  TextElement glowSegment(int number) {
    TextElement tex = new TextElement();
    tex.setAttribute("textLength", "${WIDTH_CONSTANT}");
    tex.setAttribute("fill", "#FF9900");
    tex.setAttribute("font-size", "45");
    tex.setAttribute("font-family", "'Nixie One', monospace");
    tex.style.textAlign = "center";
    tex.setAttribute("filter", "url(#glow)");

    tex.text = number.toString();
    return tex;
  }

  TextElement litSegment(int number) {
    TextElement tex = new TextElement();
    tex.setAttribute("textLength", "${WIDTH_CONSTANT}");
    tex.setAttribute("fill", "#FFBB44");
    tex.setAttribute("font-size", "45");
    tex.setAttribute("font-family", "'Nixie One', monospace");
    tex.style.textAlign = "center";


    tex.text = number.toString();
    return tex;
  }

}

class AnalogueGague implements Display {
  int value;
  int maxValue;
  bool needle;
  bool bar;

  AnalogueGague(int value, int maxValue, bool needle, bool bar) {
    this.value = value;
    this.maxValue = maxValue;
    this.needle = needle;
    this.bar = bar;
  }

  @override
  int getMaxValue(){
    return maxValue;
  }

  @override
  int getValue(){
    return value;
  }


  @override
  SvgSvgElement graphicalDisplay(){
    SvgSvgElement ret = new SvgSvgElement();
    ret.setAttribute("width", "150");
    ret.setAttribute("height", "75");

    double stopX = 75 *(1 - cos(PI * value/maxValue));
    double stopY = 75* (1 - sin(PI * value/maxValue));


    if(bar) {
      PathElement barDisp = new PathElement();
      barDisp.setAttribute("d", "M 0 75"
          " A 75 75 0 0 1 $stopX $stopY");
      barDisp.setAttribute("fill", "transparent");
      barDisp.setAttribute("stroke", "green");
      ret.append(barDisp);
    }
    if(needle) {
      PathElement needleDisp = new PathElement();
      needleDisp.setAttribute("d", "M 75 75 L $stopX $stopY");
      needleDisp.setAttribute("stroke", "red");
      ret.append(needleDisp);
    }
    print("($stopX, $stopY)");
    return ret;

  }
}