var prepareShoppingListTestHasBeenSetup = false;
var testStoreName = "UI Automation Test Store";
var testStoreWithNonExistingGrocerySections = "";

function createOrSelectTestStoreForPrepareShoppingList(target, app, storeName)
{
	var mainWindow = new MainWindow(target, app);
		
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), storeName) )
	{
		var data = new testMasterListData();
		var editStoreWindow = createStore(target, app, storeName);	
		var dataWithNonExistingSections = new testMasterListForGroceryStoreWithUnknownGrocerySections();	

		createGrocerySections(target, app, storeName, new Hash(1, ['produce', 'new grocery section in new aisle'], 5, ['first item in aisle 5']));
		createMasterListItems(target, app, storeName, [data.groceryItem2InNewSection, data.groceryItemInProduceSection]);

		testStoreWithNonExistingGrocerySections = createStoreWithNonExistingGrocerySectionAssignedToGroceryItem(target, app)

		editStoreWindow.BackButton().tap();
		editStoreWindow.BackButton().waitForInvalid();

	}
 	mainWindow.StorePicker().wheels()[0].selectValue(storeName);
	return mainWindow;
}

function setupPrepareShoppingListTest(target, app)
{
	if (prepareShoppingListTestHasBeenSetup)
		return;

	var mainWindow = createOrSelectTestStoreForPrepareShoppingList(target, app, testStoreName);
	
	mainWindow.PrepareGroceryListButton().tap();
	mainWindow.PrepareGroceryListButton().waitForInvalid();

	prepareShoppingListTestHasBeenSetup = true;
}

function exitPrepareShoppingListTest(target, app)
{
	if (!prepareShoppingListTestHasBeenSetup)
		return;

	var editShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	editShoppingListWindow.BackButton().tap();
	editShoppingListWindow.BackButton().waitForInvalid();
	target.delay(2); // give to time for the io operation to complete
	prepareShoppingListTestHasBeenSetup = false;	
}

function testAddShoppingItem(target, app)
{
	setupPrepareShoppingListTest(target, app)
	var data = new testCurrentListData();
	
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.groceryItem2InNewSection, data.groceryItemInProduceSection] );
	
	prepareShoppingListWindow.AddItemButton().tap();
	prepareShoppingListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	testEditCurrentItemWindowValidity(editItemWindow, data.defaultGroceryItem );
	
	editItemWindow.NameTextView().setValue(data.shoppingGroceryItem1.Name );
	editWithShoppingItemValues(app, editItemWindow, data.shoppingGroceryItem1);

	var itemCell = prepareShoppingListWindow.GroceryItemCell(data.shoppingGroceryItem1);
	if (itemCell.IncludeSwitch().value() != data.shoppingGroceryItem1.Selected)
		itemCell.IncludeSwitch().tap();
	 
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.groceryItem2InNewSection, data.groceryItemInProduceSection, data.shoppingGroceryItem1] );
}

function testAddShoppingItemAndAssignToNewGrocerySection(target, app)
{
	var data = new testCurrentListData();

	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);

	prepareShoppingListWindow.AddItemButton().tap();
	prepareShoppingListWindow.AddItemButton().waitForInvalid();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);

	editItemWindow.NameTextView().setValue(data.shoppingListItem6.Name );
	setShoppingItemValuesInEditWindow(app, editItemWindow, data.shoppingListItem6);
	//editWithShoppingItemValues(app, editItemWindow, data.shoppingListItem6);

	if (app.keyboard().isValid())
	{
		app.keyboard().buttons()["Return"].tap();
		app.keyboard().buttons()["Return"].waitForInvalid();
	}

	editItemWindow.SelectGrocerySectionButton().tap();
	editItemWindow.SelectGrocerySectionButton().waitForInvalid();	
	 								
	var selectGrocerySectionWindow = new SelectGrocerySectionWindow(target, app);	 
	 
	selectGrocerySectionWindow.InsertInAisleButton(0).tap();
	selectGrocerySectionWindow.InsertInAisleButton(0).waitForInvalid();
	 
	var addGrocerySectionWindow = new AddGrocerySectionWindow(target, app);
	addGrocerySectionWindow.SectionNameTextField().setValue(data.shoppingListItem6.Section);  // 'produce' section added as a result..
	addGrocerySectionWindow.AisleNumberTextField().setValue(data.shoppingListItem6.Aisle);
	addGrocerySectionWindow.AddSectionButton().tap(); 
	addGrocerySectionWindow.AddSectionButton().waitForInvalid();
	
	target.pushTimeout(1);
	assertTrue(editItemWindow.DoneButton().isValid(), "Did not return to Edit Item Window after assigning new grocery section"); 
	target.popTimeout();
	testEditItemWindowValidity(editItemWindow, data.shoppingListItem6 );
	
	 editItemWindow.DoneButton().tap();
	 editItemWindow.DoneButton().waitForInvalid();
	 
	 testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.groceryItem2InNewSection, data.groceryItemInProduceSection, data.shoppingGroceryItem1, data.shoppingListItem6]);
}

function testSelectItemsAndSetQuantities(target, app)
{
	setupPrepareShoppingListTest(target, app)
	var data = new testCurrentListData();
	 
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	
	var itemCell = prepareShoppingListWindow.GroceryItemCell(data.shoppingGroceryItem1);	
	itemCell.IncrementQuantityButton().tap();
	if (itemCell.IncludeSwitch().value() != data.shoppingListItem1.Selected)
		itemCell.IncludeSwitch().tap();
	 
	itemCell = prepareShoppingListWindow.GroceryItemCell(data.groceryItemInProduceSection);
	itemCell.DecrementQuantityButton().tap();
	if (itemCell.IncludeSwitch().value() != data.shoppingListItem3.Selected)
		itemCell.IncludeSwitch().tap();

	itemCell = prepareShoppingListWindow.GroceryItemCell(data.groceryItem2InNewSection);
	if (itemCell.IncludeSwitch().value() != data.shoppingListItem2.Selected)
		itemCell.IncludeSwitch().tap();
	 
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem6] );	
}


