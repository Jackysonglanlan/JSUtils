//
//  ARDatabaseManager.m
//  iActiveRecord
//
//  Created by Alex Denisov on 10.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "ARDatabaseManager.h"
#import "ActiveRecord.h"
#import "NSString+quotedString.h"
#include <sys/xattr.h>
#import "sqlite3_unicode.h"
#import "ARColumn.h"

#define DEFAULT_DBNAME @"database"

static NSArray *class_getSubclasses(Class parentClass) {
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = (Class*) malloc(sizeof(Class) * numClasses);
    
    objc_getClassList(classes, numClasses);
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        do{
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil) {
            continue;
        }
        [result addObject:classes[i]];
    }
    free(classes);
    return result;
}

@implementation ARDatabaseManager{
    dispatch_queue_t worker;
}

static ARDatabaseManager *instance = nil;
static BOOL useCacheDirectory = YES;
static NSString *databaseName = DEFAULT_DBNAME;

static BOOL migrationsEnabled = YES;

+ (void)registerDatabase:(NSString *)aDatabaseName cachesDirectory:(BOOL)isCache {
    databaseName = [aDatabaseName copy];
    useCacheDirectory = isCache;
}

+ (id)sharedInstance {
    @synchronized(self){
        if(nil == instance){
            instance = [[ARDatabaseManager alloc] init];
        }
        return instance;
    }
}

- (id)init {
    self = [super init];
    if(nil != self){
#ifdef UNIT_TEST
        dbName = [[NSString alloc] initWithFormat:@"%@-test.sqlite", databaseName];
#else
        dbName = [[NSString alloc] initWithFormat:@"%@.sqlite", databaseName];
#endif
        NSString *storageDirectory = useCacheDirectory ? [self cachesDirectory] : [self documentsDirectory];
        dbPath = [[NSString alloc] initWithFormat:@"%@/%@", storageDirectory, dbName];
        DLog(@"%@", dbPath);
        [self createDatabase];
    }
    return self;
}

- (void)dealloc{
    [self closeConnection];
    [dbName release];
    [dbPath release];
    [super dealloc];
}

- (void)createDirForDBFile {
    NSString *name = [dbPath lastPathComponent];
    NSString *dir = [dbPath stringByReplacingOccurrencesOfString:name withString:@""];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)createDatabase {
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
        
        [self createDirForDBFile];
        
        [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
        if(!useCacheDirectory){
            [self skipBackupAttributeToFile:[NSURL fileURLWithPath:dbPath]];
        }
        [self openConnection];
        [self createTables];
        return;
    }
    [self openConnection];
    [self appendMigrations];
}

- (void)clearDatabase {
    NSArray *entities = class_getSubclasses([ActiveRecord class]);
    for(Class Record in entities){
        [Record performSelector:@selector(dropAllRecords)];
    }
}

- (void)createTables {
    NSArray *entities = class_getSubclasses([ActiveRecord class]);
    for(Class Record in entities){
        [self createTable:Record];
    }
}

- (void)createTable:(id)aRecord {
//    [self jsDoInOneThread:^{
        const char *sqlQuery = (const char *)[aRecord performSelector:@selector(sqlOnCreate)];
        [self executeSqlQuery:sqlQuery];
//    }];
}

- (void)appendMigrations {
    if(!migrationsEnabled){
        return;
    }
    NSArray *existedTables = [self tables];
    NSArray *describedTables = [self describedTables];
    for(NSString *table in describedTables){
        if(![existedTables containsObject:table]){
            [self createTable:NSClassFromString(table)];
        }else{
            Class Record = NSClassFromString(table);
            NSArray *existedColumns = [self columnsForTable:table];
            
            NSArray *describedProperties = [Record performSelector:@selector(columns)];
            NSMutableArray *describedColumns = [NSMutableArray array];
            for(ARColumn *column in describedProperties){
                [describedColumns addObject:column.columnName];
            }
            for(NSString *column in describedColumns){
                if(![existedColumns containsObject:column]){
                    const char *sql = (const char *)[Record performSelector:@selector(sqlOnAddColumn:)
                                                                 withObject:column];
                    [self executeSqlQuery:sql];
                }
            }
        }
    }
}

- (void)addColumn:(NSString *)aColumn onTable:(NSString *)aTable {
    
}

