#import "tuneupJs/tuneup.js"
#import "windowDefinitions.js"
#import "utils.js"

function testMainWindowValidity()
{
	var window = arguments[0];

	assertEquals("Select Grocery Store", window.Name(), "Main Window has wrong title (not at main window?)");
 	assertTrue(window.PrepareGroceryListButton().isValid());
 	assertTrue(window.GoShoppingButton().isValid()); 	 
 	assertTrue(window.AddStoreButton().isValid());
 	assertTrue(window.EditStoreButton().isValid());
 	assertTrue(window.StorePicker().isValid(), "List of grocery stores not displayed on main window.");
 	//assertEquals(arguments.length - 1, window.StorePicker().wheels()[0].values().length, "Unexpected number of stores found in List of Stores");
 
	for (var i = 1; i < arguments.length; i++) 
	{
		var iRegExp = new RegExp(arguments[i-1] + ".*$");
		var matchFound = false;
		for (var j = 0; !matchFound && (j < window.StorePicker().wheels()[0].values().length); j++)
		{
			assertTrue(storeExists(window.StorePicker().wheels()[0].values(), arguments[i]), "'" + arguments[i] + "'" + " not found in list of stores.");			
			//matchFound = iRegExp.test(window.StorePicker().wheels()[0].values()[j]);		
		}
	    //assertTrue(matchFound, "List of store names are not what is expected.");
	}
}

// paream 1: EditStoreWindow
function testEditStoreWindowValidity(window, expectedStoreName)
{
 	assertEquals("Edit Grocery Store", window.Name());
	window.BackButton().isValid();
	window.DeleteStoreButton().isValid();
	window.StoreNameTextField().isValid();
	window.Toolbar().isValid();
 	assertFalse(window.StoreNameTextField().isEnabled(), "Edit field is enabled without clicking Compose button");
	
	if (expectedStoreName !== "")
	{
	 	assertEquals(expectedStoreName, window.StoreNameTextField().value());
		window.EditAislesButtton().isValid();
		window.EditMasterListButton().isValid();
		window.ShareGroceryListsButton().isValid();
		window.EditStoreNameButton().isValid();
	}
}

function testEditAislesWindowValidity(window, expectedAisles)
{	
	assertEquals(window.StoreName + " Aisles", window.Name(), "Edit Aisles has wrong title (not at edit aisles window?)");
 	assertTrue(window.AislesTableView().isValid(), "Table View in Edit Aisles Window is not valid");
	if (window.Mode == "View")
		assertTrue(window.EnterEditModeButton().isValid(), "Button to enter edit mode in Edit Aisles Window is not valid")
	else
		assertTrue(window.ExitEditModeButton().isValid(), "Button to exit edit mode in Edit Aisles Window is not valid")
	
 	assertEquals(expectedAisles.length, window.AislesTableView().groups().length, "Unexpected number of aisles found");

 	var j = 0;
	var expectedNumberOfSections = 0;
 	for (var aisle in expectedAisles.items)
	{
		if ( j == expectedAisles.length)
			break;
	
		
		assertEquals(aisle, window.AislesTableView().groups()[j].staticTexts()[0].name(), "Expected '" + aisle + "' not found");		
		expectedNumberOfSections += expectedAisles.getItem(aisle).length;
		for (var section in expectedAisles[aisle])
		{
			assertEquals(section, window.AislesTableView().groups()[j].elements()[0].staticTexts()[0].name(), "Expected '" + section + "' not found");
		}
		j++;
	}
	assertEquals(expectedNumberOfSections, window.AislesTableView().cells().length , "wrong number of sections present");
}

function testMasterListWindowValidity(window, expectedItems)
{	
	assertEquals(window.StoreName + " List", window.Name(), "Master List window has wrong title (not at master list window?)");
 	assertTrue(window.MasterListView().isValid(), "Table View in Master List Window is not valid");
	assertEquals(expectedItems.length, window.MasterListView().cells().length, "Unexpected number of items found in master list");

	var expectedNumberOfItems = 0;
	var cell;
 	for (var j = 0; j < expectedItems.length; j++)
	{
		var item = expectedItems[j];
		var expectedCellName = item.MasterItemCellName();
		assertNotNull(window.MasterListView().cells()[expectedCellName], "'" + expectedCellName + "'" + "not a valid cell name"); 	
	}
}

