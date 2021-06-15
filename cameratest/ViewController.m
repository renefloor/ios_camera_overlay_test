//
//  ViewController.m
//  cameratest
//
//  Created by Rene Floor on 10/06/2021.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController

UIImagePickerController *_imagePickerController;
UIImagePickerControllerCameraDevice _device;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIViewController *)viewControllerWithWindow:(UIWindow *)window {
  UIWindow *windowToUse = window;
  if (windowToUse == nil) {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
      if (window.isKeyWindow) {
        windowToUse = window;
        break;
      }
    }
  }

  UIViewController *topController = windowToUse.rootViewController;
  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }
  return topController;
}

- (IBAction)openCamera:(id)sender {
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.delegate = self;
    _imagePickerController.mediaTypes = @[ (NSString *)kUTTypeImage ];


    _device = UIImagePickerControllerCameraDeviceRear;
    [self checkCameraAuthorization];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    printf("touched");
}

- (IBAction)logTap:(id)sender {
    printf("Button tapped\n");
}

- (void)checkCameraAuthorization {
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

  switch (status) {
    case AVAuthorizationStatusAuthorized:
      [self showCamera];
      break;
    case AVAuthorizationStatusNotDetermined: {
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                               completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                   if (granted) {
                                     [self showCamera];
                                   } else {
                                     [self errorNoCameraAccess:AVAuthorizationStatusDenied];
                                   }
                                 });
                               }];
      break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
    default:
      [self errorNoCameraAccess:status];
      break;
  }
}

- (void) showCamera {
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePickerController.cameraDevice = _device;
    [[self viewControllerWithWindow:nil] presentViewController:_imagePickerController
                                                      animated:YES
                                                    completion:nil];
}

- (void)errorNoCameraAccess:(AVAuthorizationStatus)status {
  switch (status) {
    case AVAuthorizationStatusRestricted:
      printf("The user is not allowed to use the camera.");
      break;
    case AVAuthorizationStatusDenied:
    default:
      printf("The user did not allow camera access.");
      break;
  }
}


@end
                              
