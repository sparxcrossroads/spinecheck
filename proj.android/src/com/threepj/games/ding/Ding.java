/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package com.threepj.games.ding;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.utils.PSNative;
import android.os.Bundle;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

public class Ding extends Cocos2dxActivity {
	private static String gameVersion = "0";
	@Override
	public void onCreate(Bundle savedInstanceState) {
		PSNative.init(this);
		super.onCreate(savedInstanceState);
		try{
		PackageManager manager = this.getPackageManager();
		PackageInfo info = manager.getPackageInfo(this.getPackageName(), 0);
		gameVersion = info.versionName;
		} catch(Exception e){
			
		}
	}

    static {
    	System.loadLibrary("game");
    }
    
    public static String getVersion(){
    	return gameVersion;
    }
}