function testEditItemWindowValidity(window, expectedItem )
{
	assertEquals(expectedItem.Name, window.NameTextView().value(), "Item name does not match");
	assertEquals(expectedItem.Notes, window.NotesTextView().value(), "Item notes do not match");
	assertEquals(expectedItem.Quantity, window.QuantityTextField().value(), "Item quantity does not match");
	assertEquals(expectedItem.Unit, window.QuantityUnitTextField().value(), "Item unit does not match");
	assertEquals(expectedItem.Section, window.ItemGrocerySection().value(), "Item's grocery section is incorrect.");
	//assertEquals(expectedItem.Selected, window.SelectedSwitch().value(), "Item's selected state is incorrect.")
}

function testEditMasterItemWindowValidity(window, expectedItem )
{
	testEditItemWindowValidity(window, expectedItem);
	
	assertEquals(expectedItem.IncludeInShoppingListByDefault, window.SelectedSwitch().value(), "Item's IncludeInShoppingListByDefault value is incorrect.")
}

function testEditCurrentItemWindowValidity(window, expectedItem )
{
	testEditItemWindowValidity(window, expectedItem);
	
	assertEquals(expectedItem.IsPantryItem, window.SelectedSwitch().value(), "Item's IsPantryItem value is incorrect.")
}

function testSelectGrocerySectionWindowValidity(window, expectedAisles)
{	
	//assertEquals(window.StoreName + " Aisles", window.Name(), "Edit Aisles has wrong title (not at edit aisles window?)");
 	assertTrue(window.SectionsTableView().isValid(), "Table View in Select Grocery Section Window is not valid  (not at select grocery section window?)");	
 	assertEquals(expectedAisles.length, window.SectionsTableView().groups().length, "Unexpected number of aisles found");

	var expectedNumberOfSections = 0;
	var sectionCellIndex = 0;
	var aisleGroupIndex = 0;
	for (var aisle in expectedAisles.items)
	{
		if (aisleGroupIndex == expectedAisles.length)
			break;
			
		assertEquals(aisle, window.SectionsTableView().groups()[aisleGroupIndex].staticTexts()[0].name(), "Expected aisle '" + aisle + "' not found");		
		expectedNumberOfSections += expectedAisles.getItem(aisle).length;
				
		for (var j = 0; j < expectedAisles.items[aisle].length; j++)	
		{
			var section = expectedAisles.items[aisle][j] ;
			assertEquals(section, window.SectionsTableView().cells()[sectionCellIndex].name(), "Expected section '" + section + "' not found");
			sectionCellIndex++;
		}
		aisleGroupIndex++;
	}
	assertEquals(expectedNumberOfSections, window.SectionsTableView().cells().length , "wrong number of sections present");
}

function testPrepareShoppingListWindowValidity(window, expectedItems)
{
	assertEquals(window.StoreName + " List", window.Name(), "Prepare Shopping List window has wrong title (not at prepare shopping list window?)");
 	assertTrue(window.ShoppingListView().isValid(), "Table View in Prepare Shopping List Window is not valid");
	assertEquals(expectedItems.length, window.ShoppingListView().cells().length, "Unexpected number of items found in shopping list");

 	for (var j = 0; j < expectedItems.length; j++)
	{
		var item = expectedItems[j];
		var expectedCellName = item.PrepareShoppingListCellName();
		UIALogger.logDebug("Testing: '" + expectedCellName + "' cell");
		assertNotNull(window.ShoppingListView().cells()[expectedCellName], "'" + expectedCellName + "'" + "not a valid cell name in shopping list being prepared"); 	
		cell = new PrepareShoppingListCell(window.ShoppingListView().cells()[expectedCellName]);
		assertEquals(item.IncludeInShoppingList, cell.IncludeSwitch().value(), "'" + expectedCellName + "' has incorrect selection indicator");
	}
	
}

function testShoppingListWindowValidity(window, expectedItems)
{
	assertEquals(window.StoreName + " Shopping List", window.Name(), "Shopping List window has wrong title (not at prepare shopping list window?)");
 	assertTrue(window.ShoppingListView().isValid(), "Table View in Shopping List Window is not valid");
	assertEquals(expectedItems.length, window.ShoppingListView().cells().length, "Unexpected number of items found in shopping list");
 	for (var j = 0; j < expectedItems.length; j++)
	{
		var item = expectedItems[j];
		var expectedCellName = item.ShoppingListCellName();
		UIALogger.logDebug("Looking for: '" + expectedCellName + "' cell");
		assertNotNull(window.ShoppingListView().cells()[expectedCellName], "'" + expectedCellName + "'" + "not a valid cell name in shopping list"); 	
		cell = new ShoppingListCell(window.ShoppingListView().cells()[expectedCellName]);
		assertTrue(cell.isValid());
		//assertEquals(item.Selected, cell.IncludeSwitch().value(), "'" + expectedCellName + "' has incorrect selection indicator");
	}
	
}
