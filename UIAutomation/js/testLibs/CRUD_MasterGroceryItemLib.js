#import "tuneupJs/tuneup.js"
#import "commonWindowFunctions.js"
#import "windowTests.js"

var masterListTestHasBeenSetup = false;
var testStoreName = "UI Automation Test Store";

function setupMasterListTest(target, app)
{
	if (masterListTestHasBeenSetup)
		return;
	
	var mainWindow = new MainWindow(target, app);
	var editStoreWindow = new EditStoreWindow(target, app);
	
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), testStoreName) )
	{
		createStore(target, app, testStoreName);		
		createGrocerySections(target, app, testStoreName, new Hash(1, ['new grocery section in new aisle'], 5, ['first item in aisle 5']));
	}
	else
	{
		mainWindow.StorePicker().wheels()[0].selectValue(testStoreName);	
		mainWindow.EditStoreButton().tap();
		mainWindow.EditStoreButton().waitForInvalid();
		
	}
	editStoreWindow.EditMasterListButton().tap();
	editStoreWindow.EditMasterListButton().waitForInvalid();

	masterListTestHasBeenSetup = true;
}

function exitMasterListTest(target, app)
{
	if (!masterListTestHasBeenSetup)
		return;

	editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();
	
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
		
	masterListTestHasBeenSetup = false;	
}

function testAddItemToMasterList(target, app)
{
	setupMasterListTest(target, app)
	var data = new testMasterListData();
	
	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.AddItemButton().tap();
	editMasterListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	testEditMasterItemWindowValidity(editItemWindow, data.defaultGroceryItem );
	
	editItemWindow.NameTextView().setValue(data.groceryItem1.Name );
	editWithMasterItemValues(app, editItemWindow, data.groceryItem1);
	
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem1]);
	
}
function testEditItemInMasterList(target, app)
{
	setupMasterListTest(target, app)
	var data = new testMasterListData();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.MasterListView().cells()[data.groceryItem1.MasterItemCellName()].tap();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);
	testEditMasterItemWindowValidity(editItemWindow, data.groceryItem1 );
	 
	editItemWindow.NameTextView().setValue(data.updatedGroceryItem1.Name );
	editWithMasterItemValues(app, editItemWindow, data.updatedGroceryItem1);
	 	 
	testMasterListWindowValidity(editMasterListWindow, [data.updatedGroceryItem1]);
}

function testChangeNameOfExistingItemInMasterList(target, app)
{
	var data = new testMasterListData();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.MasterListView().cells()[data. updatedGroceryItem1.MasterItemCellName()].tap();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);	
	editItemWindow.NameTextView().setValue(data.item1WithChangedName.Name );
	
	app.keyboard().buttons()["Return"].tap();
	app.keyboard().buttons()["Return"].waitForInvalid();
	
	editItemWindow.DoneButton().tap();
	editItemWindow.DoneButton().waitForInvalid();
	 
	testMasterListWindowValidity(editMasterListWindow, [data.item1WithChangedName]);	
}

function testCannotAddItemWithNoNameToMasterList(target, app)
{
	setupMasterListTest(target, app)
	var data = new testMasterListData();
	
	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.AddItemButton().tap();
	editMasterListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	setMasterItemValuesInEditWindow(app, editItemWindow, data.groceryItem2);
	 
	//app.keyboard().buttons()["Return"].tap();
	//app.keyboard().buttons()["Return"].waitForInvalid();
	
	expectedAlertMessage = "Name Required"
	editItemWindow.DoneButton().tap();
	editItemWindow.DoneButton().waitForInvalid();
	 
	var okayButton = app.alert().buttons()["Okay"];
	okayButton.tap(); 
	okayButton.waitForInvalid(); 

	editItemWindow.NameTextView().setValue(data.groceryItem2.Name );
	app.keyboard().buttons()["Return"].tap();
	app.keyboard().buttons()["Return"].waitForInvalid();
	
	editItemWindow.DoneButton().tap();
	editItemWindow.DoneButton().waitForInvalid();
	 
	// items are in same grocery section, so should be in alpha order  
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2, data.item1WithChangedName]);
	
}

