#import "testLibs/Tuneupjs/test.js"
#import "testLibs/commonWindowFunctions.js"
#import "testLibs/windowTests.js"
#import "testLibs/PrepareShoppingListLib.js"


test("PrepareShoppingList_AddItem", function(target, app)
{		
	 testAddShoppingItem(target, app);
});

test("PrepareShoppingList_AddItemInNewSection", function(target, app)
{
	 testAddShoppingItemAndAssignToNewGrocerySection(target, app);
});

test("PrepareShoppingList_SelectItemsAndSetQuantities", function(target, app)
{
	testSelectItemsAndSetQuantities(target, app);
});

test("PrepareShoppingList_CancelEditShoppingItem", function(target, app)
{
	testCancelEditShoppingItem(target, app);
});

test("PrepareShoppingList_EditShoppingItem", function(target, app)
{
	testEditShoppingItem(target, app);
});

test("PrepareShoppingList_CannotAddItemWithNoName", function(target, app)
{
	testCannotAddShoppingItemWithNoName(target, app);
});

test("PrepareShoppingList_CannotSaveItemWithDuplicateName", function(target, app)
{
	testCannotSaveShoppingItemWithDuplicateName(target, app);
});

test("PrepareShoppingList_AddItemThatIsNotSavedToMasterList", function(target, app)
{
	testAddItemThatIsNotSavedToMasterList(target, app);
});


test("PrepareShoppingList_SaveAndLoad", function(target, app)
{
	 testSaveAndLoadPreparedShoppingList(target, app);
});

test("PrepareShoppingList_VerifyMasterListIncludesItemsAdded", function(target, app)
{
	testVerifyMasterListIncludesItemsAdded(target, app);
});

test("PrepareShoppingList_VerifyNewListCreatedAfterShopping", function(target, app)
{
	 UIALogger.logWarning("Not Implemented.");
});
