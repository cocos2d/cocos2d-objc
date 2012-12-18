/*
 
 Copyright (c) 2012 - Zynga Inc.
 
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
 
 */

/*
 Local Storage support for the JS Bindings for iOS.
 Works on cocos2d-iphone and cocos2d-x.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

static int _initialized = 0;
static sqlite3 *_db;
static sqlite3_stmt *_stmt_select;
static sqlite3_stmt *_stmt_remove;
static sqlite3_stmt *_stmt_update;
static char *_db_path = "js_localstorage.sqlite";


void localStorageLazyInit();


void localStorageLazyInit()
{
	if( ! _initialized ) {

		int ret = 0;
		
		if (!_db_path)
			ret = sqlite3_open(":memory:",&_db);
		else
			ret = sqlite3_open(_db_path, &_db);
		
		// SELECT
		const char *sql_select = "SELECT value FROM data WHERE key=?";
		ret = sqlite3_prepare_v2(_db, sql_select, -1, &_stmt_select, NULL);

		// UPDATE
		const char *sql_update = "REPLACE INTO data (key, value) VALUES (?,?);";
		ret = sqlite3_prepare_v2(_db, sql_update, -1, &_stmt_update, NULL);

		// UPDATE
		const char *sql_remove = "DELETE FROM data WHERE key=?;";
		ret = sqlite3_prepare_v2(_db, sql_remove, -1, &_stmt_remove, NULL);

		if( ret != SQLITE_OK ) {
			// report error
		}
	}
}

void localStorageDestroy()
{
	if( _initialized ) {
		sqlite3_finalize(_stmt_select);
		sqlite3_finalize(_stmt_remove);
		sqlite3_finalize(_stmt_update);		

		sqlite3_close(_db);
	}
}

/** sets an item in the LS */
void localStorageSetItem( char *key, const char *value)
{
	localStorageLazyInit();

	sqlite3_bind_text(_stmt_update, 1, key, -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(_stmt_update, 2, value, -1, SQLITE_TRANSIENT);

	sqlite3_step(_stmt_update);
	
	sqlite3_reset(_stmt_update);
}

/** gets an item from the LS */
const unsigned char* localStorageGetItem( char *key )
{
	localStorageLazyInit();
	
	sqlite3_bind_text(_stmt_select, 1, key, -1, SQLITE_TRANSIENT);
	
	sqlite3_step(_stmt_select);
	const unsigned char *ret = sqlite3_column_text(_stmt_select, 0);
	
	sqlite3_reset(_stmt_select);

	return ret;
}

/** removes an item from the LS */
void localStorageRemoveItem( char *key )
{
	sqlite3_bind_text(_stmt_remove, 1, key, -1, SQLITE_TRANSIENT);
	
	sqlite3_step(_stmt_remove);
	
	sqlite3_reset(_stmt_remove);	
}
