//
//  FerroMagnetism.m
//  FerroMagnetism
//
//  Created by Prakrit Shrestha on 2/25/14.
//  Copyright (c) 2014 Prakrit Shrestha. All rights reserved.
//

#import "FerroMagnetism.h"

@implementation FerroMagnetism

- (id)initWithFrame:(NSRect)frame
{
    
    srandom(unsigned(time(NULL)));  //seed with time
    
    temperature = 2 / log(1 + sqrt(2));
    absMinEnergy = 2 * SQR(SIZE);
    maxMagnetization = SQR(SIZE);
    
    maxTemp = 10;
    maxTime = 100;
    deltaTemp = 0.1;
    
    return [super initWithFrame:frame];
}

- (void)awakeFromNib
{
    [temperatureText setDoubleValue:temperature];
    [maxTempText    setDoubleValue:maxTemp];
    [maxTimeText setDoubleValue:maxTime];
    [deltaTempText setDoubleValue:deltaTemp];
    
    latticeBitmapRep = [[NSBitmapImageRep alloc]        //renders bitmap image
                        initWithBitmapDataPlanes:nil
                        pixelsWide:SIZE
                        pixelsHigh:SIZE
                        bitsPerSample:8
                        samplesPerPixel:3
                        hasAlpha:NO
                        isPlanar:NO
                        colorSpaceName:NSDeviceRGBColorSpace
                        bitmapFormat:0
                        bytesPerRow:0
                        bitsPerPixel:0
                        ];
    
    latticeImage = [[NSImage alloc]
                    initWithSize:NSMakeSize(SIZE, SIZE)
                    ];
    
    [self reset:self];
    
    startTime = clock();                //timer measures the time taken to render 100000 images
    for (int i = 0; i < 100000; i++)
    {
        [self display];
    }
    stopTime = clock();
    
    NSLog(@"total time taken (s):%f", (stopTime - startTime) / double(CLOCKS_PER_SEC));
}

- (void)drawRect:(NSRect)dirtyRect
{
    unsigned char *latticeBitmapData = [latticeBitmapRep bitmapData];
    
    for (int x = 0; x < SIZE; x++)
    {
        for (int y = 0; y < SIZE; y++)
        {
            short gray = (spin[x][y] + 1) / 2;
            
            unsigned char grayByte = gray * UCHAR_MAX;
            
            int index = 3 * ((SIZE - 1 - y) * SIZE + x);
            
            latticeBitmapData[index + 0] = grayByte;        //return pointer to bitmap data
            latticeBitmapData[index + 1] = grayByte;
            latticeBitmapData[index + 2] = grayByte;
            /*
             [[NSColor colorWithCalibratedWhite: gray alpha:1.0] set];      //draw each pixel
             
             NSRect aDot = NSMakeRect(x, y, 1, 1);
             NSRectFill(aDot);
             */
        }
    }
    
    [latticeImage addRepresentation:latticeBitmapRep];          
    [latticeImage compositeToPoint: NSMakePoint(0, 0) operation:NSCompositeCopy];
    [latticeImage removeRepresentation:latticeBitmapRep];
    [latticeImage recache];
}

- (void)reset:(id)sender
{
    temperature = [temperatureText doubleValue];
    
    for (int x = 0; x < SIZE; x++)
    {
        for (int y = 0; y < SIZE; y++)
            spin[x][y] = (RANDOM > 0.5)? -1: +1;
    }
    
    for (int x = 0; x < SIZE; x++)
    {
        for (int y = 0; y < SIZE; y++)
        {
            magnetization += spin[x][y];
            energy += -spin[x][y] * (spin[RH(x + 1)][y] + spin[x][RH(y + 1)]);
        }
    }
    
    [self setNeedsDisplay:YES];
}

-(void)evolve:(NSTimer *)timer
{
    for (int x = 0; x < SIZE; x++)
    {
        for (int y = 0; y < SIZE; y++)
        {
            double deltaEnergy = 2 * spin[x][y] * ( spin[RH(x + 1)][y] + spin[x][RH(y + 1)] + spin[RL(x - 1)][y] + spin[x][RL(y - 1)]);
            
            if (deltaEnergy < 0 || (exp(-deltaEnergy /  temperature) > RANDOM))
            {
                spin[x][y] = - spin[x][y];
                magnetization += 2 * spin[x][y];
                energy += deltaEnergy;
            }
            
        }
    }
    [magnetizationText setDoubleValue:(magnetization / maxMagnetization)];
    [energyText setDoubleValue:(energy / absMinEnergy)];
    [self display];

}

