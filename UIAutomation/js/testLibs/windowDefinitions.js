#import "tuneupJs/tuneup.js"

function MainWindow(target, application) {
	
	var app = application;
	
	this.StorePicker = function() 
	{
		//return app.mainWindow().pickers()["List Of Grocery Stores"];
		return app.mainWindow().pickers()[0];
	};
	this.Name = function()
	{
		return app.mainWindow().navigationBars()[0].name();
	}
	this.PrepareGroceryListButton = function() { return app.mainWindow().buttons()["Prepare Grocery List"]; };
	this.GoShoppingButton = function() { return app.mainWindow().buttons()["Go Shopping"]; };
	this.AddStoreButton = function() { return app.mainWindow().navigationBars()[0].rightButton(); }
	this.EditStoreButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };

}

function EditStoreWindow(target, application) {
	var app = application;
	
	this.EditAislesButtton = function() { return app.mainWindow().buttons()["Edit Aisle Information"]; };
	this.EditMasterListButton = function() { return app.mainWindow().buttons()["Edit Master Grocery List"]; };
	this.ShareGroceryListsButton = function() { return app.mainWindow().buttons()["Share Grocery Lists"]; };
	this.Name = function() { return app.mainWindow().navigationBars()[0].name(); };
	this.DeleteStoreButton = function() { return app.mainWindow().navigationBars()[0].rightButton(); };
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };
	this.StoreNameTextField = function() { return app.mainWindow().textFields()["Store Name Text Field"]; };
	this.Toolbar = function() { return app.mainWindow().toolbar(); };
	this.EditStoreNameButton = function() {
		return this.Toolbar().buttons()["Compose"];
	};
	this.DoneEditingStoreNameButton = function() {
		return this.Toolbar().buttons()["Done"];
	};

}
function EditAislesWindow(target, application, storeName)
{
	var app = application;
	
	this.Mode = "View";
	this.Name = function() { return app.mainWindow().navigationBars()[0].name(); };
	this.StoreName = storeName;
	this.Toolbar = function() { return app.mainWindow().toolbar(); };
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };
	this.AislesTableView = function() { return app.mainWindow().tableViews()[0]; };
	this.EnterEditModeButton = function() { return this.AislesTableView().groups()[0].elements()[0].buttons()["Edit"]; };
	this.EnterDeleteModeButton = function() { return this.AislesTableView().groups()[0].elements()[0].buttons()["Delete"]; };
	this.ExitEditModeButton = function() { return this.AislesTableView().groups()[0].elements()[0].buttons()["Done"]; };
	this.ExitDeleteModeButton = function() { return this.AislesTableView().groups()[0].elements()[0].buttons()["Done"]; };
	
	this.CellToEdit  = function(sectionName) { return new EditGrocerySectionCellView(this.AislesTableView(), sectionName); };
	this.CellToDelete  = function(sectionName) { return new DeleteGrocerySectionCellView(app, this.AislesTableView(), sectionName); };
	//this.CellToDelete  = function(sectionName) { return new EditGrocerySectionCellView(this.AislesTableView(), sectionName); };
	
	//when editing sections / aisles
	this.InsertAfterSectionButton = function InsertAfterSectionButton(sectionName) { 
		return this.AislesTableView().cells()[sectionName].buttons()["Insert " + sectionName]; 
	};
	
	//when deleting sections
	this.DeleteSectionSwitch = function(sectionName) { 
		var cell = this.AislesTableView().cells()[sectionName];
		assertTrue(cell.isValid(), sectionName + " cell not valid");
		
		var deleteSwitch = cell.switches()["Delete " + sectionName];
		assertTrue(deleteSwitch.isValid(), "Delete button in cell is not valid");
		return deleteSwitch; 
	};

}

