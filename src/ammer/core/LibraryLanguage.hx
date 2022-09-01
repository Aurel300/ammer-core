package ammer.core;

@:using(ammer.core.LibraryLanguage.LibraryLanguageTools)
enum LibraryLanguage {
  C;
  Cpp;
  ObjectiveC;
  ObjectiveCpp;
}

class LibraryLanguageTools {
  public static function extension(lang:LibraryLanguage):String {
    return (switch (lang) {
      case C: "c";
      case Cpp: "cpp";
      case ObjectiveC: "m";
      case ObjectiveCpp: "mm";
    });
  }

  public static function extensionHeader(lang:LibraryLanguage):String {
    return (switch (lang) {
      case C: "h";
      case Cpp: "hpp";
      case ObjectiveC: "h";
      case ObjectiveCpp: "hpp"; // TODO: is this correct?
    });
  }
}
