//
//  XspfQTValueTransformers.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//

/*
 Copyright (c) 2008-2009, masakih
 All rights reserved.
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2008-2009, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1, Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3, The names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <QTKit/QTKit.h>

#import "XspfQTValueTransformers.h"


@implementation XspfQTTimeTransformer
+ (Class)transformedValueClass
{
	return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation
{
	return YES;
}
- (id)transformedValue:(id)value
{
	if(!value) return nil;
	
	QTTime t = [value QTTimeValue];
	NSTimeInterval res;
	
	if(!QTGetTimeInterval(t, &res)) {return nil;}
	
	return [NSNumber numberWithDouble:res];
}
- (id)reverseTransformedValue:(id)value
{
	if(!value) return nil;
	
	QTTime t = QTMakeTimeWithTimeInterval([value doubleValue]);
	
	return [NSValue valueWithQTTime:t];
}
@end

@implementation XspfQTTimeDateTransformer
+ (Class)transformedValueClass
{
	return [NSDate class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}
- (id)transformedValue:(id)value
{
	if(!value) return nil;
	
	QTTime t = [value QTTimeValue];
	NSTimeInterval res;
	
	if(!QTGetTimeInterval(t, &res)) {return nil;}
	
	res -= [[NSTimeZone systemTimeZone] secondsFromGMT];
	
	return [NSDate dateWithTimeIntervalSince1970:res];
}
@end


@implementation XspfQTSizeToStringTransformer
+ (Class)transformedValueClass
{
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}
- (id)transformedValue:(id)value
{
	if(!value) return nil;
	
	NSSize size = [value sizeValue];
	
	return [NSString stringWithFormat:@"%.0f X %.0f", size.width, size.height];
}
@end

@implementation XspfQTFileSizeStringTransformer
+ (Class)transformedValueClass
{
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}
- (id)transformedValue:(id)value
{
	if(!value) return nil;
	
	double dSize = [value longLongValue];
	
	if(dSize < 1024) {
		return [NSString stringWithFormat:@"%.0f Byte", dSize];
	}
	
	dSize /= 1024;
	if(dSize < 1024) {
		return [NSString stringWithFormat:@"%.2f KB", dSize];
	}
	
	dSize /= 1024;
	if(dSize < 1024) {
		return [NSString stringWithFormat:@"%.2f MB", dSize];
	}
	
	dSize /= 1024;
	return [NSString stringWithFormat:@"%.2f GB", dSize];
}
@end

