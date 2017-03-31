//
//  ViewController.m
//  XYAsynchronousManager Demo
//
//  Created by xuyang on 2017/3/29.
//  Copyright © 2017年 SeanXuCn. All rights reserved.
//

#import "ViewController.h"
#import "XYAsynchronizationManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *groupOneView;
@property (weak, nonatomic) IBOutlet UIView *groupTwoView;
@property (weak, nonatomic) IBOutlet UIView *groupThreeView;

@property (weak, nonatomic) IBOutlet UILabel *groupOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupThreeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupOneHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupTwoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupThreeHeight;


@property (nonatomic, copy) NSArray *imageViewsArray;
@property (nonatomic, strong) NSArray *listSourceArray;

//isRunning只是为了Demo演示的时候将各项演示区分开,当你实际使用时完全无需添加这个变量
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 40.f;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - actions

- (void)OneGroupConcurrence{
    if (self.isRunning) return;
    self.isRunning = YES;
    
    //1、设置总并发数量，并给这组并发设置一个唯一id
    [[XYAsynchronizationManager sharedManager] xy_synchronizeWithIdentifier:@"oneGroup" totalCount:self.imageViewsArray.count doneBlock:^{
        XYAM_Log(@"oneGroup Tasks Done!");
        
        self.isRunning = NO;
    }];
    
    [self.imageViewsArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //开启异步线程
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self randomSleep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageViewsArray[idx] setImage:[UIImage imageNamed:@"ditou"]];
                XYAM_Log(@"oneGroup Task %lu executed", (unsigned long)idx);
                
                /*
                 2、当你完成一步操作的时候，告知manager你完成了一步操作，你可以完全不考虑当前是在什么线程内，只需要直接调用即可。
                 这个demo是因为需要在主线程给imageView设置图片，所以才特意回到主线程中执行的。
                 */
                [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"oneGroup"];
            });
            
        });
    }];
}

- (void)TwoGroupConcurrence{
    if (self.isRunning) return;
    self.isRunning = YES;
    //1、设置第一组总并发数量，并给这组并发设置一个唯一id
    [[XYAsynchronizationManager sharedManager] xy_synchronizeWithIdentifier:@"groupOne" totalCount:6 doneBlock:^{
        XYAM_Log(@"groupOne Tasks Done!");
        
        self.isRunning = NO;
    }];
    
    //2、设置第二组总并发数量，并给这组并发设置一个唯一id
    [[XYAsynchronizationManager sharedManager] xy_synchronizeWithIdentifier:@"groupTwo" totalCount:3 doneBlock:^{
        XYAM_Log(@"groupTwo Tasks Done!");
        
        self.isRunning = NO;
    }];
    
    //3、开始第一组任务
    for (int i = 0; i < 6; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self randomSleep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageViewsArray[i] setImage:[UIImage imageNamed:@"ditou"]];
                XYAM_Log(@"groupOne Task %d executed", i);
                
                /*
                 2、当你完成一步操作的时候，告知manager你完成了一步操作，你可以完全不考虑当前是在什么线程内，只需要直接调用即可。
                 这个demo是因为需要在主线程给imageView设置图片，所以才特意回到主线程中执行的。
                 */
                [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"groupOne"];
            });
        });
    }
    
    //4、开始第二组任务
    for (int i = 6; i < 9; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self randomSleep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageViewsArray[i] setImage:[UIImage imageNamed:@"ditou"]];
                XYAM_Log(@"groupTwo Task %d executed", i);
                
                /*
                 2、当你完成一步操作的时候，告知manager你完成了一步操作，你可以完全不考虑当前是在什么线程内，只需要直接调用即可。
                 这个demo是因为需要在主线程给imageView设置图片，所以才特意回到主线程中执行的。
                 */
                [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"groupTwo"];
            });
        });
    }
    
    /**
     本例中：1、2、3、4的顺序也可以改成1、3、2、4或者是其他组合。
     只要保证先使用id和数量创建同步管理器(synchronizer)，再开始执行就没问题。
     */
}

