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

function addTalent(talentId, projectId) {
    $.ajax({
        url: "/projects/" + projectId + "/add_talent",
        type : "POST",
        dataType: 'script',
        data : {
            talent_id : talentId
        }
    });

    ModalPopups.Close('talentSelectListContainer');
}

function removeTalent(pt_id, projectId) {
    $.ajax({
        url: "/projects/" + projectId + "/remove_talent",
        type : "POST",
        dataType: 'script',
        data : {
            pt_id : pt_id
        }
    });
}

function selectTalent_OLD(talentName, talentId, talentUsername) {
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

function doBuzzCharCount(el) {
    var inputLength = $(el).val().length;
    
    if(inputLength > 140) {
        $(el).val($(el).val().substring(0,140));
    }
    
    chars_left = (140 - inputLength < 0) ? 0 : 140 - inputLength;
    $('#char_count').html(chars_left);
}