function testCannotAddItemWithSameNameToMasterList(target, app)
{
	setupMasterListTest(target, app)
	var data = new testMasterListData();
	
	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.AddItemButton().tap();
	editMasterListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	editItemWindow.NameTextView().setValue(data.itemWithSameNameAsItem2.Name ); 
	setMasterItemValuesInEditWindow(app, editItemWindow, data.itemWithSameNameAsItem2);
	 
	//app.keyboard().buttons()["Return"].tap();
	//app.keyboard().buttons()["Return"].waitForInvalid();
	
	expectedAlertMessage = "Duplicate Item";
	editItemWindow.DoneButton().tap();
	editItemWindow.DoneButton().waitForInvalid();
	 
	var okayButton = app.alert().buttons()["Okay"];
	okayButton.tap(); 
	okayButton.waitForInvalid(); 
	
	editItemWindow.CancelButton().tap();
	editItemWindow.CancelButton().waitForInvalid();
	 
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2, data.item1WithChangedName]);
	
}

function testDeleteItemFromMasterList(target, app)
{
	setupMasterListTest(target, app)
	var data = new testMasterListData();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.MasterListView().cells()[data.item1WithChangedName.MasterItemCellName()].tap();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);
	editItemWindow.DeleteItemButton().tap();
	editItemWindow.DeleteItemButton().waitForInvalid();
	 
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2]);
}

function testCreateAndAssignGrocerySectionToGroceryItemInMasterList(target, app)
{
	var data = new testMasterListData();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.MasterListView().cells()[data.groceryItem2.MasterItemCellName()].tap();
	
	var editItemWindow = new EditGroceryItemWindow(target, app);
	editItemWindow.SelectGrocerySectionButton().tap();
	editItemWindow.SelectGrocerySectionButton().waitForInvalid();	
	 								
	var selectGrocerySectionWindow = new 	SelectGrocerySectionWindow(target, app);	 
	 
	selectGrocerySectionWindow.InsertInAisleButton(0).tap();
	selectGrocerySectionWindow.InsertInAisleButton(0).waitForInvalid();
	 
	var addGrocerySectionWindow = new AddGrocerySectionWindow(target, app);
	addGrocerySectionWindow.SectionNameTextField().setValue(data.groceryItem2InNewSection.Section);  // 'produce' section added as a result..
	addGrocerySectionWindow.AisleNumberTextField().setValue(data.groceryItem2InNewSection.Aisle);
	addGrocerySectionWindow.AddSectionButton().tap(); 
	addGrocerySectionWindow.AddSectionButton().waitForInvalid();
	
	target.pushTimeout(1);
	assertTrue(editItemWindow.DoneButton().isValid(), "Did not return to Edit Item Window after assigning new grocery section"); 
	target.popTimeout();
	testEditItemWindowValidity(editItemWindow, data.groceryItem2InNewSection );
	
	 editItemWindow.DoneButton().tap();
	 editItemWindow.DoneButton().waitForInvalid();
	 
	 testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2InNewSection]);
  	 exitMasterListTest(target, app)
}
function testNewGrocerySectionAddedToAisleConfig(target, app)
{
	var mainWindow = new MainWindow(target, app);
	
	mainWindow.StorePicker().wheels()[0].selectValue(testStoreName);	
	mainWindow.EditStoreButton().tap();
	mainWindow.EditStoreButton().waitForInvalid();

	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.EditAislesButtton().tap();
	editStoreWindow.EditAislesButtton().waitForInvalid();

	editAislesWindow = new EditAislesWindow(target, app, testStoreName);
	//data.groceryItem2InNewSection.Section = 'produce'
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown'], 'Aisle 1', ['new grocery section in new aisle', 'produce'], 'Aisle 5', ['first item in aisle 5']) );

	editAislesWindow.BackButton().tap();
	editAislesWindow.BackButton().waitForInvalid();
	
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
}	
function testAssignExistingGrocerySectionToGroceryItemInMasterList(target, app)
{
	
	setupMasterListTest(target, app)
	var data = new testMasterListData();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);	
	editMasterListWindow.AddItemButton().tap();
	editMasterListWindow.AddItemButton().waitForInvalid();
	 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	editItemWindow.NameTextView().setValue(data.groceryItemInProduceSection.Name );
	 	
	editWithMasterItemValues(app, editItemWindow, data.groceryItemInProduceSection);
	 
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2InNewSection, data.groceryItemInProduceSection]);
	
	//editAislesWindow = new EditAislesWindow(target, app, testStoreName);
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();
	
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
}