- (void)ThreeGroupsConcurrenceAndDependence{
    if (self.isRunning) return;
    self.isRunning = YES;
    
    /** 1、设置第三组总并发数量，并给这组并发设置一个唯一id
     *  这个组里只有两个步骤，第一个步骤是第一组完成，第二个步骤是第二组完成。
     */
    [[XYAsynchronizationManager sharedManager] xy_synchronizeWithIdentifier:@"groupThree" totalCount:2 doneBlock:^{
        
        //组1和组2都完成了
        XYAM_Log(@"groupThree Tasks Done!");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.groupThreeLabel.hidden = NO;
            self.groupThreeView.hidden = NO;
            [self.bottomView layoutIfNeeded];
            [UIView animateWithDuration:0.25f animations:^{
                self.groupThreeHeight.constant = self.bottomView.frame.size.height;
                [self.bottomView layoutIfNeeded];
            }];
        });
        self.isRunning = NO;
    }];
    
    //2、设置第一组总并发数量，并给这组并发设置一个唯一id
    [[XYAsynchronizationManager sharedManager] xy_synchronizeWithIdentifier:@"groupOne" totalCount:6 doneBlock:^{
        XYAM_Log(@"groupOne Tasks Done!");
        XYAM_Log(@"groupThree Task 0 executed");
        [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"groupThree"];
        
        self.isRunning = NO;
    }];
    
    //3、设置第二组总并发数量，并给这组并发设置一个唯一id
    [[XYAsynchronizationManager sharedManager] xy_synchronizeWithIdentifier:@"groupTwo" totalCount:3 doneBlock:^{
        XYAM_Log(@"groupTwo Tasks Done!");
        XYAM_Log(@"groupThree Task 1 executed");
        [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"groupThree"];
        self.isRunning = NO;
    }];
    
    //4、开始第一组任务
    for (int i = 0; i < 6; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self randomSleep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageViewsArray[i] setImage:[UIImage imageNamed:@"ditou"]];
                XYAM_Log(@"groupOne Task %d executed", i);
                
                /*
                 4.1、当你完成一步操作的时候，告知manager你完成了一步操作，你可以完全不考虑当前是在什么线程内，只需要直接调用即可。
                 这个demo是因为需要在主线程给imageView设置图片，所以才特意回到主线程中执行的。
                 */
                [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"groupOne"];
            });
        });
    }
    
    //5、开始第二组任务
    for (int i = 6; i < 9; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self randomSleep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageViewsArray[i] setImage:[UIImage imageNamed:@"ditou"]];
                XYAM_Log(@"groupTwo Task %d executed", i);
                
                /*
                 5.1、当你完成一步操作的时候，告知manager你完成了一步操作，你可以完全不考虑当前是在什么线程内，只需要直接调用即可。
                 这个demo是因为需要在主线程给imageView设置图片，所以才特意回到主线程中执行的。
                 */
                [[XYAsynchronizationManager sharedManager] xy_synchronizeOneStepByIdentifier:@"groupTwo"];
            });
        });
    }
}

#pragma mark - animations
- (void)OneGroupConcurrenceAnimation{
    self.groupOneLabel.hidden = NO;
    self.groupTwoLabel.hidden = YES;
    self.groupThreeLabel.hidden = YES;
    self.groupOneView.hidden = NO;
    self.groupTwoView.hidden = YES;
    self.groupThreeView.hidden = YES;
    [self.bottomView layoutIfNeeded];
    [UIView animateWithDuration:0.25f animations:^{
        self.groupOneHeight.constant = self.bottomView.frame.size.height;
        [self.bottomView layoutIfNeeded];
    }];
}

- (void)TwoGroupConcurrenceAnimation{
    self.groupOneLabel.hidden = NO;
    self.groupTwoLabel.hidden = NO;
    self.groupThreeLabel.hidden = YES;
    self.groupOneView.hidden = NO;
    self.groupTwoView.hidden = NO;
    self.groupThreeView.hidden = YES;
    [self.bottomView layoutIfNeeded];
    [UIView animateWithDuration:0.25f animations:^{
        self.groupOneHeight.constant = self.bottomView.frame.size.height/3*2;
        self.groupTwoHeight.constant = self.bottomView.frame.size.height/3*1;
        [self.bottomView layoutIfNeeded];
    }];
}

- (void)resetAll{
    for (UIImageView *imageView in self.imageViewsArray) {
        imageView.image = [UIImage imageNamed:@"iOSLogo"];
    }
    self.groupOneLabel.hidden = YES;
    self.groupTwoLabel.hidden = YES;
    self.groupThreeLabel.hidden = YES;
    self.groupOneView.hidden = NO;
    self.groupTwoView.hidden = NO;
    self.groupThreeView.hidden = YES;
    [self.bottomView layoutIfNeeded];
    [UIView animateWithDuration:0.25f animations:^{
        self.groupOneHeight.constant = 2.f;
        self.groupTwoHeight.constant = 2.f;
        self.groupThreeHeight.constant = 2.f;
        [self.bottomView layoutIfNeeded];
    }];
}

- (void)randomSleep{
    //模拟延迟1-4秒回调
    int x = arc4random() % 3 +1;
    sleep(x);
}
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = [self.listSourceArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self resetAll];
    switch (indexPath.row) {
        case 0:
            [self OneGroupConcurrence];
            [self OneGroupConcurrenceAnimation];
            break;
        case 1:
            [self TwoGroupConcurrence];
            [self TwoGroupConcurrenceAnimation];
            break;
        case 2:
            [self ThreeGroupsConcurrenceAndDependence];
            [self TwoGroupConcurrenceAnimation];
            break;
        default:
            break;
    }
}


#pragma mark - lazy
- (NSArray *)imageViewsArray{
    if (nil == _imageViewsArray) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:9];
        for (int i = 0; i < 9; i++) {
            UIImageView *imageView = [self.bottomView viewWithTag:1000+i];
            [tempArray addObject:imageView];
        }
        _imageViewsArray = [tempArray copy];
    }
    return _imageViewsArray;
}

- (NSArray *)listSourceArray{
    if (nil == _listSourceArray) {
        _listSourceArray = @[@"并发一组异步操作,完成后回调",@"同时并发两组异步操作,互不影响,完成后回调",@"先同时并发两组操作,完成后执行第三组操作",@"请在控制台查看输出的结果"];
    }
    return _listSourceArray;
}
@end
