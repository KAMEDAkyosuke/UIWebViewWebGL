//
//  Datastore.m
//  UIWebViewWebGL
//
//  Created by organlounge on 2013/10/16.
//  Copyright (c) 2013年 Nathan de Vries. All rights reserved.
//

#import "Datastore.h"

#import <sqlite3.h>

#import "Bookmark.h"

static const int kDatastoreVersion = 1;

static void exec_sql(sqlite3* db, const char* sql);
static void create_tables(sqlite3 *db);
static void update_tables_if_nessesary(sqlite3* db, int version);
static bool table_is_exist(sqlite3* db, char* table);

@interface Datastore ()
@property(nonatomic, assign) sqlite3 *db;
@end

@implementation Datastore

+ (instancetype)sharedDatastore
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self.class.alloc init];
    });
    return instance;
}

- (void)open:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if (sqlite3_open_v2([writableDBPath UTF8String],
                        &_db,
                        SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
                        NULL) != SQLITE_OK) {
        NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(_db));
        sqlite3_close(_db);
        _db = NULL;
        return;
    }
    else{
        if(table_is_exist(_db, "bookmark_tbl")){
            // pass
        }
        else{
            create_tables(_db);
            Bookmark *bookmark = [Bookmark.alloc init];
            bookmark.url = @"http://webglsamples.googlecode.com/hg/aquarium/aquarium.html";
            [self insertOrReplaceBookmark:bookmark];
        }
    }
}

- (void)close
{
    if(self.db != NULL){
        sqlite3_close(self.db);
        self.db = NULL;
    }
}

#pragma mark - bookmark

- (NSArray*)bookmarks
{
    sqlite3_stmt *stmt = NULL;
    NSMutableArray *r = [NSMutableArray array];
    const char *sql = "SELECT url, insert_at, update_at FROM bookmark_tbl ORDER BY insert_at DESC;";
    if (sqlite3_prepare_v2(self.db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.db));
    }
    
    // Execute the query.
    while(sqlite3_step(stmt) == SQLITE_ROW){
        int idx = 0;
        char *url = (char*) sqlite3_column_text(stmt, idx++);
        double insert_at = sqlite3_column_double(stmt, idx++);
        double update_at = sqlite3_column_double(stmt, idx++);
        
        Bookmark *bookmark = [Bookmark.alloc init];
        bookmark.url = [NSString stringWithUTF8String:url];
        bookmark.insertAt = [NSDate dateWithTimeIntervalSince1970:insert_at];
        bookmark.updateAt = [NSDate dateWithTimeIntervalSince1970:update_at];
        [r addObject:bookmark];
    }
    sqlite3_finalize(stmt);
    return r;
}

- (void)insertOrReplaceBookmark:(Bookmark*)bookmark
{
    sqlite3_stmt *stmt = NULL;
    
    static const char *sql = "INSERT OR REPLACE INTO bookmark_tbl (url, insert_at, update_at) VALUES (?, ?, ?);";
    if (sqlite3_prepare_v2(self.db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.db));
    }
    // Bind the parser type to the statement.
    int index = 1;
    if (sqlite3_bind_text(stmt, index++, [bookmark.url UTF8String], -1, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(self.db));
    }
    NSDate *insertAt = bookmark.insertAt != nil ? bookmark.insertAt : [NSDate date];
    if (sqlite3_bind_double(stmt, index++, [insertAt timeIntervalSince1970]) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(self.db));
    }
    NSDate *updateAt = bookmark.updateAt != nil ? bookmark.updateAt : [NSDate date];
    if (sqlite3_bind_double(stmt, index++, [updateAt timeIntervalSince1970]) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(self.db));
    }
    
    // Execute the query.
    int success = sqlite3_step(stmt);
    if (success == SQLITE_ERROR) {
        NSCAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(self.db));
    }
    sqlite3_finalize(stmt);
}

- (void)deletBookmark:(Bookmark*)bookmark
{
    sqlite3_stmt *stmt = NULL;
    
    static const char *sql = "DELETE FROM bookmark_tbl WHERE url = ?;";
    if (sqlite3_prepare_v2(self.db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.db));
    }
    // Bind the parser type to the statement.
    int index = 1;
    if (sqlite3_bind_text(stmt, index++, [bookmark.url UTF8String], -1, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(self.db));
    }
    // Execute the query.
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

@end

static void exec_sql(sqlite3* db, const char* sql)
{
    char *errmsg = NULL;
    sqlite3_exec(db, sql, NULL, NULL, &errmsg);
    if(errmsg != NULL){
        NSLog(@"sqlite3_exec on error : %s", errmsg);
    }
    sqlite3_free(errmsg);
}

static void create_tables(sqlite3 *db)
{
    exec_sql(db,
             "CREATE TABLE bookmark_tbl \n"
             "(\n"
                 "url TEXT NOT NULL, \n"
                 "insert_at REAL NOT NULL, \n"
                 "update_at REAL NOT NULL, \n"
                 "PRIMARY KEY(url)\n"
             ");");
}

static bool table_is_exist(sqlite3* db, char* table)
{
    sqlite3_stmt *stmt = NULL;
    bool r = false;
    
    static const char *sql = "SELECT tbl_name FROM sqlite_master WHERE type = 'table' AND tbl_name = ?;";
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    }
    // Bind the parser type to the statement.
    if (sqlite3_bind_text(stmt, 1, table, -1, NULL) != SQLITE_OK) {
        NSCAssert1(0, @"Error: failed to bind variable with message '%s'.", sqlite3_errmsg(db));
    }
    // Execute the query.
    if(sqlite3_step(stmt) == SQLITE_ROW){
        r = true;
    }
    sqlite3_finalize(stmt);
    return r;
}
