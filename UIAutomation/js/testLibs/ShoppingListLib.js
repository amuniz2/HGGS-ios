var shoppingListTestHasBeenSetup = false;
var testStoreName = "UI Automation Test Store";
var testStoreWithNonExistingGrocerySections = "";

function createOrSelectTestStoreForShoppingListTest(target, app, storeName)
{
	var mainWindow = new MainWindow(target, app);
		
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), storeName) )
	{
		var masterListData = new testMasterListData();
		var currentListData = new testCurrentListData();
		var editStoreWindow = createStore(target, app, storeName);		

		createGrocerySections(target, app, storeName, new Hash(1, ['produce','new grocery section in new aisle'], 5, ['first item in aisle 5']));		
		createMasterListItems(target, app, storeName, [masterListData.shoppingListItem2_updated, masterListData.groceryItemInProduceSection_updated, masterListData.shoppingListItem4, masterListData.shoppingListItem6]);
		
		editStoreWindow.BackButton().tap();
		editStoreWindow.BackButton().waitForInvalid();
	 	mainWindow.StorePicker().wheels()[0].selectValue(storeName);
		prepareShoppingList(target, app, storeName, 
			[currentListData.shoppingListItem2_updated, 
			/*currentListData.shoppingListItem3*/ currentListData.groceryItemInProduceSection_updated, 
			currentListData.shoppingListItem4, 
			currentListData.shoppingListItem6],
			[currentListData.shoppingListItem5_NotAddedToMaster] );
	}
		
 	mainWindow.StorePicker().wheels()[0].selectValue(storeName);
	return mainWindow;
}

function createMasterListWithItemWhoseSectionIsNotDefined(target, app)
{
	var mainWindow = new MainWindow(target, app);
	var data = new testMasterListForGroceryStoreWithUnknownGrocerySections();
	testStoreWithNonExistingGrocerySections = createStoreWithNonExistingGrocerySectionAssignedToGroceryItem(target, app)
	var editStoreWindow = new EditStoreWindow(target, app);
	
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
 	mainWindow.StorePicker().wheels()[0].selectValue(testStoreWithNonExistingGrocerySections);
	mainWindow.EditStoreButton().tap();
	mainWindow.EditStoreButton().waitForInvalid();
	
	editStoreWindow.EditMasterListButton().tap();
	editStoreWindow.EditMasterListButton().waitForInvalid();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreWithNonExistingGrocerySections);

	editMasterListWindow.AddItemButton().tap();
	editMasterListWindow.AddItemButton().waitForInvalid();
 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	editItemWindow.NameTextView().setValue(data.groceryItem1.Name );
	editItemWindow.NotesTextView().setValue(data.groceryItem1.Notes);
	editItemWindow.QuantityTextField().setValue(data.groceryItem1.Quantity);
	editItemWindow.QuantityUnitTextField().setValue(data.groceryItem1.Unit);
	
	dismissKeyboardIfPresent(app);

	editItemWindow.ItemGrocerySection().setValue(data.groceryItem1.Section);
	editItemWindow.DoneButton().tap();
	editItemWindow.DoneButton().waitForInvalid();
	
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();
	
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();			
	
}
function setupShoppingListTest(target, app)
{
	if (shoppingListTestHasBeenSetup)
		return;

	createMasterListWithItemWhoseSectionIsNotDefined(target, app);

	var mainWindow = new MainWindow(target, app);
 	mainWindow.StorePicker().wheels()[0].selectValue(testStoreWithNonExistingGrocerySections);
	
	var data = new testCurrentListForGroceryStoreWithUnknownGrocerySections();
	prepareShoppingList(target, app, testStoreWithNonExistingGrocerySections, [data.groceryItem1],
		[] );

	var mainWindow = createOrSelectTestStoreForShoppingListTest(target, app, testStoreName);		
	
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
	testShoppingListWindowValidity(shoppingListWindow, [data.shoppingListItem2, data.shoppingListItem3, data.shoppingListItem4, data.shoppingListItem1, data.shoppingListItem6] );

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

	exitShoppingListTest (target, app);
	 
	expectedAlertMessage = "Prepare Shopping List";

	var mainWindow = new MainWindow(target, app);
 	mainWindow.StorePicker().wheels()[0].selectValue(testStoreName);

	mainWindow.PrepareGroceryListButton().tap();
	mainWindow.PrepareGroceryListButton().waitForInvalid(); 

	var yesButton = app.alert().buttons()["Yes"];
	yesButton.tap();
	yesButton.waitForInvalid();
		 
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, 
		[	data.shoppingListItem2_updated, 
			data.groceryItemInProduceSection, 
		//	data.shoppingListItem1, 
			data.shoppingListItem4, 
			data.shoppingListItem6] );
}

function testVerifyShoppingListCreated_WhenGrocerySectionsDoNotExist(target, app)
{

	var data = new testShoppingListDataWithUnknownGrocerySection();
	var storeName = testStoreWithNonExistingGrocerySections;

	var mainWindow = new MainWindow(target, app);
 	mainWindow.StorePicker().wheels()[0].selectValue(storeName);
	mainWindow.GoShoppingButton().tap();
	mainWindow.GoShoppingButton().waitForInvalid();
	 
	var shoppingListWindow = new ShoppingListWindow(target, app, storeName);
	testShoppingListWindowValidity(shoppingListWindow, [data.shoppingItem1] );

	shoppingListWindow.BackButton().tap();
	shoppingListWindow.BackButton().waitForInvalid();	

}

