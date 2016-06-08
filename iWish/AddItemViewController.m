//
//  AddItemViewController.m
//  iWish
//
//  Created by Elena Maso Willen on 01/06/2016.
//  Copyright © 2016 Elena. All rights reserved.
//

#import "AddItemViewController.h"

#import <CoreData/CoreData.h>
#import "AppDelegate.h"

#import "Item.h"
#import "List.h"

@interface AddItemViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) AppDelegate *appDelegate;

@property (nonatomic) UITextView *activeField;
@property (nonatomic) UITextField *activeTextField;
@property (nonatomic) BOOL isValidUrl;
@property (nonatomic) UIEdgeInsets originalContentInsets;
@property (nonatomic) BOOL pictureTaken;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UITextView *itemDetailsTextView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;


- (IBAction)addPictureButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;


@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Item";
    
    self.pictureTaken = NO;
    
    [self.doneButton setEnabled:NO];
    
    [self.itemDetailsTextView setDelegate:self];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grTapped:)];
    [self.scrollView addGestureRecognizer:gr];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;

}

- (void) viewDidAppear:(BOOL)animated  {
    
    self.originalContentInsets = self.scrollView.contentInset;
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    BOOL rc = NO;
    [textField resignFirstResponder];
    rc = YES;
    return rc;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (textField == self.itemNameTextField) {
        if (self.itemNameTextField.text.length > 1 || (string.length > 0 && ![string isEqualToString:@""])) {
            [self.doneButton setEnabled:YES];
        } else {
            [self.doneButton setEnabled:NO];
        }
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if (textField == self.itemNameTextField) {
        [self.doneButton setEnabled:NO];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.urlTextField) {
        self.activeTextField = textField;
    }
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.urlTextField) {
        
        self.activeTextField = nil;
    }
    return YES;
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    self.activeField = textView;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    self.activeField = nil;

    [textView resignFirstResponder];
    return YES;
}

#pragma mark - UIImageControllerDelegate delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    self.pictureTaken = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.itemImageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - KeyBoard

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.originalContentInsets.top, self.originalContentInsets.left, self.originalContentInsets.bottom + kbSize.height , self.originalContentInsets.right);
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if ( CGRectGetMaxY(aRect) < CGRectGetMaxY(self.activeField.frame) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
    if (CGRectGetMaxY(aRect) < CGRectGetMaxY(self.activeTextField.frame)) {
        [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    self.scrollView.contentInset = self.originalContentInsets;
    self.scrollView.scrollIndicatorInsets = self.originalContentInsets;
    [self.scrollView scrollRectToVisible:CGRectZero animated:YES];
}

#pragma  mark - Private

- (NSString *)savePictureToDisk {
    
     if (self.itemImageView.image) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSUUID *uuid = [NSUUID UUID];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [uuid UUIDString]]];
        
        [UIImagePNGRepresentation(self.itemImageView.image) writeToFile:filePath atomically:YES];
        
        return filePath;
    }
    return nil;
}

- (void)grTapped:(id)sender {
    
    [self.scrollView endEditing:YES];
}

- (void)saveObject {
    
    NSError *error = nil;
    [self.appDelegate.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Core Data could not save: %@", [error localizedDescription]);
    }
}

- (BOOL) isValidUrl {
    
    self.isValidUrl = NO;
        NSURL* url = [NSURL URLWithString:self.urlTextField.text];
        if (url && url.scheme && url.host) {
            NSLog(@"YES %@ is a proper URL", self.urlTextField.text);
            self.isValidUrl = YES;
            return YES;
        } else {
            NSLog(@"Nope %@ is not a proper URL", self.urlTextField.text);
            self.isValidUrl = NO;
            return NO;
        }
    return self.isValidUrl;
}

- (void) showUrlAlert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Url Invalid" message:@"Please enter a valid url (https://...)" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Action handlers

- (IBAction)addPictureButtonPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (self.urlTextField.text.length >= 1) {

        [self isValidUrl];
    }
            
    if (self.isValidUrl || self.urlTextField.text.length == 0) {
        Item *anItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.appDelegate.managedObjectContext];
        anItem.name = self.itemNameTextField.text;
        anItem.details = self.itemDetailsTextView.text;
        anItem.url = self.urlTextField.text;
        long x = self.listSelected.items.count;
        anItem.position = [NSNumber numberWithLong:x];
                
        if (self.pictureTaken) {
            anItem.picture = [self savePictureToDisk];
        } else {
            anItem.picture = nil;
        }
        
        [self.listSelected addItemsObject:anItem];
    
        [self saveObject];
        [self dismissViewControllerAnimated:YES completion:nil];
            
    } else {
        [self showUrlAlert];
    }
}




@end









