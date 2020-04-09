/* Utils.em - a small collection of useful editing macros */

/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function.
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	// Get the owner's name from the environment variable: MYNAME.
	// If the variable doesn't exist, then the owner field is skipped.
	szMyName = getenv(MYNAME)

	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

	// begin assembling the title string
	sz = "/*   "

	/* convert symbol name to T E X T   L I K E   T H I S */
	cch = strlen(szFunc)
	ich = 0
	while (ich < cch)
		{
		ch = szFunc[ich]
		if (ich > 0)
			if (isupper(ch))
				sz = cat(sz, "   ")
			else
				sz = cat(sz, " ")
		sz = Cat(sz, toupper(ch))
		ich = ich + 1
		}

	sz = Cat(sz, "   */")
	InsBufLine(hbuf, ln, sz)
	InsBufLine(hbuf, ln+1, "/*-------------------------------------------------------------------------")

	/* if owner variable exists, insert Owner: name */
	if (strlen(szMyName) > 0)
		{
		InsBufLine(hbuf, ln+2, "    Owner: @szMyName@")
		InsBufLine(hbuf, ln+3, " ")
		ln = ln + 4
		}
	else
		ln = ln + 2

	InsBufLine(hbuf, ln,   "    ") // provide an indent already
	InsBufLine(hbuf, ln+1, "-------------------------------------------------------------------------*/")

	// put the insertion point inside the header comment
	SetBufIns(hbuf, ln, 4)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current function.
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = getenv(MYNAME)

	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")

	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2

	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}



// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}

macro InsertCPlusPlus()
{
	IfdefSz("__cplusplus");
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)

	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}


// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}

	hbufOutput = NewBuf("Results")

	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}

	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)

	return hbufOutput
}

/***************************************************************************************
****************************************************************************************
* FILE		: SourceInsight_Comment.em
* Description	: utility to insert comment in Source Insight project
*
* Copyright (c) 2007 by Liu Ying. All Rights Reserved.
*
* History:
* Version		Name       	Date			Description
   0.1		Liu Ying		2006/04/07	Initial Version
   0.2		Liu Ying		2006/04/21	add Ly_InsertHFileBanner
****************************************************************************************
****************************************************************************************/