- (NSArray *)describedTables {
    NSArray *entities = class_getSubclasses([ActiveRecord class]);
    NSMutableArray *tables = [NSMutableArray arrayWithCapacity:entities.count];
    for(Class record in entities){
        [tables addObject:NSStringFromClass(record)];
    }
    return tables;
}

- (NSArray *)columnsForTable:(NSString *)aTableName {
    __block NSMutableArray *resultArray = nil;
    [self jsDoInOneThread:^{
        NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", [aTableName quotedString]];
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [sql UTF8String];
        if(SQLITE_OK == sqlite3_get_table(database,
                                          pszSql,
                                          &results,
                                          &nRows,
                                          &nColumns,
                                          NULL))
        {
            resultArray = [NSMutableArray arrayWithCapacity:nRows++];
            for(int i=0;i<nRows-1;i++){
                int index = (i + 1)*nColumns + 1;
                const char *pszValue = results[index];
                if(pszValue){
                    [resultArray addObject:[NSString stringWithUTF8String:pszValue]];
                }
            }
            sqlite3_free_table(results);
        }else
        {
            DLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
        }
    }];
    return resultArray;
}

//  select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'
- (NSArray *)tables {
    __block NSMutableArray *resultArray = nil;
    [self jsDoInOneThread:^{
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [@"select tbl_name from sqlite_master where type='table' and name not like 'sqlite_%'" UTF8String];
        if(SQLITE_OK == sqlite3_get_table(database,
                                          pszSql,
                                          &results,
                                          &nRows,
                                          &nColumns,
                                          NULL))
        {
            resultArray = [NSMutableArray arrayWithCapacity:nRows++];
            for(int i=0;i<nRows-1;i++){
                for(int j=0;j<nColumns;j++){
                    int index = (i+1)*nColumns + j;
                    [resultArray addObject:[NSString stringWithUTF8String:results[index]]];
                }
            }
            sqlite3_free_table(results);
        }else
        {
            DLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
        }
    }];
    return resultArray;
}

- (void)openConnection {
        sqlite3_unicode_load();
        if(SQLITE_OK != sqlite3_open([dbPath UTF8String], &database)){
            DLog(@"Couldn't open database connection: %s", sqlite3_errmsg(database));
        }
}

- (NSString *)tableName:(NSString *)modelName {
    return [[NSString stringWithFormat:@"%@", modelName] quotedString];
}

- (void)closeConnection {
        sqlite3_close(database);
        sqlite3_unicode_free();
}

- (NSNumber *)insertRecord:(NSString *)aRecordName withSqlQuery:(const char *)anSqlQuery {
    __block NSNumber *uid = nil;
//    [self jsDoInOneThread:^{
        [self executeSqlQuery:anSqlQuery];
        uid = [self getLastId:aRecordName];
//    }];
    return uid;
}

- (void)executeSqlQuery:(const char *)anSqlQuery {
    [self jsDoInOneThread:^{
    if(SQLITE_OK != sqlite3_exec(database, anSqlQuery, NULL, NULL, NULL)){
        DLog(@"Couldn't execute query %s : %s", anSqlQuery, sqlite3_errmsg(database));
    }
    }];
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSString *)cachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSArray *)allRecordsWithName:(NSString *)aName withSql:(NSString *)aSqlRequest{
    __block NSMutableArray *resultArray = nil;
    [self jsDoInOneThread:^{
        
        NSString *propertyName;
        id aValue;
        Class Record;
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [aSqlRequest UTF8String];
        if(SQLITE_OK == sqlite3_get_table(database,
                                          pszSql,
                                          &results,
                                          &nRows,
                                          &nColumns,
                                          NULL))
        {
            resultArray = [NSMutableArray arrayWithCapacity:nRows++];
            Record = NSClassFromString(aName);
            for(int i=0;i<nRows-1;i++){
                id record = [Record new];
                for(int j=0;j<nColumns;j++){
                    propertyName = [NSString stringWithUTF8String:results[j]];
                    int index = (i+1)*nColumns + j;
                    const char *pszValue = results[index];
                    
                    if(pszValue){
                        ARColumn *column = [Record performSelector:@selector(columnNamed:)
                                                        withObject:propertyName];
                        NSString *sqlData = [NSString stringWithUTF8String:pszValue];
                        aValue = [column.columnClass performSelector:@selector(fromSql:)
                                                          withObject:sqlData];
                    }else{
                        aValue = @"";
                    }
                    [record setValue:aValue forKey:propertyName];
                }
                [resultArray addObject:record];
                [record release];
            }
            sqlite3_free_table(results);
        }else
        {
            DLog(@"%@", aSqlRequest);
            DLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
        }
    }];
    return resultArray;
}

