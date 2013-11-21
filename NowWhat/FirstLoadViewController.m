//
//  FirstLoadViewController.m
//  NowWhat
//
//  Created by Rich Humphrey on 11/21/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "FirstLoadViewController.h"

@interface FirstLoadViewController ()

@end

@implementation FirstLoadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



// *********************
// Database Methods


-(IBAction) importOldDatabase {
    
    sqlite3 *db;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"database.sql"];
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: filePath ] == NO) {
    
        NSLog(@"No database file exists, yay");
        return;
        
        
    }
    
    
    //—-open database—-
    if (sqlite3_open([filePath UTF8String], &db) != SQLITE_OK ) {
	    sqlite3_close(db);
	    NSAssert(0, @"Database failed to open.");
	}
    
    //—-retrieve rows—-
    NSString *qsql = [NSString stringWithFormat:@"SELECT eventID, eventTime, eventText, eventNotes FROM EventList"];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *field1Str;
            NSString *field2Str;
            NSString *field3Str;
            NSString *field4Str;
            
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            field1Str = [[NSString alloc] initWithUTF8String: field1];
			
            char *field2 = (char *) sqlite3_column_text(statement, 1);
            field2Str = [[NSString alloc] initWithUTF8String: field2];
			
            char *field3 = (char *) sqlite3_column_text(statement, 2);
            field3Str = [[NSString alloc] initWithUTF8String: field3];
			
            
			char *field4 = (char *) sqlite3_column_text(statement, 3);
            field4Str = [[NSString alloc] initWithUTF8String: field4];
            
            NSString *str = [NSString stringWithFormat:@"%@ - %@ - %@ - '%@'", field1Str, field2Str, field3Str, field4Str];
            NSLog(@"%@", str);
			
            /*
            [dayData addObject:[eventClass eventWithID:field1Str
                                                  date:thisDate
                                          dateNSFormat:eventNSDate
                                                  text:field3Str
                                                  time:field2Str
                                                 notes:field4Str]];
            */
                             
        }
		
        //—-deletes the compiled statement from memory—-
        sqlite3_finalize(statement);
    }
    
    
    //—-retrieve rows—-
    NSString *sqlTemplateEvents = [NSString stringWithFormat:@"SELECT eventTime, eventText, eventNotes FROM TemplateEvents"];
    
    sqlite3_stmt *statementTemplateEvents;
    //templateEvents =[[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2( db, [sqlTemplateEvents UTF8String], -1, &statementTemplateEvents, nil) == SQLITE_OK) {
        while (sqlite3_step(statementTemplateEvents) == SQLITE_ROW) {
            
            NSString *field1Str;
            NSString *field2Str;
            NSString *field3Str;
            char *field1;
            char *field2;
            char *field3;
            
            field1 = (char *) sqlite3_column_text(statementTemplateEvents, 0);
            field1Str = [[NSString alloc] initWithUTF8String: field1];
			
            field2 = (char *) sqlite3_column_text(statementTemplateEvents, 1);
            field2Str = [[NSString alloc] initWithUTF8String: field2];
			
            field3 = (char *) sqlite3_column_text(statementTemplateEvents, 2);
            field3Str = [[NSString alloc] initWithUTF8String: field3];
			
            
            NSString *str = [[NSString alloc] initWithFormat:@"got template from DB: %@ - %@ - %@",
							 field1Str, field2Str, field3Str];
            
             NSLog(@"%@", str);
            /*
            [templateEvents addObject:[eventClass eventWithID:nil
                                                         date:nil
                                                 dateNSFormat:nil
                                                         text:field2Str
                                                         time:field1Str
                                                        notes:field3Str]];
            */
        
        }
        
        sqlite3_finalize(statementTemplateEvents);
    }
    
    
    
    //—-retrieve rows—-
    NSString *sqlTemplates = [NSString stringWithFormat:@"SELECT templateID,templateName,templateListOrder FROM TemplateList"];
    sqlite3_stmt *statementTemplates;
    
    if (sqlite3_prepare_v2( db, [sqlTemplates UTF8String], -1, &statementTemplates, nil) == SQLITE_OK) {
        while (sqlite3_step(statementTemplates) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statementTemplates, 0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
			
            char *field2 = (char *) sqlite3_column_text(statementTemplates, 1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
			
            char *field3 = (char *) sqlite3_column_text(statementTemplates, 2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
			
            
            NSString *str = [[NSString alloc] initWithFormat:@"got template from DB: %@ - %@ - %@",
							 field1Str, field2Str, field3Str];
            
            NSLog(@"%@", str);
            
			/*
            thisTemplate = [templateClass templateWithID:field1Str
                                                    name:field2Str
                                                   order:[field3Str intValue]];
            */
            
        }
        
		
        //—-deletes the compiled statement from memory—-
        //sqlite3_reset(statement);
        sqlite3_finalize(statementTemplates);
    }
    
    
    
    sqlite3_close(db);
    
}

    


@end
