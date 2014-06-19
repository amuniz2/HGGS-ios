#import "tuneupJs/tuneup.js"
#import "windowDefinitions.js"
#import "windowTests.js"

function testPrepareGroceryList(target, app)
{
	 var mainWindow = new MainWindow(target,app);
	 var storeName= "My Grocery Store"
	 
	 mainWindow.StorePicker().wheels()[0].selectValue(storeName);
	 
	 mainWindow.PrepareGroceryListButton().tap();
	 mainWindow.PrepareGroceryListButton().waitForInvalid();
	 
	 var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app);
	 assertTrue(prepareShoppingListWindow.BackButton());
	 prepareShoppingListWindow.BackButton().tap();
	 prepareShoppingListWindow.BackButton().waitForInvalid();
	 
	 //testMainWindowValidity(mainWindow, "My Grocery Store", "My Favorite Grocery Store");
	testMainWindowValidity(mainWindow, "My Grocery Store");
}
