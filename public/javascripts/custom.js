//custom js functionality

var loadingImage = false;

var loggedIn;

function doInit() {
    $("#content_container *").tooltip({showURL: false});

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
//
//function selectTalent_OLD(talentName, talentId, talentUsername) {
//    talentIdContainerId = $('#' + talentName + '_talent_id');
//    talentUsernameContainerId = $('#' + talentName + '_name');
//    talentClearLink = $('#' + talentName + '_clear_talent_link_container');
//
//    talentIdContainerId.val(talentId);
//    talentUsernameContainerId.val(talentUsername);
//    talentUsernameContainerId.attr('disabled', true);
//    talentClearLink.show();
//
//    talentIdContainerId = talentUsernameContainerId = null;
//
//    ModalPopups.Close('talentSelectListContainer');
//}

var postInProgress = false;

function doPostBuzz() {
    if(postInProgress) {
        alert("Please wait while your post is sent.");
        return;
    }
    
    if($('#blog_body').val().length == 0) {
        alert("Please enter a buzz.");
        return;
    }
    
    postInProgress = true;
    
    $('#blog_form').submit();
}
function doBuzzCharCount(el) {
    var input = $(el).val();
    
    //extract links (they count for 24 chars)
    var URLexp = /(^|\s|-)+http:\/\//g;
    var words = input.split(" ");
    
    var linkCount = 0;
    var charDeduction = 0;
    
    for(var i=0; i<words.length; i++) {
        var exists = words[i].match(URLexp);
        
        if(exists) {
            linkCount++;
            charDeduction += words[i].length;
        }
    }
    
    var bitlyCharsPerLink = 24;
    var inputLength = input.length - charDeduction + (linkCount * bitlyCharsPerLink);
    
    //console.log("Links: " + linkCount + " Deduct: " + charDeduction + " Orig Input Length: " + input.length + " New Input Length: " + inputLength);
    
    if(inputLength > 140) {
        $(el).val($(el).val().substring(0,140));
    }
    
    if(linkCount > 0) {
        $('#link_shorten_message').show();
    } else {
        $('#link_shorten_message').hide();
    }
    
    chars_left = (140 - inputLength < 0) ? 0 : 140 - inputLength;
    $('#char_count').html(chars_left);
}

function doRebuzz(blogId, confirm) {
    if(!loggedIn) {
        redirectToLogin();
        return false;
    }
    
    $.ajax({
        url: "/blogs",
        type : "POST",
        dataType: 'script',
        data : {
            "blog[blog_rebuzz_id]" : blogId,
            confirm_rebuzz : confirm,
            authenticity_token : $("#post_update_box input[name='authenticity_token']").val()
        }
    });
    
    return false;
}

function doReply(mention) {
    if(!loggedIn) {
        redirectToLogin();
        return;
    }
    
    $('#post_update_box #blog_body').val(mention + " ");
    $('#post_update_box #blog_rebuzz_id').val("");
    $('#post_update_box #blog_body').focus();
    
    var animation = {
        scrollTop: $('#post_update_box').offset().top
        };
    $('html,body').animate(animation, 'slow', 'swing');
    
}

function redirectToLogin() {
    location = "/login";
}

function doProjectSearch() {
    $('#global_search_type').val('projects');
    $('#global_search_form').submit();
}

function doUserSearch() {
    $('#global_search_type').val('users');
    $('#global_search_form').submit();
}