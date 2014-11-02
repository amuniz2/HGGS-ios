var sectionTestHasBeenSetup = false;
var testStoreName = "UI Automation Test Store";

function setupSectionTest(target, app)
{
	if (sectionTestHasBeenSetup)
		return;
	
	var mainWindow = new MainWindow(target, app);
	var editStoreWindow = new EditStoreWindow(target, app);
	
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), testStoreName) )
	{
		createStore(target, app, testStoreName);		
	}
	else
	{
		mainWindow.StorePicker().wheels()[0].selectValue(testStoreName);	
		mainWindow.EditStoreButton().tap();
		mainWindow.EditStoreButton().waitForInvalid();
	}
	editStoreWindow.EditAislesButtton().tap();
	editStoreWindow.EditAislesButtton().waitForInvalid();
	
	sectionTestHasBeenSetup = true;
}
function exitSectionTest(target, app, editAislesWindow)
{
	if (!sectionTestHasBeenSetup)
		return;

	editAislesWindow = new EditAislesWindow(target, app, testStoreName);
	editAislesWindow.BackButton().tap();
	editAislesWindow.BackButton().waitForInvalid();
	
	var editStoreWindow = new EditStoreWindow(target, app);
	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();
	
	sectionTestHasBeenSetup = false;	
}
function enterDeleteMode(editAislesWindow)
{
	if (editAislesWindow.EnterDeleteModeButton().isValid())
	{
		editAislesWindow.EnterDeleteModeButton().tap();
		editAislesWindow.EnterDeleteModeButton().waitForInvalid();
	}
	editAislesWindow.Mode = "Delete"; 
}

function exitDeleteMode(editAislesWindow)
{	
	assertTrue(editAislesWindow.ExitDeleteModeButton().isValid());
	if (editAislesWindow.ExitDeleteModeButton().isValid())
	{
		editAislesWindow.ExitDeleteModeButton().tap();
		editAislesWindow.ExitDeleteModeButton().waitForInvalid();
	};
	editAislesWindow.Mode = "View"; 
}


function testAddGrocerySectionInSameAisle(target, app)
{
	//setup: create store, then edit
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown']) );
								 
	enterEditMode(editAislesWindow);
	 
	editAislesWindow.InsertAfterSectionButton("unknown").tap();
	 
	var newSectionCell = editAislesWindow.CellToEdit("Aisle:");
	newSectionCell.SectionNameTextField().setValue("new grocery section in same aisle");
	newSectionCell.DoneButton().tap();
 	newSectionCell.DoneButton().waitForInvalid();
	
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'new grocery section in same aisle']) );

	editAislesWindow.InsertAfterSectionButton("unknown").tap();
	 
	var newSectionCell = editAislesWindow.CellToEdit("Aisle:");
	newSectionCell.SectionNameTextField().setValue("middle item in aisle 0");
	newSectionCell.DoneButton().tap();
 	newSectionCell.DoneButton().waitForInvalid();

	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'middle item in aisle 0','new grocery section in same aisle']) );
	 
	exitEditMode(editAislesWindow);	 
	
}


function testAddGrocerySectionInNewAisle(target, app)
{	
	//setup: create store, then edit
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
	 
	enterEditMode(editAislesWindow);
	 
	editAislesWindow.InsertAfterSectionButton('new grocery section in same aisle').tap();
	 
	var newSectionCell = editAislesWindow.CellToEdit("Aisle:");
	newSectionCell.SectionNameTextField().setValue("new grocery section in new aisle");
	newSectionCell.IncrementAisleNumberButton().tap();
	 
	target.pushTimeout(1);
	assertEquals(1, newSectionCell.AisleNumberTextField().value(), "Aisle number is not as expected.");
	target.popTimeout();
	newSectionCell.DoneButton().tap();
 	newSectionCell.DoneButton().waitForInvalid();

	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'middle item in aisle 0','new grocery section in same aisle'], 'Aisle 1', ['new grocery section in new aisle']) );

	exitEditMode(editAislesWindow);
}	  

function testCannotInsertGrocerySectionWithNoName(target, app)
{
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
	//testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'new grocery section in same aisle']) );
	 
	enterEditMode(editAislesWindow);
	 
	editAislesWindow.InsertAfterSectionButton('new grocery section in same aisle').tap();
	 
	var newSectionCell = editAislesWindow.CellToEdit("Aisle:");

	newSectionCell.DoneButton().tap();
 	newSectionCell.DoneButton().waitForInvalid();

	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'middle item in aisle 0','new grocery section in same aisle'], 'Aisle 1', ['new grocery section in new aisle']) );
	
	exitEditMode(editAislesWindow);  
}

