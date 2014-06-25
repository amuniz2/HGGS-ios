#import "testLibs/TuneupJs/tuneup.js"
#import "testLibs/windowDefinitions.js"
#import "testLibs/commonWindowFunctions.js"
#import "testLibs/windowTests.js"

#import "testLibs/CRUD_StoreLib.js"

test("StoreList_View", function(target, app) {
	 testInitialScreen(target, app);	 
});


test ("StoreList_AddNewStore", function(target, app)
{
	  testAddNewStore(target, app);
});

test("StoreList_RenameStore", function(target, app) {
	 testEditRenameMyNewStore(target, app);
});


test("Store_DeleteStore", function(target, app) {
	testDeleteMyGroceryStore(target, app);	
});