/*==================================================================
* Function	: InsertFileHeader
* Description	: insert file header
*
* Input Para	: none

* Output Para	: none

* Return Value: none
==================================================================*/
macro Ly_InsertFileHeader()
{
	// get aurthor name
	szMyName = getenv(MYNAME)
	if (strlen(szMyName) <= 0)
	{
		szMyName = "XXX"
	}

	// get company name
	szCompanyName = getenv(MYCOMPANY)
	if (strlen(szCompanyName) <= 0)
	{
		szCompanyName = szMyName
	}

	// get time
	szTime = GetSysTime(True)
	Day = szTime.Day
	Month = szTime.Month
	Year = szTime.Year
	if (Day < 10)
	{
		szDay = "0@Day@"
	}
	else
	{
		szDay = Day
	}
	if (Month < 10)
	{
		szMonth = "0@Month@"
	}
	else
	{
		szMonth = Month
	}

	// get file name
	hbuf = GetCurrentBuf()
	szpathName = GetBufName(hbuf)
	szfileName = GetFileName(szpathName)
	nlength = StrLen(szfileName)

	// assemble the string
	hbuf = GetCurrentBuf()

InsBufLine(hbuf, 0, "")
InsBufLine(hbuf, 1, "/****************************************Copyright (c)****************************************************")
InsBufLine(hbuf, 2, "**")
InsBufLine(hbuf, 3, "** Copyright (c) @Year@ by @szCompanyName@ co.,ltd. All Rights Reserved.")
InsBufLine(hbuf, 4, "**")

InsBufLine(hbuf, 5, "**--------------File Info---------------------------------------------------------------------------------")
InsBufLine(hbuf, 6, "** File name         : @szfileName@")
InsBufLine(hbuf, 7, "** Last modified Date: @Year@年@szMonth@月@szDay@日 ")
InsBufLine(hbuf, 8, "** Last Version      : Ver 1.0")
InsBufLine(hbuf, 9, "** Description	     :")
InsBufLine(hbuf, 10,"**")
InsBufLine(hbuf, 11,"**------------------------------------------------------------------------------------------------------")

InsBufLine(hbuf, 12,"** Created by        : @szMyName@")
InsBufLine(hbuf, 13,"** Created date      : @Year@年@szMonth@月@szDay@日")
InsBufLine(hbuf, 14,"** Version           : Ver 1.0")
InsBufLine(hbuf, 15,"** Description       : The original version 初始版本")
InsBufLine(hbuf, 16,"**")
InsBufLine(hbuf, 17,"**------------------------------------------------------------------------------------------------------")

InsBufLine(hbuf, 18,"** Modified by       :")
InsBufLine(hbuf, 19,"** Modified date     :")
InsBufLine(hbuf, 20,"** Version           :")
InsBufLine(hbuf, 21,"** Description       :")
InsBufLine(hbuf, 22,"**")
InsBufLine(hbuf, 23,"********************************************************************************************************/")

InsBufLine(hbuf, 24, "")
InsBufLine(hbuf, 25, "")

InsBufLine(hbuf, 26,"/************************************************************************")
InsBufLine(hbuf, 27,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 28,"**Debug switch 调试选项 ")
InsBufLine(hbuf, 29,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 30,"************************************************************************/")

InsBufLine(hbuf, 31, "")

InsBufLine(hbuf, 32,"/************************************************************************")
InsBufLine(hbuf, 33,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 34,"**Include File 包含文件")
InsBufLine(hbuf, 35,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 36,"************************************************************************/")

InsBufLine(hbuf, 37, "")

InsBufLine(hbuf, 38,"/************************************************************************")
InsBufLine(hbuf, 39,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 40,"**enum Define 枚举变量定义")
InsBufLine(hbuf, 41,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 42,"************************************************************************/")

InsBufLine(hbuf, 43, "")

InsBufLine(hbuf, 44,"/************************************************************************")
InsBufLine(hbuf, 45,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 46,"**union Define 联合体变量定义")
InsBufLine(hbuf, 47,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 48,"************************************************************************/")

InsBufLine(hbuf, 49, "")

InsBufLine(hbuf, 50,"/************************************************************************")
InsBufLine(hbuf, 51,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 52,"**Macro Define 宏定义")
InsBufLine(hbuf, 53,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 54,"************************************************************************/")

InsBufLine(hbuf, 55, "")


InsBufLine(hbuf, 56,"/************************************************************************")
InsBufLine(hbuf, 57,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 58,"**Struct Define 结构体定义 ")
InsBufLine(hbuf, 59,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 60,"************************************************************************/")

InsBufLine(hbuf, 61, "")

InsBufLine(hbuf, 62,"/************************************************************************")
InsBufLine(hbuf, 63,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 64,"**Prototype Declare 函数原型声明 ")
InsBufLine(hbuf, 65,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 66,"************************************************************************/")

InsBufLine(hbuf, 67, "")

InsBufLine(hbuf, 68,"/************************************************************************")
InsBufLine(hbuf, 69,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 70,"**Global Variable Declare 全局变量声明")
InsBufLine(hbuf, 71,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 72,"************************************************************************/")

InsBufLine(hbuf, 73, "")

InsBufLine(hbuf, 74,"/************************************************************************")
InsBufLine(hbuf, 75,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 76,"**Global Variable Define 全局变量定义")
InsBufLine(hbuf, 77,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 78,"************************************************************************/")

InsBufLine(hbuf, 79, "")

InsBufLine(hbuf, 80,"/************************************************************************")
InsBufLine(hbuf, 81,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 82,"**Static Variable Define 静态变量定义")
InsBufLine(hbuf, 83,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 84,"************************************************************************/")

InsBufLine(hbuf, 85, "")

InsBufLine(hbuf, 86,"/************************************************************************")
InsBufLine(hbuf, 87,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 88,"**Function Define  函数定义")
InsBufLine(hbuf, 89,"-------------------------------------------------------------------------")
InsBufLine(hbuf, 90,"************************************************************************/")
InsBufLine(hbuf, 91, "")
InsBufLine(hbuf, 92, "")
InsBufLine(hbuf, 93, "")
InsBufLine(hbuf, 94, "")
InsBufLine(hbuf, 95,"/**********************************END**********************************/")
InsBufLine(hbuf, 96, "")



	// put the insertion point
	SetBufIns(hbuf, 78, 0)
}
macro Date()
{
	// get aurthor name
	szMyName = getenv(MYNAME)
	if (strlen(szMyName) <= 0)
	{
		szMyName = "XXX"
	}

	// get time
	szTime = GetSysTime(True)
	Day = szTime.Day
	Month = szTime.Month
	Year = szTime.Year

	if (Day < 10)
	{
		szDay = "0@Day@"
	}
	else
	{
		szDay = Day
	}
	if (Month < 10)
	{
		szMonth = "0@Month@"
	}
	else
	{
		szMonth = Month
	}

	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)

	hbuf = GetCurrentBuf()

	InsBufLine(hbuf,lnFirst,"/* @Year@年@szMonth@月@szDay@日 by @szMyName@ */")

}