- (void)toggleEvolve:(id)sender
{
    if  (not evolving)
    {
        evolving = YES;
        animateTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 60.0
                                                        target:self
                                                      selector:@selector
                        (evolve:)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    else // animating
    {
        evolving = NO;
        [animateTimer invalidate];
    }
}

- (void)reDraw: (id)sender
{
    [self display];
}

-(IBAction)saveSnapshot:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];       //save Image
    
    NSDateFormatter *formatter;     //add date-time stamp to the default file name
    NSString *snapShot, *dateTime, *ising, *extension;
    ising = @"issingSnapShot";
    extension = @".png";
    
    formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyy_HHmmss"];
    dateTime =[formatter stringFromDate:[NSDate date]];
    snapShot = [NSString stringWithFormat:@"%@%@%@", ising, dateTime, extension];
    
    [savePanel setNameFieldStringValue: snapShot];
    
    [savePanel beginSheetModalForWindow:[self window] completionHandler:
     ^(NSInteger result)
     {
         if (result == NSOKButton)
         {
             [savePanel close];
             NSData *data = [latticeBitmapRep           //save image data into panel
                             representationUsingType:NSPNGFileType properties:nil];
             [data writeToFile:[[savePanel URL] path] atomically:NO];
         }
     }
     ];
}

-(IBAction)saveData:(id)sender
{
    maxTime = [maxTimeText doubleValue];
    maxTemp = [maxTempText doubleValue];
    deltaTemp = [deltaTempText doubleValue];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    NSDateFormatter *formatter;                 //add date-time stamp to the default file name
    NSString *dataExport, *dateTime, *ising, *extension;
    ising = @"issingData";
    extension = @".txt";
    
    formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyy_HHmmss"];
    dateTime =[formatter stringFromDate:[NSDate date]];
    dataExport = [NSString stringWithFormat:@"%@%@%@", ising, dateTime, extension];
    
    [savePanel setNameFieldStringValue: dataExport];
    
    [savePanel beginSheetModalForWindow:[self window] completionHandler:
     ^(NSInteger result)
     {
         if (result == NSOKButton)      //close panel after ok button
         {
             [savePanel close];
             const char *cFileName = [[[savePanel URL] path]
                                      cStringUsingEncoding:NSUTF8StringEncoding];
             
             FILE *outputFileP = fopen(cFileName, "w");
             fprintf(outputFileP, "temperature \t energy \t magnetization \n");
             fclose(outputFileP);
             
             for (temperature = 0.1; temperature < maxTemp; temperature += deltaTemp)
             {
                 for (int x = 0; x < SIZE; x++)
                 {
                     for (int y = 0; y < SIZE; y++)
                         spin[x][y] = (RANDOM > 0.5)? -1: +1;
                 }
                 
                 energy = 0.0;
                 magnetization = 0.0;
                 
                 for (int x = 0; x < SIZE; x++)
                 {
                     for (int y = 0; y < SIZE; y++)
                     {
                         magnetization += spin[x][y];
                         energy += -spin[x][y] * (spin[RH(x + 1)][y] + spin[x][RH(y + 1)]);
                     }
                 }
                 for (int time = 0; time < maxTime; time++)
                 {
                     for (int x = 0; x < SIZE; x++)
                     {
                         for (int y = 0; y < SIZE; y++)
                         {
                             double deltaEnergy = 2 * spin[x][y] * ( spin[RH(x + 1)][y] + spin[x][RH(y + 1)] + spin[RL(x - 1)][y] + spin[x][RL(y - 1)]);
                             
                             if (deltaEnergy < 0 || (exp(-deltaEnergy /  temperature) > RANDOM))
                             {
                                 spin[x][y] = - spin[x][y];
                                 magnetization += 2 * spin[x][y];
                                 energy += deltaEnergy;
                             }
                         }
                     }
                 }
                 fopen(cFileName, "a");
                 fprintf(outputFileP, "%f \t %f \t %f \n",  temperature, energy, magnetization);
                 fclose(outputFileP);
             }
         }
     }
     ];
    [temperatureText setDoubleValue:temperature];
}

@end