- (NSArray *)joinedRecordsWithSql:(NSString *)aSqlRequest {
    __block NSMutableArray *resultArray = nil;
    [self jsDoInOneThread:^{
        
        NSString *propertyName;
        NSString *header;
        id aValue;
        char **results;
        int nRows;
        int nColumns;
        const char *pszSql = [aSqlRequest UTF8String];
        if(SQLITE_OK == sqlite3_get_table(database,
                                          pszSql,
                                          &results,
                                          &nRows,
                                          &nColumns,
                                          NULL))
        {
            resultArray = [NSMutableArray arrayWithCapacity:nRows++];
            for(int i=0;i<nRows-1;i++){
                NSMutableDictionary *dictionary = [NSMutableDictionary new];
                NSString *recordName = nil;
                for(int j=0;j<nColumns;j++){
                    header = [NSString stringWithUTF8String:results[j]];
                    
                    recordName = [[header componentsSeparatedByString:@"#"] objectAtIndex:0];
                    propertyName = [[header componentsSeparatedByString:@"#"] objectAtIndex:1];
                    
                    Class Record = NSClassFromString(recordName);
                    
                    int index = (i+1)*nColumns + j;
                    const char *pszValue = results[index];
                    if(pszValue){
                        ARColumn *column = [Record
                                            performSelector:@selector(columnNamed:)
                                            withObject:propertyName];
                        NSString *sqlData = [NSString stringWithUTF8String:pszValue];
                        aValue = [column.columnClass performSelector:@selector(fromSql:)
                                                          withObject:sqlData];
                    }else{
                        aValue = @"";
                    }
                    id currentRecord = [dictionary valueForKey:recordName];
                    if(currentRecord == nil){
                        currentRecord = [[Record new] autorelease];
                        [dictionary setValue:currentRecord
                                      forKey:recordName];
                    }
                    [currentRecord setValue:aValue
                                     forKey:propertyName];
                    //                [dictionary setValue:aValue forKey:propertyName];
                }
                [resultArray addObject:dictionary];
                [dictionary release];
            }
            sqlite3_free_table(results);
        }else
        {
            DLog(@"%@", aSqlRequest);
            DLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
        }
    }];
    return resultArray;
}

- (NSInteger)countOfRecordsWithName:(NSString *)aName {
    __block NSInteger count = 0;
//    [self jsDoInOneThread:^{
        NSString *aSqlRequest = [NSString stringWithFormat:
                                 @"SELECT count(id) FROM %@",
                                 [self tableName:aName]];
        count = [self functionResult:aSqlRequest];
//    }];
    return count;
}

- (NSNumber *)getLastId:(NSString *)aRecordName {
    NSString *aSqlRequest = [NSString stringWithFormat:@"select MAX(id) from %@",
                             [aRecordName quotedString]];
    NSInteger res = [self functionResult:aSqlRequest];
    return [NSNumber numberWithInt:res];
}

- (NSInteger)functionResult:(NSString *)anSql {
    __block NSInteger resId = 0;
    [self jsDoInOneThread:^{
    char **results;
    int nRows;
    int nColumns;
    const char *pszSql = [anSql UTF8String];
    if(SQLITE_OK == sqlite3_get_table(database,
                                      pszSql,
                                      &results,
                                      &nRows,
                                      &nColumns,
                                      NULL))
    {
        if(nRows == 0 || nColumns == 0){
            resId = -1;
        }else{
            resId = [[NSString stringWithUTF8String:results[1]] integerValue];
        }
        
        sqlite3_free_table(results);
    }else
    {
        DLog(@"%@", anSql);
        DLog(@"Couldn't retrieve data from database: %s", sqlite3_errmsg(database));
    }
    }];
    return resId;
}

- (void)skipBackupAttributeToFile:(NSURL *)url {
    u_int8_t b = 1;
    setxattr([[url path] fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

+ (void)disableMigrations {
    migrationsEnabled = NO;
}

#pragma mark jacky.song enhance

-(void)jsDoInOneThread:(dispatch_block_t)block{
    if (!worker) {
        worker = dispatch_queue_create("__jackysong__enhance__ARDatabaseManager__worker", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_sync(worker, block);
}

@end