macro zhushi()
{

	hbufCur = GetCurrentBuf();

	hwnd = GetCurrentWnd()
    selection = GetWndSel(hwnd)
    LnFirst = GetWndSelLnFirst(hwnd)      //取首行行号
    
	InsBufLine(hbufCur,LnFirst,"/* */")

}

/*==================================================================
* Function	: InsertFileHeader
* Description	: insert file header
*
* Input Para	: none

* Output Para	: none

* Return Value: none
==================================================================*/

macro Ly_InsertFunctionHeaderx()
{
	// get function name
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

// get time
	szTime = GetSysTime(True)
	Day = szTime.Day
	Month = szTime.Month
	Year = szTime.Year

	Hour = szTime.Hour
	Minute = szTime.Minute

	if(Hour <10)
	{
		szHour = "0@Hour@"
	}
	else
	{
		szHour = "@Hour@"
	}
	if(Minute < 10)
	{
		szMin = "0@Minute@"
	}
	else
	{
		szMin = "@Minute@"
	}

	if (Day < 10)
	{
		szDay = "0@Day@"
	}
	else
	{
		szDay = Day
	}
	if (Month < 10)
	{
		szMonth = "0@Month@"
	}
	else
	{
		szMonth = Month
	}

	// get aurthor name
	szMyName = getenv(MYNAME)
	if (strlen(szMyName) <= 0)
	{
		szMyName = "XXX"
	}

	// assemble the string
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, ln, "")
	InsBufLine(hbuf, ln+1, "/*********************************************************************************************************")
	InsBufLine(hbuf, ln+2, "** Function name : @szFunc@")
	InsBufLine(hbuf, ln+3, "** Input Para	 : NONE")
	InsBufLine(hbuf, ln+4, "** Output param  : NONE")
    InsBufLine(hbuf, ln+5, "** Return param  : NONE")
	InsBufLine(hbuf, ln+6, "** Created by    : @szMyName@")
	InsBufLine(hbuf, ln+7, "** Created Date  : @Year@年@szMonth@月@szDay@日")
	InsBufLine(hbuf, ln+8, "** Descriptions	 : ")
	InsBufLine(hbuf, ln+9, "**")
	InsBufLine(hbuf, ln+10, "** -------------------------------------------------------------------------------------------------------")
	InsBufLine(hbuf, ln+11,"** Modified by   : ")
	InsBufLine(hbuf, ln+12,"** Modified Date : ")
	InsBufLine(hbuf, ln+13,"** Descriptions	 : ")
	InsBufLine(hbuf, ln+14,"**")
	InsBufLine(hbuf, ln+15,"** -------------------------------------------------------------------------------------------------------")
	InsBufLine(hbuf, ln+16,"**********************************************************************************************************/")
    InsBufLine(hbuf, ln+17, "")
	// put the insertion point
	SetBufIns(hbuf, ln+18, 0)
}


