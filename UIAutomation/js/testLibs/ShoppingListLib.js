var shoppingListTestHasBeenSetup = false;
var testStoreName = "UI Automation Test Store";


function createOrSelectTestStoreForShoppingListTest(target, app, storeName)
{
	var mainWindow = new MainWindow(target, app);
		
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), storeName) )
	{
		var masterListData = new testMasterListData();
		var currentListData = new testCurrentListData();
		var editStoreWindow = createStore(target, app, storeName);		

		createGrocerySections(target, app, storeName, new Hash(1, ['produce','new grocery section in new aisle'], 5, ['first item in aisle 5']));		
		createMasterListItems(target, app, storeName, [masterListData.groceryItem2InNewSection, masterListData.groceryItemInProduceSection, masterListData.shoppingListItem1, masterListData.shoppingListItem4]);
		
		editStoreWindow.BackButton().tap();
		editStoreWindow.BackButton().waitForInvalid();
	 	mainWindow.StorePicker().wheels()[0].selectValue(storeName);
		prepareShoppingList(target, app, storeName, 
			[currentListData.shoppingListItem2_updated, 
			/*currentListData.shoppingListItem3*/ currentListData.groceryItemInProduceSection, 
			currentListData.shoppingListItem1, 
			currentListData.shoppingListItem4],
			[currentListData.shoppingListItem5_NotAddedToMaster] );
	}
 	mainWindow.StorePicker().wheels()[0].selectValue(storeName);
	return mainWindow;
}

function setupShoppingListTest(target, app)
{
	if (shoppingListTestHasBeenSetup)
		return;

	var mainWindow = createOrSelectTestStoreForShoppingListTest(target, app, testStoreName);
	
	UIALogger.logDebug("Clicking on 'Go Shopping'");
	
	mainWindow.GoShoppingButton().tap();
	mainWindow.GoShoppingButton().waitForInvalid();

	shoppingListTestHasBeenSetup = true;
}

function exitShoppingListTest(target, app)
{
	if (!shoppingListTestHasBeenSetup)
		return;

	var shoppingListWindow = new ShoppingListWindow(target, app, testStoreName);
	shoppingListWindow.BackButton().tap();
	shoppingListWindow.BackButton().waitForInvalid();	
	
	shoppingListTestHasBeenSetup = false;	
}

function testVerifyShoppingListCreated(target, app)
{
	setupShoppingListTest(target, app)

	var data = new ShoppingListData();
	 
	var shoppingListWindow = new ShoppingListWindow(target, app, testStoreName);
	testShoppingListWindowValidity(shoppingListWindow, [data.shoppingListItem0, data.shoppingListItem1, data.shoppingListItem2, data.shoppingListItem3, data.shoppingListItem4] );
	exitShoppingListTest (target, app);
}

function testCheckItemOff(target, app)
{
	UIALogger.logWarning("Not Implemented, due to inability to tap an invisible button.")
	
	/*
	var data = new ShoppingListData();
	var shoppingListWindow = new ShoppingListWindow(target, app, testStoreName);
	var itemCell = shoppingListWindow.GroceryItemCell(data.shoppingListItem2).tap();
	  
 	exitShoppingListTest (target, app);
	*/
}

function testVerifyNewListCreatedAfterShopping(target, app)
{
	var data = new testCurrentListData();
	 
	var mainWindow = new MainWindow(target, app);
	mainWindow.PrepareGroceryListButton().tap();
	mainWindow.PrepareGroceryListButton().waitForInvalid(); 
		 
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, 
		[	data.shoppingListItem2_updated, 
			data.groceryItemInProduceSection, 
			data.shoppingListItem1, 
			data.shoppingListItem4] );
	exitShoppingListTest (target, app);
}