function testCannotInsertGrocerySectionWithDuplicateName(target, app)
{
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
	//testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'new grocery section in same aisle']) );
	 
	enterEditMode(editAislesWindow);
	 
	editAislesWindow.InsertAfterSectionButton('new grocery section in new aisle').tap();
	 
	var newSectionCell = editAislesWindow.CellToEdit("Aisle:");

	newSectionCell.SectionNameTextField().setValue("new grocery section in same aisle");
	newSectionCell.IncrementAisleNumberButton().tap();
	 
	target.pushTimeout(1);
	assertEquals(2, newSectionCell.AisleNumberTextField().value(), "Aisle number is not as expected.");
	target.popTimeout();
	
	expectedAlertMessage = "Section Name Already Exists"

	newSectionCell.DoneButton().tap();
	newSectionCell.DoneButton().waitForInvalid();
	var okayButton = app.alert().buttons()["Okay"];
	okayButton.tap(); 
	okayButton.waitForInvalid();
	
	 //editAislesWindow.AislesTableView().logElementTree(); 
	 
	newSectionCell.SectionNameTextField().setValue("unique grocery section in aisle 2");
	newSectionCell.DoneButton().tap();
	newSectionCell.DoneButton().waitForInvalid();	 
	 
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'middle item in aisle 0','new grocery section in same aisle'], 'Aisle 1', ['new grocery section in new aisle'], 'Aisle 2', ['unique grocery section in aisle 2'] ));
	  
	exitEditMode(editAislesWindow);
}

function testDeleteSectionInAisle(target, app)
{
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
								 
	enterDeleteMode(editAislesWindow);
	var deleteCell = editAislesWindow.CellToDelete('new grocery section in same aisle');
	deleteCell.DeleteSwitch().tap();
	deleteCell.logElement();
	deleteCell.ConfirmDeleteButton().tap();
	 
	deleteCell.ConfirmDeleteButton().waitForInvalid();
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'middle item in aisle 0'], 'Aisle 1', ['new grocery section in new aisle'], 'Aisle 2', ['unique grocery section in aisle 2'] ));	 

	exitEditMode(editAislesWindow);
}

function testDeleteLastSectionInAisle(target, app)
{
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
								 
	enterDeleteMode(editAislesWindow);
	
	var deleteCell = editAislesWindow.CellToDelete('unique grocery section in aisle 2');
	deleteCell.logElement();
	 
	assertTrue(deleteCell.DeleteSwitch().isValid(), 'delete switch is not valid');
	 
	// todo: this needs to change!
	deleteCell.DeleteSwitch().tap();
	
	target.pushTimeout(2);
	deleteCell.ConfirmDeleteButton().isValid();
	target.popTimeout();
	
	 deleteCell.ConfirmDeleteButton().tap();
	 	 
	deleteCell.ConfirmDeleteButton().waitForInvalid();
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown', 'middle item in aisle 0'], 'Aisle 1', ['new grocery section in new aisle']) );

	//todo: this should not need to be done 2x!
	exitDeleteMode(editAislesWindow);
}

function testUpdateSectionAisle(target, app)
{
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
	 
	enterEditMode(editAislesWindow);
	 
	var editCell = editAislesWindow.CellToEdit('middle item in aisle 0');
	editCell.tap();

	target.pushTimeout(2);
	editCell.AisleNumberTextField().isValid();
	target.popTimeout();
	
	editCell.AisleNumberTextField().setValue("5");
	 
	editCell.DoneButton().tap();
 	editCell.DoneButton().waitForInvalid();

	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown'], 'Aisle 1', ['new grocery section in new aisle'], 'Aisle 5', ['middle item in aisle 0']) );	

	exitEditMode(editAislesWindow);
}

function testUpdateSectionName(target, app)
{
	setupSectionTest(target, app)
	
	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 
	 
	enterEditMode(editAislesWindow);
	 
	var editCell = editAislesWindow.CellToEdit('middle item in aisle 0');
	
	editCell.tap();
	target.pushTimeout(2);
	editCell.SectionNameTextField().isValid();
	target.popTimeout();
	
	editCell.SectionNameTextField().setValue('first item in aisle 5');
	 
	editCell.DoneButton().tap();
 	editCell.DoneButton().waitForInvalid();

	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown'], 'Aisle 1', ['new grocery section in new aisle'], 'Aisle 5', ['first item in aisle 5']) );
	 
	exitEditMode(editAislesWindow);	
	
}

function testSaveAndLoadAisleConfig(target, app)
{
	//setupSectionTest(target, app)	
	exitSectionTest(target, app);	 

 	setupSectionTest(target, app);

	var editAislesWindow = new EditAislesWindow(target, app, testStoreName); 	 
	testEditAislesWindowValidity(editAislesWindow, new Hash('Aisle 0', ['unknown'], 'Aisle 1', ['new grocery section in new aisle'], 'Aisle 5', ['first item in aisle 5']) );
	 
	exitSectionTest(target, app);	 
	
}