function DeleteGrocerySectionCellView(app, tableView, cellName)
{
	this.DeleteSwitch = function() { return app.mainWindow().tableViews()[0].cells()[cellName].switches()["Delete " + cellName]; };
	this.ConfirmDeleteButton = function() { return app.mainWindow().tableViews()[0].cells()[cellName].buttons()["Delete"]; };
	this.logElement = function() { app.mainWindow().tableViews()[0].cells()[cellName].logElement();}
};

function EditGrocerySectionCellView(tableView, cellName)
{
	var cell = tableView.cells()[cellName];
	this.EditButton = function() { return cell.buttons()["More info, " + cellName]; };
	this.DoneButton = function() { 		return cell.buttons()["Done Editing Section Button"]; };
	this.DecrementAisleNumberButton = function() { return cell.buttons()["Decrement"]; };
	this.IncrementAisleNumberButton = function() { return cell.buttons()["Increment"]; };
	                                                                   
	this.SectionNameTextField = function() { return cell.textFields()["Section Name Field"]; };
	this.AisleNumberTextField = function() { return cell.textFields()["Aisle Number Field"]; };
}

function PrepareShoppingListWindow(target, application) {
	var app = application;
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };
}

function MasterListWindow(target, application, storeName)
{
	var app = application;
	
	this.StoreName = storeName;
	this.Name = function() { return app.mainWindow().navigationBars()[0].name(); };
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };

	this.MasterListView = function() { return app.mainWindow().tableViews()[0]; };
	this.AddItemButton = function() { return app.mainWindow().navigationBars()[0].rightButton(); };	
}
/*function GroceryItem(name, quantity, unit, notes, section, aisle, selected)
{
	this.Name = name;
	this.Quantity =  quantity ;
	this.Unit =  unit ;
	this.Notes = notes;
	this.Section = section;
	this.Selected = selected;
	this.Aisle = aisle;
	this.MasterItemCellName = function() { return this.Name + ', ' + this.Quantity + ' ' + this.Unit + ', ' + this.Notes ; };
	this.PrepareShoppingListCellName = function() { return this.Name + ', ' + this.Quantity + ' ' + this.Unit; };
	
}*/
function GroceryItem(name, quantity, unit, notes, section, aisle, selected)
{
	this.Name = name;
	this.Quantity =  quantity ;
	this.Unit =  unit ;
	this.Notes = notes;
	this.Section = section;
	this.Selected = selected;
	this.Aisle = aisle;
	this.MasterItemCellName = function() { return this.Name + ', ' + this.Quantity + ' ' + this.Unit + ', ' + this.Notes ; };
	this.PrepareShoppingListCellName = function() { return this.Name + ', ' + this.Quantity + ' ' + this.Unit; };
	this.ShoppingListCellName = function() { return this.Name + ', ' + this.Notes  + ', ' + this.Quantity + ' ' + this.Unit; };
	
}
//MasterGroceryItem.prototype - new GroceryItem(name, quantity, unit, notes, section, aisle, selected);


function ShoppingItem(name, quantity, unit, notes, section, aisle, selected)  
{
	GroceryItem.apply(this, arguments);
	
  	this.IsCheckedOff = function()  { return this.selected; };
	this.Check = function() { this.selected = true; } ;
	this.Uncheck = function() { this.selected = false; }; 
}

function EditGroceryItemWindow(target, application)
{
	var app = application;

	this.NameTextView = function() { return app.mainWindow().textViews()['Item Name']; };
	this.NotesTextView = function() { return app.mainWindow().textViews()['Item Notes']; };
	this.QuantityTextField = function() {return app.mainWindow().textFields()['Quantity']; };
	this.QuantityUnitTextField = function() {return app.mainWindow().textFields()['Quantity Unit']; };
	this.ItemGrocerySection = function() {return app.mainWindow().textFields()['EditGroceryItemWindow']; };
	this.SelectGrocerySectionButton = function() {return app.mainWindow().buttons()['Select Grocery Section Button']; };
	this.ScanButton = function() { return app.mainWindow().buttons()['Scan Button']; };
	this.SelectedSwitch = function() { return app.mainWindow().switches()['Item Selected Switch'];}
	this.DeleteItemButton = function(){ return app.mainWindow().toolbars()[0].buttons()['Delete']; };
	this.CancelButton = function(){ return app.mainWindow().toolbars()[0].buttons()['Cancel']; };
	this.DoneButton = function() { return app.mainWindow().toolbars()[0].buttons()['Done']; };

}

