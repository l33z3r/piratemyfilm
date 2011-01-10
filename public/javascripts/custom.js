//custom js functionality

var loadingImage = false;

function doInit() {
    $("#content_container *").tooltip();

    //attach ajax loading images to elements
    $(document).ajaxStart(function() {
        if(!loadingImage) showLoadingImage();
    });

    $(document).ajaxStop(function() {
        if(loadingImage) hideLoadingImage();
    })
}

function showLoadingImage() {
    ModalPopups.Indicator("loadingImgContainer",
        "Loading...",
        "<div style='text-align: center; padding-top: 8px;'>\n\
        <img src='/images/spinner.gif'></div>",
        { 
            width: 90,
            height: 70
        } );

    loadingImage = true;
}

function hideLoadingImage() {
    ModalPopups.Close("loadingImgContainer");
    loadingImage = false;
}

function selectTalent(talentName, talentId, talentUsername) {
    talentIdContainerId = $('#' + talentName + '_talent_id');
    talentUsernameContainerId = $('#' + talentName + '_name');
    talentClearLink = $('#' + talentName + '_clear_talent_link_container');

    talentIdContainerId.val(talentId);
    talentUsernameContainerId.val(talentUsername);
    talentUsernameContainerId.attr('disabled', true);
    talentClearLink.show();

    talentIdContainerId = talentUsernameContainerId = null;

    ModalPopups.Close('talentSelectListContainer');
}

function clearTalent(talentName) {
    talentIdContainerId = $('#' + talentName + '_talent_id');
    talentUsernameContainerId = $('#' + talentName + '_name');
    talentClearLink = $('#' + talentName + '_clear_talent_link_container');

    talentIdContainerId.val('');
    talentUsernameContainerId.val('');
    talentUsernameContainerId.attr('disabled', false);
    talentClearLink.hide();
}