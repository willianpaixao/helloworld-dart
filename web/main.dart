import 'dart:html';

void main() {
  // Get references to the DOM elements
  final HeadingElement output = querySelector('#output') as HeadingElement;
  final ButtonElement button = querySelector('#clickButton') as ButtonElement;

  // Add click event listener to the button
  button.onClick.listen((event) {
    output.text = 'Hello Dart World!';

    // Change the text back after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      output.text = 'Hello World!';
    });
  });
}