function SelectGrocerySectionWindow(target, application)
{
	var app = application;
	
	//this.Name = function() { return app.mainWindow().navigationBars()[0].name(); };
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };
	this.SectionsTableView = function() { return app.mainWindow().tableViews()[0]; };
		
	//when editing sections / aisles
	this.InsertInAisleButton = function InsertInAisleButton(aisleIndex) { 
		return this.SectionsTableView().groups()[aisleIndex].buttons()["New"]; 
	};

}

function AddGrocerySectionWindow(target, application)
{
	var app = application;
	
	this.CancelButton = function() {return app.mainWindow().buttons()['Cancel Button'];};
	this.AddSectionButton = function() { 		return app.mainWindow().buttons()["Add Section Button"]; };
	this.DecrementAisleNumberButton = function() { return app.mainWindow().buttons()["Decrement"]; };
	this.IncrementAisleNumberButton = function() { return app.mainWindow().buttons()["Increment"]; };
	                                                                   
	this.SectionNameTextField = function() { return app.mainWindow().textFields()["Section Name Field"]; };
	this.AisleNumberTextField = function() { return app.mainWindow().textFields()["Aisle Number Field"]; };
}

function PrepareShoppingListWindow(target, application, storeName)
{
	var app = application;
	
	this.StoreName = storeName;
	this.Name = function() { return app.mainWindow().navigationBars()[0].name(); };
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };
	this.SearchField = function() { return app.mainWindow().searchBars()[0].textFields()[0]; };

	this.ShoppingListView = function() { return app.mainWindow().tableViews()[0]; };
	this.AddItemButton = function() { return app.mainWindow().navigationBars()[0].rightButton(); };	
	this.GroceryItemCell = function(groceryItem) {return new PrepareShoppingListCell(this.ShoppingListView().cells()[groceryItem.PrepareShoppingListCellName()]);};
}

function PrepareShoppingListCell(cell)
{
	this.IncludeSwitch = function() {return cell.switches()["Include"];};
	this.DecrementQuantityButton = function() {return cell.buttons()["Decrement"];};
	this.IncrementQuantityButton = function() {return cell.buttons()["Increment"];};
	this.tap = function() { cell.tap(); };
	this.waitForInvalid = function() { cell.waitForInvalid(); };
	this.isValid = function() { return cell.isValid(); };
	
}

function ShoppingListCell(cell)
{
	//this.CheckedOffSwitch = function() {return cell.switches()["Include"];};
	this.tap = function() { cell.buttons()[0].tap(); };
	this.isValid = function() { return cell.isValid(); };	
}

function ShoppingListWindow(target, application, storeName)
{
	var app = application;
	
	this.StoreName = storeName;
	this.Name = function() { return app.mainWindow().navigationBars()[0].name(); };
	this.BackButton = function() { return app.mainWindow().navigationBars()[0].leftButton(); };
	//this.SearchField = function() { return app.mainWindow().searchBars()[0].textFields()[0]; };

	this.ShoppingListView = function() { return app.mainWindow().tableViews()[0]; };	
	this.GroceryItemCell = function(groceryItem) 
	{
		return new ShoppingListCell( this.ShoppingListView().cells()[groceryItem.ShoppingListCellName()]);
	};
}


function MasterGroceryItem(name, quantity, unit, notes, section, aisle, selected) 
{
  	GroceryItem.apply(this, arguments);
	this.SelectByDefault = selected;
}

function CurrentGroceryItem(name, quantity, unit, notes, section, aisle, selected, applyToMaster)
{
    GroceryItem.apply(this, arguments);
  	this.ApplyToMaster = applyToMaster;
}