/*==================================================================
* Function	: InsertFileHeader
* Description	: insert file header
*
* Input Para	: none

* Output Para	: none

* Return Value: none
==================================================================*/
macro Ly_InsertHFileBanner()
{
		// get aurthor name
	szMyName = getenv(MYNAME)
	if (strlen(szMyName) <= 0)
	{
		szMyName = "XXX"
	}

	// get company name
	szCompanyName = getenv(MYCOMPANY)
	if (strlen(szCompanyName) <= 0)
	{
		szCompanyName = szMyName
	}

	// get time
	szTime = GetSysTime(True)
	Day = szTime.Day
	Month = szTime.Month
	Year = szTime.Year
	if (Day < 10)
	{
		szDay = "0@Day@"
	}
	else
	{
		szDay = Day
	}
	if (Month < 10)
	{
		szMonth = "0@Month@"
	}
	else
	{
		szMonth = Month
	}

	// get file name
	hbuf = GetCurrentBuf()
	szpathName = GetBufName(hbuf)
	szfileName = GetFileName(szpathName)
	szfileName = toupper(szfileName)

	// create banner
	banner = "_"
	nlength = strlen(szfileName)

	i=0
	while (i < nlength)
	{
		if (szfileName[i] == ".")
		{
			banner = cat(banner, "_")
		}
		else
		{
			banner = cat(banner, szfileName[i])
		}

		i = i+1
	}

	banner = cat(banner, "_")

	// print banner
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)

	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifndef @banner@")
	InsBufLine(hbuf, lnFirst+1, "#define @banner@")
	InsBufLine(hbuf, lnFirst+2, "")

	InsBufLine(hbuf, lnFirst+3, "")
	InsBufLine(hbuf, lnFirst+4, "/****************************************Copyright (c)****************************************************")
	InsBufLine(hbuf, lnFirst+5, "**")
	InsBufLine(hbuf, lnFirst+6, "** Copyright (c) @Year@ by @szCompanyName@ co.,ltd. All Rights Reserved.")
	InsBufLine(hbuf, lnFirst+7, "**")

	InsBufLine(hbuf, lnFirst+8, "**--------------File Info---------------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+9, "** File name         : @szfileName@")
	InsBufLine(hbuf, lnFirst+10, "** Last modified Date: @Year@年@szMonth@月@szDay@日 ")
	InsBufLine(hbuf, lnFirst+11, "** Last Version      : Ver 1.0")
	InsBufLine(hbuf, lnFirst+12, "** Description	     :")
	InsBufLine(hbuf, lnFirst+13,"**")
	InsBufLine(hbuf, lnFirst+14,"**------------------------------------------------------------------------------------------------------")

	InsBufLine(hbuf, lnFirst+15,"** Created by        : @szMyName@")
	InsBufLine(hbuf, lnFirst+16,"** Created date      : @Year@年@szMonth@月@szDay@日")
	InsBufLine(hbuf, lnFirst+17,"** Version           : Ver 1.0")
	InsBufLine(hbuf, lnFirst+18,"** Description       : The original version 初始版本")
	InsBufLine(hbuf, lnFirst+19,"**")
	InsBufLine(hbuf, lnFirst+20,"**------------------------------------------------------------------------------------------------------")

	InsBufLine(hbuf, lnFirst+21,"** Modified by       :")
	InsBufLine(hbuf, lnFirst+22,"** Modified date     :")
	InsBufLine(hbuf, lnFirst+23,"** Version           :")
	InsBufLine(hbuf, lnFirst+24,"** Description       :")
	InsBufLine(hbuf, lnFirst+25,"**")
	InsBufLine(hbuf, lnFirst+26,"********************************************************************************************************/")

	InsBufLine(hbuf, lnFirst+27, "")
	InsBufLine(hbuf, lnFirst+28, "")

	InsBufLine(hbuf, lnFirst+29,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+30,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+31,"**Debug switch 调试选项 ")
	InsBufLine(hbuf, lnFirst+32,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+33,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+34, "")

	InsBufLine(hbuf, lnFirst+35,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+36,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+37,"**Include File 包含文件")
	InsBufLine(hbuf, lnFirst+38,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+39,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+40, "")

	InsBufLine(hbuf, lnFirst+41,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+42,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+43,"**enum Define 枚举变量定义")
	InsBufLine(hbuf, lnFirst+44,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+45,"************************************************************************/")
	InsBufLine(hbuf, lnFirst+46, "")

	InsBufLine(hbuf, lnFirst+47,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+48,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+49,"** union Define 联合体变量定义")
	InsBufLine(hbuf, lnFirst+50,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+51,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+52, "")

	InsBufLine(hbuf, lnFirst+53,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+54,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+55,"** Macro Define 宏定义")
	InsBufLine(hbuf, lnFirst+56,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+57,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+58, "")


	InsBufLine(hbuf, lnFirst+59,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+60,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+61,"**Struct Define 结构体定义 ")
	InsBufLine(hbuf, lnFirst+62,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+63,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+64, "")

	InsBufLine(hbuf, lnFirst+65,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+66,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+67,"**Prototype Declare 函数原型声明 ")
	InsBufLine(hbuf, lnFirst+68,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+69,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+70, "")

	InsBufLine(hbuf, lnFirst+71,"/************************************************************************")
	InsBufLine(hbuf, lnFirst+72,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+73,"**Global Variable Declare 全局变量声明")
	InsBufLine(hbuf, lnFirst+74,"-------------------------------------------------------------------------")
	InsBufLine(hbuf, lnFirst+75,"************************************************************************/")

	InsBufLine(hbuf, lnFirst+76, "")
	InsBufLine(hbuf, lnFirst+77, "")

	InsBufLine(hbuf, lnLast+78, "#endif /*@banner@*/")

	InsBufLine(hbuf, lnFirst+79, "")
	InsBufLine(hbuf, lnFirst+80, "")

	SetBufIns(hbuf, lnFirst+81, 0)
}

