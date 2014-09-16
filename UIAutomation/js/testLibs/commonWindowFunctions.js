#import "windowDefinitions.js"
#import "utils.js"

var expectedAlertMessage = "";

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

function createStore(target, app, storeName)
{
	var mainWindow = new MainWindow(target, app);
	mainWindow.AddStoreButton().tap();
	mainWindow.AddStoreButton().waitForInvalid();

	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.EditStoreNameButton().tap();

	target.pushTimeout(1);
	assertTrue(editStoreWindow.StoreNameTextField().isEnabled(), "Edit field is not enabled after clicking Compose button");
	target.popTimeout();	

	editStoreWindow.StoreNameTextField().setValue(storeName);
	editStoreWindow.DoneEditingStoreNameButton().tap();
	editStoreWindow.DoneEditingStoreNameButton().waitForInvalid();
	
	return editStoreWindow;	
}

function createStoreWithNonExistingGrocerySectionAssignedToGroceryItem(target, app)
{
	var storeName = "StoreWithUnknownGrocerySections";
	var mainWindow = new MainWindow(target, app);
	
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), storeName) )
	{
		createStore(target, app, storeName);		
	}
	return storeName;
	
}

function enterEditMode(editAislesWindow)
{
	if (editAislesWindow.EnterEditModeButton().isValid())
	{
		editAislesWindow.EnterEditModeButton().tap();
		editAislesWindow.EnterEditModeButton().waitForInvalid();
	}
	editAislesWindow.Mode = "Edit"; 
}

function exitEditMode(editAislesWindow)
{
	if (editAislesWindow.ExitEditModeButton().isValid())
	{
		editAislesWindow.ExitEditModeButton().tap();
		editAislesWindow.ExitEditModeButton().waitForInvalid();
	};
	editAislesWindow.Mode = "View"; 
}


function createGrocerySections(target, app, storeName, aislesToInsert)
{
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.EditAislesButtton().tap();
	editStoreWindow.EditAislesButtton().waitForInvalid();
	
	var editAislesWindow = new EditAislesWindow(target, app, storeName); 
								 
	enterEditMode(editAislesWindow);
	
	var j = 0;
	UIALogger.logDebug("number of aisles: " + aislesToInsert.length);
	UIALogger.logDebug("aisles.items: " + aislesToInsert.items);
	
	
 	for (var aisle in aislesToInsert.items)
	{
		/*
		if ( j == aislesToInsert.length)
			break;
		*/		
		for (var j = 0; j < aislesToInsert.items[aisle].length; j++)
		{
			var section = aislesToInsert.items[aisle][j] ;
			UIALogger.logDebug("inserting section: "  + section + "in aisle: " + aisle);
			editAislesWindow.InsertAfterSectionButton("unknown").tap();
			var newSectionCell = editAislesWindow.CellToEdit("Aisle:");
			newSectionCell.SectionNameTextField().setValue(section);
			newSectionCell.AisleNumberTextField().setValue(aisle);
			newSectionCell.DoneButton().tap();
		 	newSectionCell.DoneButton().waitForInvalid();
		}	
	}	 	 
		 
	exitEditMode(editAislesWindow);	 
	
	editAislesWindow.BackButton().tap();
	editAislesWindow.BackButton().waitForInvalid();
	
	return editStoreWindow;
}

function setCommonItemValuesInEditWindow(app, editWindow, item)
{
	editWindow.NotesTextView().setValue(item.Notes);
	editWindow.QuantityTextField().setValue(item.Quantity);
	editWindow.QuantityUnitTextField().setValue(item.Unit);

	if (app.keyboard().checkIsValid() && (app.keyboard().buttons()["Return"] != null) && app.keyboard().buttons()["Return"].checkIsValid())
	{ 
		app.keyboard().buttons()["Return"].tap();
		app.keyboard().buttons()["Return"].waitForInvalid();
	}
	// note: select has 3 different meanings:
	// (1) from master list, it means the item should be selected by default when preparing a shopping list
	// (2) from current list, it means the change(s) should be applied to the corresponding item
	//if (editWindow.SelectedSwitch().value() != item.Selected)
	//	editWindow.SelectedSwitch().tap();
	
	if (item.Section != "Grocery Section")
	{
		selectGrocerySection(target, app, editWindow, item.Section );
	}
		
}

