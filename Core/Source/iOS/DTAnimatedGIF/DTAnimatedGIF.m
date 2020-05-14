//
//  DTAnimatedGIF.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 7/2/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "DTAnimatedGIF.h"
#import <ImageIO/ImageIO.h>

// returns the frame duration for a given image in 1/100th seconds
static NSUInteger DTAnimatedGIFFrameDurationForImageAtIndex(CGImageSourceRef source, NSUInteger index)
{
  // NOTE: This code was removed because it was copied from stackoverflow.com under the
  // CC-BY-SA 4.0 license.
  return 10;
}

// returns the great common factor of two numbers
static NSUInteger DTAnimatedGIFGreatestCommonFactor(NSUInteger num1, NSUInteger num2)
{
	NSUInteger t, remainder;
	
	if (num1 < num2)
	{
		t = num1;
		num1 = num2;
		num2 = t;
	}
	
	remainder = num1 % num2;
	
	if (!remainder)
	{
		return num2;
	}
	else
	{
		return DTAnimatedGIFGreatestCommonFactor(num2, remainder);
	}
}

static UIImage *DTAnimatedGIFFromImageSource(CGImageSourceRef source)
{
	size_t const numImages = CGImageSourceGetCount(source);
	
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numImages];
	
	// determine gretest common factor of all image durations
	NSUInteger greatestCommonFactor = DTAnimatedGIFFrameDurationForImageAtIndex(source, 0);
	
	for (NSUInteger i=1; i<numImages; i++)
	{
		NSUInteger centiSecs = DTAnimatedGIFFrameDurationForImageAtIndex(source, i);
		greatestCommonFactor = DTAnimatedGIFGreatestCommonFactor(greatestCommonFactor, centiSecs);
	}
	
	// build array of images, duplicating as necessary
	for (NSUInteger i=0; i<numImages; i++)
	{
		CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
		UIImage *frame = [UIImage imageWithCGImage:cgImage];
		
		NSUInteger centiSecs = DTAnimatedGIFFrameDurationForImageAtIndex(source, i);
		NSUInteger repeat = centiSecs/greatestCommonFactor;
		
		for (NSUInteger j=0; j<repeat; j++)
		{
			[frames addObject:frame];
		}
		
		CGImageRelease(cgImage);
	}
	
	// create animated image from the array
	NSTimeInterval totalDuration = [frames count] * greatestCommonFactor / 100.0;
	return [UIImage animatedImageWithImages:frames duration:totalDuration];
}

UIImage * _Nullable DTAnimatedGIFFromFile(NSString  * _Nonnull path)
{
	NSURL *URL = [NSURL fileURLWithPath:path];
	CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)(URL), NULL);
	
	if (!source)
	{
		return nil;
	}
	
	UIImage *image = DTAnimatedGIFFromImageSource(source);
	CFRelease(source);
	
	return image;
}

UIImage * _Nullable DTAnimatedGIFFromData(NSData * _Nonnull data)
{
	CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
	
	if (!source)
	{
		return nil;
	}

	UIImage *image = DTAnimatedGIFFromImageSource(source);
	CFRelease(source);
	
	return image;
}