/*==================================================================
* Function	: GetFileName
* Description	: get file name from path
*
* Input Para	: pathName	: path stringSmart

* Output Para	: None

* Return Value: name		: file name
==================================================================*/
macro GetFileName(pathName)
{
	nlength = strlen(pathName)
	i = nlength - 1
	name = ""
	while (i + 1)
	{
		ch = pathName[i]
		if ("\\" == "@ch@")
			break
		i = i - 1
	}
	i = i + 1
	while (i < nlength)
	{
		name = cat(name, pathName[i])
		i = i + 1
	}

	return name
}

macro MultiLineComment()
{
    hwnd = GetCurrentWnd()
    selection = GetWndSel(hwnd)
    LnFirst = GetWndSelLnFirst(hwnd)      //取首行行号
    LnLast = GetWndSelLnLast(hwnd)      //取末行行号
    hbuf = GetCurrentBuf()

    if(GetBufLine(hbuf, 0) == "//magic-number:tph85666031"){
        stop
    }

    Ln = Lnfirst
    buf = GetBufLine(hbuf, Ln)
    len = strlen(buf)

    while(Ln <= Lnlast) {
        buf = GetBufLine(hbuf, Ln)  //取Ln对应的行
        if(buf == ""){                    //跳过空行
            Ln = Ln + 1
            continue
        }

        if(StrMid(buf, 0, 1) == "/") {       //需要取消注释,防止只有单字符的行
            if(StrMid(buf, 1, 2) == "/"){
                PutBufLine(hbuf, Ln, StrMid(buf, 2, Strlen(buf)))
            }
        }

        if(StrMid(buf,0,1) != "/"){          //需要添加注释
            PutBufLine(hbuf, Ln, Cat("//", buf))
        }
        Ln = Ln + 1
    }

    SetWndSel(hwnd, selection)
}

