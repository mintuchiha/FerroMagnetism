//
//  FerroMagnetism.h
//  FerroMagnetism
//
//  Created by Prakrit Shrestha on 2/25/14.
//  Copyright (c) 2014 Prakrit Shrestha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <time.h>

#define RANDOM (double(random()) / RAND_MAX)
#define RH(n) ((n < SIZE)? n : 0)
#define RL(n) ((n >= 0)? n : SIZE - 1)
#define SQR(a) ((a) * (a))

const int SIZE = 512;

@interface FerroMagnetism : NSView
{
    double energy, magnetization; IBOutlet id energyText, magnetizationText;
    
    double temperature; IBOutlet id temperatureText;
    double absMinEnergy;
    double maxMagnetization;
    
    int maxTime, maxTemp; IBOutlet id maxTimeText, maxTempText, deltaTempText;
    double deltaTemp;
    
    //NSString *picName, *dataName;
    
    short spin[SIZE][SIZE];     //  +/- 1
    
    bool evolving;
 
    NSTimer *animateTimer;

    NSImage *latticeImage;
    NSBitmapImageRep *latticeBitmapRep;
    
    clock_t startTime, stopTime;
}

-(IBAction)reset:(id)sender;
-(void)awakeFromNib;
-(void)evolve: (NSTimer *)timer;
-(IBAction)toggleEvolve: (id)sender;
-(IBAction)reDraw:(id)sender;
-(IBAction)saveSnapshot:(id)sender;
-(IBAction)saveData:(id)sender;

@end
