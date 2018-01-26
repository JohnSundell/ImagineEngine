# Xcode Templates

In this folder you can find Xcode templates that can be installed to enable you to easily create new Imagine Engine-powered game projects.

Currently there's only a template for iOS, but pull requests adding templates for macOS & tvOS as well are more than welcome 👍.

## Installing the templates

Clone Imagine Engine (if you haven't done so already):

```
$ git clone https://github.com/JohnSundell/ImagineEngine.git
```

Then, copy the `Imagine Engine` folder located in `XcodeTemplates` to `~/Library/Developer/Xcode/Templates/` (you may need to create the `Templates` folder).

Done! 👌

## Using the templates

- Open Xcode and select `New > Project...`.
- Under the "iOS" tab, scroll down to the "Imagine Engine" section and select "iOS Game".
- Enter a name for your game and make sure to select "Swift" as language.
- Xcode will now create a project for you. Close the project and go to the project's folder on the command line.
- Run `pod install`. This will install Imagine Engine through [CocoaPods](https://cocoapods.org).
- Open the generated Xcode workspace and start building your game! 🚀