function setShoppingItemValuesInEditWindow(app, editWindow, item)
{
	setCommonItemValuesInEditWindow(app, editWindow, item);

	// note: select has 3 different meanings:
	// (1) from master list, it means the item should be selected by default when preparing a shopping list
	// (2) from current list, it means the change(s) should be applied to the corresponding item
	if (editWindow.SelectedSwitch().value() != item.ApplyToMaster)
	{
		UIALogger.logDebug(item.Name + '.ApplyToMaster: ' + item.ApplyToMaster);
		editWindow.SelectedSwitch().tap();		
	}
}

function setMasterItemValuesInEditWindow(app, editWindow, item)
{
	setCommonItemValuesInEditWindow(app, editWindow, item);

	// note: select has 3 different meanings:
	// (1) from master list, it means the item should be selected by default when preparing a shopping list
	// (2) from current list, it means the change(s) should be applied to the corresponding item
	if (editWindow.SelectedSwitch().value() != item.SelectByDefault)
		editWindow.SelectedSwitch().tap();		
}

function cancelWithShoppingItemValues(app, editWindow, item)
{	
	setShoppingItemValuesInEditWindow(app, editWindow, item);
	
	if (app.keyboard().isValid())
	{
		app.keyboard().buttons()["Return"].tap();
		app.keyboard().buttons()["Return"].waitForInvalid();
	}
	editWindow.CancelButton().tap();
	editWindow.CancelButton().waitForInvalid();
	
	
}

function editWithMasterItemValues(app, editWindow, item)
{	
	setMasterItemValuesInEditWindow(app, editWindow, item);
	
	if (app.keyboard().isValid())
	{
		app.keyboard().buttons()["Return"].tap();
		app.keyboard().buttons()["Return"].waitForInvalid();
	}
	editWindow.DoneButton().tap();
	editWindow.DoneButton().waitForInvalid();
	
	
}

function editWithShoppingItemValues(app, editWindow, item)
{	
	setShoppingItemValuesInEditWindow(app, editWindow, item);
	
	if (app.keyboard().isValid())
	{
		app.keyboard().buttons()["Return"].tap();
		app.keyboard().buttons()["Return"].waitForInvalid();
	}
	editWindow.DoneButton().tap();
	editWindow.DoneButton().waitForInvalid();
	
}

function selectGrocerySection(target, app, editItemWindow, section)
{
	editItemWindow.SelectGrocerySectionButton().tap();
	editItemWindow.SelectGrocerySectionButton().waitForInvalid();	
	 								
	var selectGrocerySectionWindow = new 	SelectGrocerySectionWindow(target, app);	 
	if (selectGrocerySectionWindow.SectionsTableView().cells()[section].isValid())
	{
		selectGrocerySectionWindow.SectionsTableView().cells()[section].tap();
	}
	else
	{
		selectGrocerySectionWindow.SectionsTableView().cells()["unknown"].tap();
		
	} 
	selectGrocerySectionWindow.SectionsTableView().waitForInvalid();
}

function createMasterListItems(target, app, storeName, itemsToAdd)
{
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.EditMasterListButton().tap();
	editStoreWindow.EditMasterListButton().waitForInvalid();
	
	var editMasterListWindow = new MasterListWindow(target, app, storeName);
	
	for (var i = 0; i < itemsToAdd.length; i++)
	{
		editMasterListWindow.AddItemButton().tap();
		editMasterListWindow.AddItemButton().waitForInvalid();
	 
		var editItemWindow = new EditGroceryItemWindow(target, app);
		editItemWindow.NameTextView().setValue(itemsToAdd[i].Name );
		editWithMasterItemValues(app, editItemWindow, itemsToAdd[i]);		
		
	}
	editMasterListWindow.BackButton().tap();
	editMasterListWindow.BackButton().waitForInvalid();
	
}

