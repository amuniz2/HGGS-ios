#import "testLibs/tuneupJs/tuneup.js"
#import "testLibs/windowDefinitions.js"
#import "testLibs/commonWindowFunctions.js"
#import "testLibs/windowTests.js"
#import "testLibs/utils.js"

#import "testLibs/ShoppingListLib.js"

test("ShoppingList_VerifyShoppingListCreated", function(target, app)
{	
	testVerifyShoppingListCreated(target, app);
});

test("ShoppingList_CheckItemOff", function(target, app)
{
	 testCheckItemOff(target, app);
	 
});

test("ShoppingList_VerifyNewListCreatedAfterShopping", function(target, app)
{
	testVerifyNewListCreatedAfterShopping(target, app);
});
