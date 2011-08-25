Objectives:
x 1st: Able to replace an image in an array with another image
x 2nd: Able to replace an image in an array with another image from _photo library_
x 3rd: Able to replace an image in an array with another image from _photo library & camera"
x 4th: Create a class which takes a pointer to a NSMutable array, then this class is able to use the photo library or camera to replace the photo in the NSMutable array.

25/8
-ImageReplacer is able to replace a particular image in a NSMutable array. It has to be initialized with the pointer to the NSMutableArray and the specific index of the image.ImageReplacer also a interface (expected to be refined).
-Bug: When a photo is chosen from the photo library, the entire view is closed and return to the parent view. This does not happen when taking a photo from the camera.
-Bug: Loading of camera is slow, review codes.