function prepareShoppingList(target, app, storeName, masterItemsToInclude, itemsToAdd)
{
	var window = new MainWindow(target, app);
	window.PrepareGroceryListButton().tap();
	window.PrepareGroceryListButton().waitForInvalid();
	
	var editShoppingListWindow = new PrepareShoppingListWindow(target, app, storeName);

	for (var i = 0; i < masterItemsToInclude.length; i++)
	{
		var expectedCellName = masterItemsToInclude[i].PrepareShoppingListCellName();
		UIALogger.logDebug("Processing: " + expectedCellName);
		var itemCell = new PrepareShoppingListCell(editShoppingListWindow.ShoppingListView().cells()[expectedCellName]);
		if (!itemCell.IncludeSwitch().value())
			itemCell.IncludeSwitch().tap() ;		
	}
	
	for (var j = 0; j < itemsToAdd.length; j++)
	{
		editShoppingListWindow.AddItemButton().tap();
		editShoppingListWindow.AddItemButton().waitForInvalid();
	 
		var editItemWindow = new EditGroceryItemWindow(target, app);
		UIALogger.logDebug("Adding item: " + itemsToAdd[j].Name);
		editItemWindow.NameTextView().setValue(itemsToAdd[j].Name );
		editWithShoppingItemValues(app, editItemWindow, itemsToAdd[j]);		
		
	}
	editShoppingListWindow.BackButton().tap();
	editShoppingListWindow.BackButton().waitForInvalid();
	
}

function testMasterListData()
{
	this.defaultGroceryItem = new MasterGroceryItem('', '1', 'Units', '', 'Grocery Section', '0', true);	
	this.groceryItem1 = new MasterGroceryItem('M Item 1', '3.5', 'lbs', 'M Item 1 Notes', 'Grocery Section', '0', true);	
	this.updatedGroceryItem1 = new MasterGroceryItem('M Item 1', '2.5', 'lbs', 'M Item 1 Notes after update', 'Grocery Section', '0', false); 
	this.item1WithChangedName = new MasterGroceryItem('M New Item 1', '2.5', 'lbs', 'M Item 1 Notes after update', 'Grocery Section', '0', false);  

	this.groceryItem2 = new MasterGroceryItem('Item 2', '10', 'oz', 'Item 2 Notes', 'Grocery Section', '0', true);	

	this.itemWithSameNameAsItem2 = new MasterGroceryItem('Item 2', '1', 'bah', 'Item x Notes', 'Grocery Section', '0', true);	
	this.groceryItem2InNewSection = new MasterGroceryItem('Item 2', '10', 'oz', 'Item 2 Notes', 'produce', '1', true);	
	this.groceryItemInProduceSection = new MasterGroceryItem('Item 3', '10', 'oz', 'Should be in produce section', 'produce', '1', false);	

	this.shoppingListItem1 = new MasterGroceryItem('Shopping Item Not Originally In Master List', '2', 'lb', 'Temp Item Notes', 'Grocery Section', '0', false);	
	this.shoppingListItem4 = new MasterGroceryItem('Item 4', '2', 'boxes', 'Item 4 Notes', 'produce', '1', true);	
	
	this.shoppingListItem6 = new MasterGroceryItem('Item 6', '0.5', 'oz', 'Section added when creating item in Prepare Shopping List', 'New Section Just Added', '3', true);

	this.shoppingListItem2_updated = new MasterGroceryItem('Item 2', '10', 'oz', 'Item 2 Notes with update', 'first item in aisle 5', '5', true);	
	this.groceryItemInProduceSection_updated = new MasterGroceryItem('Item 3', '9', 'oz', 'Should be in produce section', 'produce', '1', false);	

}
function testCurrentListData()
{
	this.defaultGroceryItem = new CurrentGroceryItem('', '1', 'Units', '', 'Grocery Section', '0', true, true);	
	this.groceryItem2InNewSection = new CurrentGroceryItem('Item 2', '10', 'oz', 'Item 2 Notes', 'produce', '1', true, true);	
	this.groceryItemInProduceSection = new CurrentGroceryItem('Item 3', '10', 'oz', 'Should be in produce section', 'produce', '1', false, false);	
	this.shoppingGroceryItem1 = new CurrentGroceryItem('Shopping Item Not Originally In Master List', '1.25', 'lbs', 'Temp Item Notes', 'Grocery Section', '0', false, true);	

	this.shoppingListItem1 = new CurrentGroceryItem('Shopping Item Not Originally In Master List', '1.5', 'lbs', 'Temp Item Notes', 'Grocery Section', '0', false, true);	
	this.shoppingListItem2 = new CurrentGroceryItem('Item 2', '10', 'oz', 'Item 2 Notes', 'produce', '1', true, true);	
	this.shoppingListItem3 = new CurrentGroceryItem('Item 3', '9', 'oz', 'Should be in produce section', 'produce', '1', true, true);	
	this.shoppingListItem2_updated = new CurrentGroceryItem('Item 2', '10', 'oz', 'Item 2 Notes with update', 'first item in aisle 5', '5', true, false);	
	this.shoppingListItem4 = new CurrentGroceryItem('Item 4', '2', 'boxes', 'Item 4 Notes', 'produce', '1', true, true);	
	
	this.shoppingListItem5_NotAddedToMaster = new CurrentGroceryItem('Item 1', '1', 'package', 'Item 5 Notes', 'produce', '1', true, false);	
	
	this.shoppingListItem6 = new CurrentGroceryItem('Item 6', '0.5', 'oz', 'Section added when creating item in Prepare Shopping List', 'New Section Just Added', '3', true, true);
	this.groceryItemInProduceSection_updated = new CurrentGroceryItem('Item 3', '9', 'oz', 'Should be in produce section', 'produce', '1', false);	
	this.shoppingListItem7 = new CurrentGroceryItem('Item 7', '1', 'package', 'Located in  non-existing section that should be added', 'New Section Added When Shopping List Was Created', '0', false);
}