macro AddMacroComment()
{
    hwnd=GetCurrentWnd()
    sel=GetWndSel(hwnd)
    lnFirst=GetWndSelLnFirst(hwnd)
    lnLast=GetWndSelLnLast(hwnd)
    hbuf=GetCurrentBuf()

    if(LnFirst == 0) {
            szIfStart = ""
    }else{
            szIfStart = GetBufLine(hbuf, LnFirst-1)
    }
    szIfEnd = GetBufLine(hbuf, lnLast+1)
    if(szIfStart == "#if 0" && szIfEnd == "#endif") {
            DelBufLine(hbuf, lnLast+1)
            DelBufLine(hbuf, lnFirst-1)
            sel.lnFirst = sel.lnFirst – 1
            sel.lnLast = sel.lnLast – 1
    }else{
            InsBufLine(hbuf, lnFirst, "#if 0")
            InsBufLine(hbuf, lnLast+2, "#endif")
            sel.lnFirst = sel.lnFirst + 1
            sel.lnLast = sel.lnLast + 1
    }

    SetWndSel( hwnd, sel )
}

/*
the info like:
by guixue 2009-8-19
*/
macro getCommentInfo()
{
	 szMyName = "guixue "
	 hbuf = GetCurrentBuf()
	 ln = GetBufLnCur(hbuf)
	 szTime = GetSysTime(1)
	 Hour = szTime.Hour
	 Minute = szTime.Minute
	 Second = szTime.Second
	 Day = szTime.Day
	 Month = szTime.Month
	 Year = szTime.Year
	 if (Day < 10)
	  szDay = "0@Day@"
	 else
	  szDay = Day
	 if (Month < 10)
	     szMonth = "0@Month@"
	 else
	  szMonth = Month
	 
	 szDescription = "by"
	 szInfo ="@szDescription@ @szMyName@ @Year@-@szMonth@-@szDay@"
	 return szInfo
}
macro SingleLineComment()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLnCur(hbuf)
 	szInfo = getCommentInfo()
 	InsBufLine(hbuf, ln+1, "/* @szInfo@ */")
}
macro C_CommentBlock()
{
	hbuf = GetCurrentBuf();
	hwnd = GetCurrentWnd();
	sel = GetWndSel(hwnd);
	/*
	szLine = GetBufLine(hbuf, sel.lnFirst);
	szLine = cat("/*", szLine);
	PutBufLine(hbuf, sel.lnFirst, szLine);
	*/
	szInfo = getCommentInfo()
	szInfo = "/*"
	InsBufLine(hbuf, sel.lnFirst, szInfo)
	InsBufLine(hbuf, sel.lnLast+2, "*/")
	tabSize = 4;
	sel.ichFirst = sel.ichFirst + tabSize;
	sel.ichLim = sel.ichLim + tabSize;
	SetWndSel(hwnd, sel);
}

macro AddCComment() 
{
   hbuf = GetCurrentBuf() 
   ln = GetBufLnCur (hbuf)
   sz = GetBufLine (hbuf, ln)

   if(strlen(sz) == 0)
   {
     sz = cat(sz, "/*  */")
   }
   else
   {
     sz = cat(sz, "/*  */")
   }
   DelBufLine (hbuf, ln)
   InsBufLine(hbuf, ln, sz)

   SetBufIns (hbuf, ln, strlen(sz)-3)
}

macro C_UnCommentBlock()
{
	hbuf = GetCurrentBuf();
	hwnd = GetCurrentWnd();
	sel = GetWndSel(hwnd);
	iLine = sel.lnFirst;
	szLine = GetBufLine(hbuf, iLine);
	szInfo = getCommentInfo()
	szInfo = "/*    @szInfo@"
	
	if (szLine[0] == "/" && szLine[1] == "*")
	{
		if(szInfo == szLine)
		{
			DelBufLine(hbuf, iLine)
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
	iLine = sel.lnLast-1;
	szLine = GetBufLine(hbuf, iLine);
	len =strlen(szLine)
	if(len <2)
		return false;
	if(szLine== "*/")
	{
		DelBufLine(hbuf, iLine)
	}
	else
	{
		return false;
	}
	SetWndSel(hwnd, sel);
	return true;
}
macro C_Do_Comment()
{
	flag =C_UnCommentBlock()
	if(flag==false)
	{
		C_CommentBlock()
	}
}

