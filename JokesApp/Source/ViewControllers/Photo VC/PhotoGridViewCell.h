//
//  PhotoGridViewCell.h
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"

@interface PhotoGridViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *  imvPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *  imvFail;
@property (weak, nonatomic) IBOutlet UILabel *      txtRate;
@property (weak, nonatomic) IBOutlet UIView *       viewBorder;

@property (nonatomic, retain) id <MWPhoto>          photo;
@property (nonatomic, assign) NSUInteger            index;

@end
