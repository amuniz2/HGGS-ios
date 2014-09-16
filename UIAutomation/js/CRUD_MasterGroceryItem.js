#import "testLibs/tuneupJs/tuneup.js"
#import "testLibs/commonWindowFunctions.js"
#import "testLibs/windowTests.js"

#import "testLibs/CRUD_MasterGroceryItemLib.js"

/*
UIATarget.onAlert = function onAlert(alert) {

    var title = alert.name();
	
    if (title == expectedAlertMessage) {

        //alert.buttons()["Yes"].tap();
		expectedAlertMessage = "";
        return true;  //alert handled, so bypass the default handler

    }
	else
		UIALogger.logWarning("Alert with title '" + title + "' encountered.");
	
    return false;
}
*/
test("MasterList_AddItem", function(target, app)
{		
	testAddItemToMasterList(target, app);
});

test("MasterList_EditItem", function(target, app)
{		
	 testEditItemInMasterList(target, app);
});


test("MasterList_ChangeNameOfExistingItem", function(target, app)
{		
	testChangeNameOfExistingItemInMasterList(target, app);
});

test("MasterList_CannotAddItemWithNoName", function(target, app)
{		
	testCannotAddItemWithNoNameToMasterList(target, app);
});


test("MasterList_CannotAddItemWithSameName", function(target, app)
{	
	testCannotAddItemWithSameNameToMasterList(target, app); 
});

test("MasterList_DeleteItem", function(target, app)
{
	testDeleteItemFromMasterList(target, app);
});

test("MasterList_CreateAndAssignGrocerySectionToGroceryItem", function(target, app)
{
	testCreateAndAssignGrocerySectionToGroceryItemInMasterList(target, app);
});

test("MasterList_NewGrocerySectionAddedToAisleConfig", function(target, app)
{
	testNewGrocerySectionAddedToAisleConfig(target, app);
});

test("MasterList_AssignExistingGrocerySectionToGroceryItem", function(target, app)
{
	testAssignExistingGrocerySectionToGroceryItemInMasterList(target, app);
});

test("MasterList_CannotAddSectionWithNoNameWhenAssigningSection", function(target, app)
{ 
	 UIALogger.logWarning("Not Implemented");
});
test("MasterList_CannotAddSectionWithDupplicateNameWhenAssigningSection", function(target, app)
{
	 UIALogger.logWarning("Not Implemented");
});

test("MasterList_SaveAndLoad", function(target, app)
{
	testSaveAndLoadMasterList(target, app);
});

test("MasterList_AutoAddOfAssignedUnknownGrocerySection", function(target, app)
{
	testAutoAddOfAssignedUnknownGrocerySection(target, app)
});