function testSaveAndLoadMasterList(target, app)
{
	exitMasterListTest(target, app);	// this saves upon exiting 
	setupMasterListTest(target, app);	
	 
	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();
	
	var data = new testMasterListData();
	 
 	var editStoreWindow = new EditStoreWindow(target, app);
 	
 	editStoreWindow.EditMasterListButton().tap();
	editStoreWindow.EditMasterListButton().waitForInvalid();

	var editMasterListWindow = new MasterListWindow(target, app, testStoreName);
		 
	testMasterListWindowValidity(editMasterListWindow, [data.groceryItem2InNewSection, data.groceryItemInProduceSection]);
	 
	exitMasterListTest(target, app);	 
}

function testAutoAddOfAssignedUnknownGrocerySection(target, app)
{
	var storeName = createStoreWithNonExistingGrocerySectionAssignedToGroceryItem(target, app)
	var data = new testMasterListForGroceryStoreWithUnknownGrocerySections();
	
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.EditMasterListButton().tap();
	editStoreWindow.EditMasterListButton().waitForInvalid();

	var editMasterListWindow = new MasterListWindow(target, app, storeName);

	editMasterListWindow.AddItemButton().tap();
	editMasterListWindow.AddItemButton().waitForInvalid();
 
	var editItemWindow = new EditGroceryItemWindow(target, app);
	editItemWindow.NameTextView().setValue(data.groceryItem1.Name );
	editItemWindow.NotesTextView().setValue(data.groceryItem1.Notes);
	editItemWindow.QuantityTextField().setValue(data.groceryItem1.Quantity);
	editItemWindow.QuantityUnitTextField().setValue(data.groceryItem1.Unit);
	
	if (app.keyboard().checkIsValid() && (app.keyboard().buttons()["Return"] != null) && app.keyboard().buttons()["Return"].checkIsValid())
	{ 
		app.keyboard().buttons()["Return"].tap();
		app.keyboard().buttons()["Return"].waitForInvalid();
	}

	editItemWindow.ItemGrocerySection().setValue(data.groceryItem1.Section);
	editItemWindow.SelectGrocerySectionButton().tap();
	editItemWindow.SelectGrocerySectionButton().waitForInvalid();	
	 								
	var selectGrocerySectionWindow = new 	SelectGrocerySectionWindow(target, app);	 
	testSelectGrocerySectionWindowValidity(selectGrocerySectionWindow, new Hash('Aisle 0', ['unknown', data.groceryItem1.Section])); 
	selectGrocerySectionWindow.SectionsTableView().cells()[data.groceryItem1.Section].tap();
	selectGrocerySectionWindow.SectionsTableView().waitForInvalid();
	
	editItemWindow.CancelButton().tap();
	editItemWindow.CancelButton().waitForInvalid();
	
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();
	
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
	var mainWindow = new MainWindow(target, app);
	
	mainWindow.StorePicker().wheels()[0].selectValue(storeName);	
	mainWindow.EditStoreButton().tap();
	mainWindow.EditStoreButton().waitForInvalid();

	editStoreWindow.EditAislesButtton().tap();
	editStoreWindow.EditAislesButtton().waitForInvalid();

	editAislesWindow = new EditAislesWindow(target, app, storeName);
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', data.groceryItem1]) );

	editAislesWindow.BackButton().tap();
	editAislesWindow.BackButton().waitForInvalid();
	
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
	
}
