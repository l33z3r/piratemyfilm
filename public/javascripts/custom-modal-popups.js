



//#########################################################examples

function ModalPopupsAlert1() {
    ModalPopups.Alert("jsAlert1",
        "Save address information",
        "<div style='padding:25px;'>The address information has been saved succesfully<br/>" +
        "to the customer database...<br/></div>",
        {
            okButtonText: "Close"
        }
        );
}

function ModalPopupsAlert99() {
    ModalPopups.Alert("jsAlert99",
        "Save address information",
        "",
        {
            okButtonText: "Close",
            loadTextFile: "TextFile.txt",
            width: 500,
            height: 300
        }
        );
}

function ModalPopupsAlert3() {
    ModalPopups.Alert("jsAlert3",
        "Save address information",
        "<div style='padding:25px;'>The address information has been saved succesfully<br/>" +
        "to the customer database...<br/></div>",
        {
            titleBackColor: "#A1B376",
            titleFontColor: "white",
            popupBackColor: "#E9E8CF",
            popupFontColor: "black",
            footerBackColor: "#A1B376",
            footerFontColor: "white"
        }
        );
}

function ModalPopupsAlert2() {
    ModalPopups.Alert("jsAlert2",
        "Save address information",
        "<div style='padding:25px;'>The address information has been saved succesfully<br/>" +
        "to the customer database...<br/></div>",
        {
            shadowSize: 15,
            okButtonText: "Close",
            backgroundColor: "Yellow",
            fontFamily: "Courier New",
            fontSize: "9pt"
        }
        );
}

function ModalPopupsConfirm() {
    ModalPopups.Confirm("idConfirm1",
        "Confirm delete address information",
        "<div style='padding: 25px;'>You are about to delete this address information.<br/><br/><b>Are you sure?</b></div>",
        {
            yesButtonText: "Yes",
            noButtonText: "No",
            onYes: "ModalPopupsConfirmYes()",
            onNo: "ModalPopupsConfirmNo()"
        }
        );
}

function ModalPopupsConfirmYes() {
    alert('You pressed Yes');
    ModalPopups.Close("idConfirm1");
}

function ModalPopupsConfirmNo() {
    alert('You pressed No');
    ModalPopups.Cancel("idConfirm1");
}

function ModalPopupsYesNoCancel() {
    ModalPopups.YesNoCancel("idYesNoCancel1",
        "Confirm close of document",
        "<div style='padding: 25px;'><p>You are about to close this document.<br/>" +
        "If you don't save this document, all information will be lost.</p>" +
        "<p><b>Close document?</b></p></div>",
        {
            onYes: "ModalPopupsYesNoCancelYes()",
            onNo: "ModalPopupsYesNoCancelNo()",
            onCancel: "ModalPopupsYesNoCancelCancel()"
        }
        );
}

function ModalPopupsYesNoCancelYes() {
    alert('You pressed Yes');
    ModalPopups.Close("idYesNoCancel1");
}

function ModalPopupsYesNoCancelNo() {
    alert('You pressed No');
    ModalPopups.Cancel("idYesNoCancel1");
}

function ModalPopupsYesNoCancelCancel() {
    alert('You pressed Cancel');
    ModalPopups.Cancel("idYesNoCancel1");
}

function ModalPopupsPrompt() {
    ModalPopups.Prompt("idPrompt1",
        "Prompt",
        "Please enter your ID number",
        {
            width: 300,
            height: 100,
            onOk: "ModalPopupsPromptOk()",
            onCancel: "ModalPopupsPromptCancel()"
        }
        );
}

function ModalPopupsPromptOk()
{
    if(ModalPopups.GetPromptInput("idPrompt1").value == "") {
        ModalPopups.GetPromptInput("idPrompt1").focus();
        return;
    }
    alert("You pressed OK\nValue: " + ModalPopups.GetPromptInput("idPrompt1").value);
    ModalPopups.Close("idPrompt1");
}

function ModalPopupsPromptCancel() {
    alert("You pressed Cancel");
    ModalPopups.Cancel("idPrompt1");
}

function ModalPopupsIndicator() {
    ModalPopups.Indicator("idIndicator1",
        "Please wait",
        "Saving address information... <br/>" +
        "This may take 3 seconds.", {
            width: 300,
            height: 100
        });

    setTimeout('ModalPopups.Close(\"idIndicator1\");', 3000);
}

function ModalPopupsIndicator2() {
    ModalPopups.Indicator("idIndicator2",
        "Please wait",
        "<div style=''>" +
        "<div style='float:left;'><img src='spinner.gif'></div>" +
        "<div style='float:left; padding-left:10px;'>" +
        "Saving address information... <br/>" +
        "This may take 3 seconds." +
        "</div>",
        {
            width: 300,
            height: 100
        }
        );

    setTimeout('ModalPopups.Close(\"idIndicator2\");', 3000);
}

function ModalPopupsCustom1() {
    ModalPopups.Custom("idCustom1",
        "Enter address information",
        "<div style='padding: 25px;'>" +
        "<table>" +
        "<tr><td>Name</td><td><input type=text id='inputCustom1Name' style='width:250px;'></td></tr>" +
        "<tr><td>Address</td><td><input type=text id='inputCustom1Address' style='width:250px;'></td></tr>" +
        "<tr><td>ZipCode</td><td><input type=text id='inputCustom1ZipCode' style='width:100px;'></td></tr>" +
        "<tr><td>City</td><td><input type=text id='inputCustom1City' style='width:250px;'></td></tr>" +
        "<tr><td>Phone</td><td><input type=text id='inputCustom1Phone' style='width:250px;'></td></tr>" +
        "<tr><td>E-Mail</td><td><input type=text id='inputCustom1EMail' style='width:250px;'></td></tr>" +
        "</table>" +
        "</div>",
        {
            width: 500,
            buttons: "ok,cancel",
            okButtonText: "Save",
            cancelButtonText: "Cancel",
            onOk: "ModalPopupsCustom1Save()",
            onCancel: "ModalPopupsCustom1Cancel()"
        }
        );

    ModalPopups.GetCustomControl("inputCustom1Name").focus();
}

function ModalPopupsCustom1Save() {
    var custom1Name = ModalPopups.GetCustomControl("inputCustom1Name");
    if(custom1Name.value == "")
    {
        alert("Please submit a name to this form");
        custom1Name.focus();
    }
    else
    {
        alert("Your name is: " + custom1Name.value);
        ModalPopups.Close("idCustom1");
    }
}

function ModalPopupsCustom1Cancel() {
    alert('You pressed Cancel');
    ModalPopups.Cancel("idCustom1");
}