function testCancelEditShoppingItem(target, app)
{
	setupPrepareShoppingListTest(target, app)
	var data = new testCurrentListData();

	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	var itemCell = prepareShoppingListWindow.GroceryItemCell(data.shoppingListItem2)
	itemCell.tap();
	itemCell.waitForInvalid();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);	 
	cancelWithShoppingItemValues(app, editItemWindow, data.shoppingListItem2_updated);
	 	 
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem6] );	
}

function testEditShoppingItem(target, app)
{
	setupPrepareShoppingListTest(target, app)
	var data = new testCurrentListData();

	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	var itemCell = prepareShoppingListWindow.GroceryItemCell(data.shoppingListItem2)
	itemCell.tap();
	itemCell.waitForInvalid();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);
	testEditCurrentItemWindowValidity(editItemWindow, data.shoppingListItem2 );
	 
	editWithShoppingItemValues(app, editItemWindow, data.shoppingListItem2_updated);
	 	 
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2_updated, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem6] );	
}

function testCannotAddShoppingItemWithNoName(target, app)
{
	setupPrepareShoppingListTest(target, app)
	var data = new testCurrentListData();
	
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	prepareShoppingListWindow.AddItemButton().tap();
	prepareShoppingListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	expectedAlertMessage = "Name Required"
	editWithShoppingItemValues(app, editItemWindow, data.shoppingListItem4);
	
	var okayButton = app.alert().buttons()["Okay"];
	okayButton.tap(); 
	okayButton.waitForInvalid(); 
	
	editItemWindow.NameTextView().setValue(data.shoppingListItem4.Name );
	app.keyboard().buttons()["Return"].tap();
	app.keyboard().buttons()["Return"].waitForInvalid();
	
	editItemWindow.DoneButton().tap();
	editItemWindow.DoneButton().waitForInvalid();
	 	
	// items are in same grocery section, so should be in alpha order  
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2_updated, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem4, data.shoppingListItem6] );
	
}

function testCannotSaveShoppingItemWithDuplicateName(target, app)
{

	setupPrepareShoppingListTest(target, app);
		var data = new testCurrentListData();
	
		var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
		var itemCell = prepareShoppingListWindow.GroceryItemCell(data.shoppingListItem3)
		itemCell.tap();
		itemCell.waitForInvalid();
	 
		var editItemWindow = new EditGroceryItemWindow(target, app);
		editItemWindow.NameTextView().setValue(data.shoppingListItem1.Name);

		if (app.keyboard().isValid())
		{
			app.keyboard().buttons()["Return"].tap();
			app.keyboard().buttons()["Return"].waitForInvalid();
		}
		expectedAlertMessage = "Duplicate Item"
		editItemWindow.DoneButton().tap();
		editItemWindow.DoneButton().waitForInvalid();
			
		var okayButton = app.alert().buttons()["Okay"];
		okayButton.tap(); 
		okayButton.waitForInvalid(); 
	 	
		editItemWindow.CancelButton().tap();
		editItemWindow.CancelButton().waitForInvalid();
	 
		// items are in same grocery section, so should be in alpha order  
		testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2_updated, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem4, data.shoppingListItem6] );
	
}

function testAddItemThatIsNotSavedToMasterList(target, app)
{
	//item 4 is set to save to master list
	//item 5 is not -	shoppingListItem5_NotAddedToMaster
	setupPrepareShoppingListTest(target, app);
	var data = new testCurrentListData();
	
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	
	prepareShoppingListWindow.AddItemButton().tap();
	prepareShoppingListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	
	editItemWindow.NameTextView().setValue(data.shoppingListItem5_NotAddedToMaster.Name );
	editWithShoppingItemValues(app, editItemWindow, data.shoppingListItem5_NotAddedToMaster);

	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2_updated, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem4, data.shoppingListItem5_NotAddedToMaster, data.shoppingListItem6] );

		 
}

function testSaveAndLoadPreparedShoppingList(target, app)
{
	var data = new testCurrentListData();

	exitPrepareShoppingListTest(target, app); // saves ...
 	setupPrepareShoppingListTest(target, app) // loads...
	
	var prepareShoppingListWindow = new PrepareShoppingListWindow(target, app, testStoreName);
	testPrepareShoppingListWindowValidity(prepareShoppingListWindow, [data.shoppingListItem2_updated, data.shoppingListItem3, data.shoppingListItem1, data.shoppingListItem4, data.shoppingListItem5_NotAddedToMaster, data.shoppingListItem6] );

	
}

function testVerifyMasterListIncludesItemsAdded(target, app)
{
	var data = new testMasterListData();

	// return to main view
	exitPrepareShoppingListTest(target, app);	 
	 	 
	var mainWindow = new MainWindow(target, app);
	 
	mainWindow.StorePicker().wheels()[0].selectValue(testStoreName)
	mainWindow.EditStoreButton().tap();
	mainWindow.EditStoreButton().waitForInvalid();
	
	var editStoreWindow = new EditStoreWindow(target, app); 
	editStoreWindow.EditMasterListButton().tap();
	editStoreWindow.EditMasterListButton().waitForInvalid();
	 
	var editMasterListWindow = new MasterListWindow(target, app, testStoreName); 
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2InNewSection, data.groceryItemInProduceSection, data.shoppingListItem1, data.shoppingListItem4, data.shoppingListItem6]);
	 
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();	 

	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
}
