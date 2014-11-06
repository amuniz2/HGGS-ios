//#import "testLibs/Tuneupjs/test.js"
#import "testLibs/tuneupJs/tuneup.js"
#import "testLibs/commonWindowFunctions.js"
#import "testLibs/windowTests.js"
#import "testLibs/utils.js"

#import "testLibs/CRUD_GrocerySectionLib.js"

test("GrocerySections_AddGrocerySectionInSameAisle", function(target, app)
{		
	testAddGrocerySectionInSameAisle(target, app);

});

test("GrocerySections_AddGrocerySectionInNewAisle", function(target, app)
{
	testAddGrocerySectionInNewAisle(target, app);
});

test("GrocerySections_CannotInsertGrocerySectionWithNoName", function(target, app)
{
	testCannotInsertGrocerySectionWithNoName(target, app);
});

test("GrocerySections_CannotInsertGrocerySectionWithDuplicateName", function(target, app)
{
	testCannotInsertGrocerySectionWithDuplicateName(target, app); 
});	 

test("GrocerySections_DeleteSectionInAisle", function(target, app)
{
	testDeleteSectionInAisle(target, app);
}); 

test("GrocerySections_DeleteLastSectionInAisle", function(target, app)
{
	testDeleteLastSectionInAisle(target, app);
});

test("GrocerySections_UpdateSectionAisle", function(target, app)
{
	 testUpdateSectionAisle(target, app);
});

test("GrocerySections_UpdateSectionName", function(target, app)
{
	 testUpdateSectionName(target, app);
}); 	 

test("GrocerySections_CannotAddSectionWithNoName", function(target, app)
{ 
	UIALogger.logWarning("Not Implemented");
});

test("GrocerySections_CannotAddSectionWithDupplicateName", function(target, app)
{
	UIALogger.logWarning("Not Implemented");
});

test("GrocerySections_SaveAndLoadAisleConfig", function(target, app)
{
	testSaveAndLoadAisleConfig(target, app);
});