function ShoppingListData()
{
	this.shoppingListItem0 = new GroceryItem('Shopping Item Not Originally In Master List', '1.5', 'lbs', 'Temp Item Notes', 'Grocery Section', '0', false);	
	this.shoppingListItem1 = new GroceryItem('Item 1', '1', 'package', 'Item 5 Notes', 'produce', '1', false);
	this.shoppingListItem2 = new GroceryItem('Item 2', '10', 'oz', 'Item 2 Notes with update', 'first item in aisle 5', '5', false);	
	this.shoppingListItem3 = new GroceryItem('Item 3', '9', 'oz', 'Should be in produce section', 'produce', '1', false);	
	this.shoppingListItem4 = new GroceryItem('Item 4', '2', 'boxes', 'Item 4 Notes', 'produce', '1', false);
//	this.shoppingListItem5 = new GroceryItem('Item 5', '1', 'package', 'Item 5 Notes', 'produce', '1', false);	
	this.shoppingListItem6 = new GroceryItem('Item 6', '0.5', 'oz', 'Section added when creating item in Prepare Shopping List', 'New Section Just Added', '3', false);
	this.shoppingListItem7 = new GroceryItem('Item 7', '1', 'package', 'Located in  non-existing section that should be added', 'New Section Added When Shopping List Was Created', '0', false);

}

function testMasterListForGroceryStoreWithUnknownGrocerySections()
{
	this.groceryItem1 = new MasterGroceryItem('Item in list with unknown section', '1', 'package', 'Section is not known', 'Initially Unknown Grocery Section 1', '0', true);	
}	
function testCurrentListForGroceryStoreWithUnknownGrocerySections()
{
	this.groceryItem1 = new CurrentGroceryItem('Item in list with unknown section', '1', 'package', 'Section is not known', 'Initially Unknown Grocery Section 1', '0', true);	
}	


function testShoppingListDataWithUnknownGrocerySection()
{
	this.shoppingItem1 = new GroceryItem('Item in list with unknown section', '1', 'package', 'Section is not known', 'Initially Unknown Grocery Section 1', '0', false);	
	
}

/*
[currentListData.shoppingListItem2_updated, 
currentListData.groceryItemInProduceSection, 
currentListData.shoppingListItem1, 
currentListData.shoppingListItem4],
[currentListData.shoppingListItem5_NotAddedToMaster] );
*/
