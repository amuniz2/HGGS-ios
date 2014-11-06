var testStoreHasBeenSetup = false;
var testStoreName = "UI Automation Test Store";
var initialTestStoreName = "My Grocery Store"

function setupStores(target, app)
{
	if (testStoreHasBeenSetup)
		return;
	
	var mainWindow = new MainWindow(target, app);
	var editStoreWindow = new EditStoreWindow(target, app);
	
	if (!storeExists(mainWindow.StorePicker().wheels()[0].values(), initialTestStoreName) )
	{
		createStore(target, app, initialTestStoreName);		
	}
	
	testStoreHasBeenSetup = true;
	
}

function testInitialScreen(target, app)
{
	 setupStores (target, app);
	 var window = new MainWindow(target,app);
	 testMainWindowValidity(window, initialTestStoreName);
}

function testAddNewStore(target, app)
{
	var mainWindow = new MainWindow(target, app);
	
	mainWindow.AddStoreButton().tap();
 	mainWindow.EditStoreButton().waitForInvalid();
 
 	var editStoreWindow = new EditStoreWindow(target, app);
 	testEditStoreWindowValidity(editStoreWindow, "");
 	
 	editStoreWindow.EditStoreNameButton().tap();
 	target.pushTimeout(1);
 	assertTrue(editStoreWindow.StoreNameTextField().isEnabled(), "Edit field is not enabled after clicking Compose button");
 	target.popTimeout();	
 	editStoreWindow.StoreNameTextField().setValue("My New Grocery Store");
	target.delay(1);
	
 	editStoreWindow.DoneEditingStoreNameButton().tap();

 	
	testEditStoreWindowValidity(editStoreWindow, "My New Grocery Store");

	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();  

}  
function testAddNewStoreWithSameName(target, app)
{
	var mainWindow = new MainWindow(target, app);
	
	mainWindow.AddStoreButton().tap();
 	mainWindow.EditStoreButton().waitForInvalid();
 
 	var editStoreWindow = new EditStoreWindow(target, app);
 	testEditStoreWindowValidity(editStoreWindow, "");
 	
 	editStoreWindow.EditStoreNameButton().tap();
 	target.pushTimeout(1);
 	assertTrue(editStoreWindow.StoreNameTextField().isEnabled(), "Edit field is not enabled after clicking Compose button");
 	target.popTimeout();	
 	editStoreWindow.StoreNameTextField().setValue("My New Grocery Store");
	
	
	expectedAlertMessage = "Duplicate Store";
 	editStoreWindow.DoneEditingStoreNameButton().tap();
	 
	var okayButton = app.alert().buttons()["Okay"];
	okayButton.tap(); 
	okayButton.waitForInvalid(); 

	editStoreWindow.BackButton().tap();
	editStoreWindow.BackButton().waitForInvalid();  

}  

function testEditRenameStoreWithoutClickingDoneButton(target, app)
{
	 var mainWindow = new MainWindow(target, app);
	 var storeNameToEdit = "My New Grocery Store"
	 testMainWindowValidity(mainWindow, initialTestStoreName, storeNameToEdit);
	 
	 mainWindow.StorePicker().wheels()[0].selectValue(storeNameToEdit);
	 mainWindow.EditStoreButton().tap();
	 mainWindow.EditStoreButton().waitForInvalid();
	 
	 var editStoreWindow = new EditStoreWindow(target, app);
	 testEditStoreWindowValidity(editStoreWindow, storeNameToEdit);

	 editStoreWindow.EditStoreNameButton().tap();
	 target.pushTimeout(1);
	 assertTrue(editStoreWindow.StoreNameTextField().isEnabled(), "Edit field is not enabled after clicking Compose button");
	 target.popTimeout();
	 
	 editStoreWindow.StoreNameTextField().setValue("My New Grocery Store Name");
	 
	 editStoreWindow.BackButton().tap();
	 editStoreWindow.BackButton().waitForInvalid();
 
	 testMainWindowValidity(mainWindow, initialTestStoreName, "My New Grocery Store Name");
	
}

function testEditRenameMyNewStore(target, app)
{
	 var mainWindow = new MainWindow(target, app);
	 var storeNameToEdit = "My New Grocery Store Name"
	 testMainWindowValidity(mainWindow, initialTestStoreName, storeNameToEdit);
	 
	 mainWindow.StorePicker().wheels()[0].selectValue(storeNameToEdit);
	 mainWindow.EditStoreButton().tap();
	 mainWindow.EditStoreButton().waitForInvalid();
	 
	 var editStoreWindow = new EditStoreWindow(target, app);
	 testEditStoreWindowValidity(editStoreWindow, storeNameToEdit);

	 editStoreWindow.EditStoreNameButton().tap();
	 target.pushTimeout(1);
	 assertTrue(editStoreWindow.StoreNameTextField().isEnabled(), "Edit field is not enabled after clicking Compose button");
	 target.popTimeout();
	 
	 editStoreWindow.StoreNameTextField().setValue(testStoreName);
	 editStoreWindow.DoneEditingStoreNameButton().tap();
	 assertEquals(testStoreName, editStoreWindow.StoreNameTextField().value());
	 
	 editStoreWindow.BackButton().tap();
	 editStoreWindow.BackButton().waitForInvalid();
	 target.onAlert = editStoreWindow.onAlert;
 
	 testMainWindowValidity(mainWindow, initialTestStoreName, testStoreName);
	
}

function testDeleteMyGroceryStore(target, app)
{
	var mainWindow = new MainWindow(target, app);
 	var storeNameToDelete = initialTestStoreName;
 	//testMainWindowValidity(mainWindow, "UI Automation Test Store", storeNameToDelete);
 
 	mainWindow.StorePicker().wheels()[0].selectValue(storeNameToDelete);
 	mainWindow.EditStoreButton().tap();
 	mainWindow.EditStoreButton().waitForInvalid();
 
 	var editStoreWindow = new EditStoreWindow(target, app);
 	testEditStoreWindowValidity(editStoreWindow, storeNameToDelete);

	expectedAlertMessage = "Delete Store";
	 
	editStoreWindow.DeleteStoreButton().tap(); 
 	editStoreWindow.DeleteStoreButton().waitForInvalid();
	
	var buttons = app.alert().buttons();
	for (var i = 0; i < buttons.length; i++) 
	{
		buttons[i].logElement();
	}
	var yesButton = buttons["Yes"];
	assertTrue(yesButton.isValid(), "Yes button is not valid.");
	yesButton.tap();
	yesButton.waitForInvalid(); 
	
	testMainWindowValidity(mainWindow, testStoreName );
	//assertEquals("",  expectedAlertMessage);
	
}

